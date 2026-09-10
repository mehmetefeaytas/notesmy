import Foundation
import AVFoundation
import CoreMedia

/// Voice profile fingerprint for a detected speaker
public struct SpeakerVoiceProfile: Codable, Equatable, Sendable {
    public var id: Int
    public var assignedName: String?
    public var averagePitchHz: Float
    public var sampleCount: Int

    public init(id: Int, assignedName: String? = nil, averagePitchHz: Float = 150.0, sampleCount: Int = 1) {
        self.id = id
        self.assignedName = assignedName
        self.averagePitchHz = averagePitchHz
        self.sampleCount = sampleCount
    }

    public mutating func updateWith(pitch: Float) {
        let weight = min(Float(sampleCount), 30.0)
        self.averagePitchHz = (averagePitchHz * weight + pitch) / (weight + 1.0)
        self.sampleCount += 1
    }
}

/// Professional Speaker Diarization Engine
/// Segments speech by conversational pauses, attributes speaker turns via acoustic pitch clustering,
/// and maps named attendees (Meetily Plus style).
public final class SpeakerDiarizationService: @unchecked Sendable {
    public static let shared = SpeakerDiarizationService()

    private let lock = NSLock()
    private var speakerProfiles: [Int: SpeakerVoiceProfile] = [:]
    private var lastSpeakerId: Int = 1
    private var activeSpeakerId: Int = 1
    private var lastSpeechTime: TimeInterval = 0
    private var lastPauseDetectedTime: TimeInterval = 0

    // Pitch smoothing window
    private var recentPitches: [Float] = []

    private init() {}

    public func reset(attendees: [String] = []) {
        lock.lock()
        defer { lock.unlock() }

        speakerProfiles.removeAll()
        recentPitches.removeAll()
        lastSpeechTime = 0
        lastPauseDetectedTime = 0
        lastSpeakerId = 1
        activeSpeakerId = 1

        // Pre-seed attendee names if provided
        for (index, name) in attendees.enumerated() {
            let spkId = index + 1
            speakerProfiles[spkId] = SpeakerVoiceProfile(
                id: spkId,
                assignedName: name,
                averagePitchHz: index % 2 == 0 ? 140.0 : 220.0
            )
        }
    }

    /// Processes CMSampleBuffer from ScreenCaptureKit
    public func processCMSampleBuffer(
        sampleBuffer: CMSampleBuffer,
        elapsedTime: TimeInterval
    ) -> (speakerId: Int, isNewTurn: Bool) {
        var blockBuffer: CMBlockBuffer?
        var audioBufferList = AudioBufferList()

        let status = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
            sampleBuffer,
            bufferListSizeNeededOut: nil,
            bufferListOut: &audioBufferList,
            bufferListSize: MemoryLayout<AudioBufferList>.size,
            blockBufferAllocator: nil,
            blockBufferMemoryAllocator: nil,
            flags: 0,
            blockBufferOut: &blockBuffer
        )

        guard status == noErr else { return (activeSpeakerId, false) }

        let buffers = UnsafeMutableAudioBufferListPointer(&audioBufferList)
        guard let firstBuf = buffers.first, let mData = firstBuf.mData else {
            return (activeSpeakerId, false)
        }

        let sampleCount = Int(firstBuf.mDataByteSize) / MemoryLayout<Float>.size
        guard sampleCount > 256 else { return (activeSpeakerId, false) }

        let samples = mData.assumingMemoryBound(to: Float.self)
        return processSamples(samples, count: sampleCount, sampleRate: 48000.0, elapsedTime: elapsedTime)
    }

    /// Processes an audio buffer from the microphone or system audio to extract pitch/energy
    public func processAudioBuffer(
        buffer: AVAudioPCMBuffer,
        sampleRate: Float = 16000.0,
        elapsedTime: TimeInterval
    ) -> (speakerId: Int, isNewTurn: Bool) {
        guard let channelData = buffer.floatChannelData?[0] else {
            return (activeSpeakerId, false)
        }

        let frameCount = Int(buffer.frameLength)
        guard frameCount > 256 else {
            return (activeSpeakerId, false)
        }

        return processSamples(channelData, count: frameCount, sampleRate: sampleRate, elapsedTime: elapsedTime)
    }

    private func processSamples(
        _ samples: UnsafePointer<Float>,
        count: Int,
        sampleRate: Float,
        elapsedTime: TimeInterval
    ) -> (speakerId: Int, isNewTurn: Bool) {
        lock.lock()
        defer { lock.unlock() }

        // 1. Calculate RMS energy
        var sum: Float = 0
        var zeroCrossings: Int = 0
        var prevSample: Float = samples[0]

        for i in 0..<count {
            let sample = samples[i]
            sum += sample * sample
            if (sample >= 0 && prevSample < 0) || (sample < 0 && prevSample >= 0) {
                zeroCrossings += 1
            }
            prevSample = sample
        }

        let rms = sqrt(sum / Float(count))
        let isSilence = (rms < 0.015)

        if isSilence {
            lastPauseDetectedTime = elapsedTime
            return (activeSpeakerId, false)
        }

        // 2. Voice Activity Detected: calculate zero-crossing rate pitch proxy (restricted to human voice range 70Hz - 450Hz)
        let rawPitch = (Float(zeroCrossings) / Float(count)) * (sampleRate / 2.0)
        let clampedPitch = max(70.0, min(450.0, rawPitch))

        recentPitches.append(clampedPitch)
        if recentPitches.count > 12 {
            recentPitches.removeFirst()
        }

        let currentPitch = recentPitches.reduce(0, +) / Float(recentPitches.count)
        let silenceDuration = elapsedTime - lastPauseDetectedTime
        let isNewTurn = (silenceDuration >= 0.85 && lastSpeechTime > 0)

        lastSpeechTime = elapsedTime

        if isNewTurn {
            // Find closest matching speaker profile or allocate new speaker
            activeSpeakerId = classifySpeaker(pitch: currentPitch)
        } else if let profile = speakerProfiles[activeSpeakerId] {
            var updated = profile
            updated.updateWith(pitch: currentPitch)
            speakerProfiles[activeSpeakerId] = updated
        }

        return (activeSpeakerId, isNewTurn)
    }

    private func classifySpeaker(pitch: Float) -> Int {
        if speakerProfiles.isEmpty {
            speakerProfiles[1] = SpeakerVoiceProfile(id: 1, averagePitchHz: pitch)
            return 1
        }

        // Check difference with existing profiles
        var closestId = 1
        var minDiff: Float = 9999.0

        for (id, profile) in speakerProfiles {
            let diff = abs(profile.averagePitchHz - pitch)
            if diff < minDiff {
                minDiff = diff
                closestId = id
            }
        }

        // If pitch difference is significant (> 28 Hz) and we have fewer than 6 room speakers, spawn a new speaker
        if minDiff > 28.0 && speakerProfiles.count < 6 {
            let newId = speakerProfiles.count + 1
            speakerProfiles[newId] = SpeakerVoiceProfile(id: newId, averagePitchHz: pitch)
            return newId
        }

        if var profile = speakerProfiles[closestId] {
            profile.updateWith(pitch: pitch)
            speakerProfiles[closestId] = profile
        }

        return closestId
    }

    /// Resolves the MeetingSpeaker enum for a given speaker ID and capture mode
    public func resolveSpeaker(
        channel: MeetingAudioChannel,
        speakerId: Int,
        mode: MeetingMode,
        attendees: [String]
    ) -> MeetingSpeaker {
        lock.lock()
        defer { lock.unlock() }

        if mode == .online && channel == .microphone {
            return .you
        }

        if let profile = speakerProfiles[speakerId], let name = profile.assignedName, !name.isEmpty {
            return .custom(name)
        }

        // If pre-configured attendee name exists at this index
        let attendeeIndex = speakerId - 1
        if attendeeIndex >= 0 && attendeeIndex < attendees.count {
            let name = attendees[attendeeIndex]
            return .custom(name)
        }

        if mode == .inPerson || mode == .micOnly {
            return .roomSpeaker(speakerId)
        } else {
            // Online remote participant
            return (speakerId > 1) ? .roomSpeaker(speakerId) : .remote
        }
    }

    /// Bulk rename all occurrences of a speaker in the transcript
    public func renameSpeakerInTranscript(
        targetSpeaker: MeetingSpeaker,
        newName: String,
        transcript: inout [MeetingTranscriptEntry]
    ) {
        let cleanName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else { return }

        let replacement = MeetingSpeaker.custom(cleanName)
        for i in transcript.indices {
            if transcript[i].speaker == targetSpeaker {
                transcript[i].speaker = replacement
            }
        }

        lock.lock()
        if case .roomSpeaker(let idx) = targetSpeaker {
            if var profile = speakerProfiles[idx] {
                profile.assignedName = cleanName
                speakerProfiles[idx] = profile
            }
        }
        lock.unlock()
    }

    /// Split a transcript entry into two separate entries with alternating speakers (Meetily Plus)
    public func splitTranscriptEntry(
        entryId: UUID,
        splitCharIndex: Int,
        newSpeaker: MeetingSpeaker,
        transcript: inout [MeetingTranscriptEntry]
    ) -> Bool {
        guard let index = transcript.firstIndex(where: { $0.id == entryId }) else {
            return false
        }

        let original = transcript[index]
        let originalText = original.text
        guard splitCharIndex > 0 && splitCharIndex < originalText.count else {
            return false
        }

        let indexStr = originalText.index(originalText.startIndex, offsetBy: splitCharIndex)
        let firstPart = String(originalText[..<indexStr]).trimmingCharacters(in: .whitespaces)
        let secondPart = String(originalText[indexStr...]).trimmingCharacters(in: .whitespaces)

        guard !firstPart.isEmpty && !secondPart.isEmpty else { return false }

        transcript[index].text = firstPart
        transcript[index].duration = max(1.0, original.duration / 2.0)

        let newEntry = MeetingTranscriptEntry(
            id: UUID(),
            timestamp: original.timestamp + max(1.0, original.duration / 2.0),
            duration: max(1.0, original.duration / 2.0),
            speaker: newSpeaker,
            text: secondPart,
            isFinal: true
        )

        transcript.insert(newEntry, at: index + 1)
        return true
    }
}

public enum MeetingAudioChannel: Sendable {
    case microphone
    case systemAudio
}
