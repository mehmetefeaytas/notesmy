import Foundation
import AVFoundation
@preconcurrency import Speech
import CoreGraphics
import CoreMedia
@preconcurrency import ScreenCaptureKit

// MARK: - Safe Nonisolated Relay for System Audio Sample Buffers
private final class SystemAudioRelay: @unchecked Sendable {
    private let request: SFSpeechAudioBufferRecognitionRequest

    init(request: SFSpeechAudioBufferRecognitionRequest) {
        self.request = request
    }

    nonisolated func appendSampleBuffer(_ buffer: CMSampleBuffer) {
        request.appendAudioSampleBuffer(buffer)
    }
}

// MARK: - Safe Nonisolated Tap Relay for Microphone Audio
private final class MeetingMicRelay: @unchecked Sendable {
    private let request: SFSpeechAudioBufferRecognitionRequest
    private let file: AVAudioFile?
    private let onMeter: @Sendable (Float) -> Void

    init(
        request: SFSpeechAudioBufferRecognitionRequest,
        file: AVAudioFile?,
        onMeter: @escaping @Sendable (Float) -> Void
    ) {
        self.request = request
        self.file = file
        self.onMeter = onMeter
    }

    nonisolated func appendBuffer(_ buffer: AVAudioPCMBuffer) {
        request.append(buffer)
        if let file = file {
            do {
                try file.write(from: buffer)
            } catch {
                // Ignore buffer write hiccups on audio hardware thread
            }
        }

        // Calculate RMS Level for VU Meter
        if let channelData = buffer.floatChannelData?[0] {
            let frames = Int(buffer.frameLength)
            if frames > 0 {
                var sum: Float = 0
                let step = max(1, frames / 128)
                var count = 0
                for i in stride(from: 0, to: frames, by: step) {
                    let val = channelData[i]
                    sum += val * val
                    count += 1
                }
                let rms = count > 0 ? sqrt(sum / Float(count)) : 0
                let normalized = min(1.0, rms * 4.5)
                onMeter(normalized)
            }
        }
    }
}

private nonisolated func installMeetingMicTap(
    on node: AVAudioNode,
    bus: AVAudioNodeBus,
    format: AVAudioFormat,
    relay: MeetingMicRelay
) {
    node.installTap(onBus: bus, bufferSize: 1024, format: format) { buffer, _ in
        relay.appendBuffer(buffer)
    }
}

// MARK: - ScreenCaptureKit Stream Output for System Audio
private final class SystemAudioCaptureOutput: NSObject, SCStreamOutput, @unchecked Sendable {
    private let onAudioSample: @Sendable (CMSampleBuffer) -> Void

    init(onAudioSample: @escaping @Sendable (CMSampleBuffer) -> Void) {
        self.onAudioSample = onAudioSample
        super.init()
    }

    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard type == .audio else { return }
        onAudioSample(sampleBuffer)
    }
}

private final class SystemAudioStreamDelegate: NSObject, SCStreamDelegate, @unchecked Sendable {
    func stream(_ stream: SCStream, didStopWithError error: Error) {
        print("System audio SCStream did stop with error: \(error)")
    }
}

// MARK: - Meeting Recording Service
@MainActor
public final class MeetingRecordingService: NSObject, ObservableObject {
    public static let shared = MeetingRecordingService()

    // Recording State
    @Published public var isRecording: Bool = false
    @Published public var isPaused: Bool = false
    @Published public var selectedMode: MeetingMode = .online
    @Published public var meetingTitle: String = ""
    @Published public var attendees: [String] = []
    @Published public var elapsedSeconds: TimeInterval = 0
    @Published public var userNotes: String = ""

    // VU Meter levels (0.0 to 1.0)
    @Published public var micLevel: Float = 0.0
    @Published public var systemLevel: Float = 0.0

    // Permissions & Hardware availability
    @Published public var hasMicPermission: Bool = false
    @Published public var hasSpeechPermission: Bool = false
    @Published public var hasSystemAudioPermission: Bool = false
    @Published public var recordingNotice: String? = nil

    // Real-time transcript entries
    @Published public var transcriptEntries: [MeetingTranscriptEntry] = []
    @Published public var activeLiveTranscript: String = ""

    // Private Audio & Recognition engines
    private var audioEngine: AVAudioEngine?
    private var micAudioFile: AVAudioFile?
    private var currentRecordedURL: URL?
    private var isMicTapInstalled: Bool = false

    private var scStream: SCStream?
    private var scStreamDelegate: SystemAudioStreamDelegate?
    private var scStreamOutput: SystemAudioCaptureOutput?
    private let scAudioQueue = DispatchQueue(label: "app.notesmy.systemaudio", qos: .userInteractive)

    private var micSpeechRecognizer: SFSpeechRecognizer?
    private var micRecognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var micRecognitionTask: SFSpeechRecognitionTask?

    private var systemSpeechRecognizer: SFSpeechRecognizer?
    private var systemRecognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var systemRecognitionTask: SFSpeechRecognitionTask?

    private var timer: Timer?
    private var meetingStartDate: Date?
    private var lastRecordedUtteranceText: String = ""

    public override init() {
        super.init()
        checkExistingPermissions()
    }

    // MARK: - Permissions Check & Settings Openers
    public func checkExistingPermissions() {
        let captureStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        if captureStatus == .authorized {
            self.hasMicPermission = true
        } else if #available(macOS 14.0, *) {
            self.hasMicPermission = (AVAudioApplication.shared.recordPermission == .granted)
        } else {
            self.hasMicPermission = true
        }
        self.hasSpeechPermission = (SFSpeechRecognizer.authorizationStatus() == .authorized)
        self.hasSystemAudioPermission = CGPreflightScreenCaptureAccess()
    }

    public func openScreenCaptureSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
    }

    public func openMicrophoneSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone") {
            NSWorkspace.shared.open(url)
        }
    }

    public func openSpeechRecognitionSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_SpeechRecognition") {
            NSWorkspace.shared.open(url)
        }
    }

    public func restartApp() {
        let url = Bundle.main.bundleURL
        let config = NSWorkspace.OpenConfiguration()
        NSWorkspace.shared.openApplication(at: url, configuration: config) { _, _ in
            DispatchQueue.main.async {
                NSApplication.shared.terminate(nil)
            }
        }
    }

    public func requestAllPermissions() async -> Bool {
        // 1. Microphone
        let mic = await requestMicPermission()
        // 2. Speech Recognizer
        let speech = await requestSpeechPermission()
        // 3. Screen/System Audio
        let screen = requestScreenCapturePermission()

        self.hasMicPermission = mic
        self.hasSpeechPermission = speech
        self.hasSystemAudioPermission = screen

        return mic || screen
    }

    nonisolated private func requestMicPermission() async -> Bool {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        if authStatus == .authorized { return true }
        if authStatus == .denied || authStatus == .restricted { return false }

        let granted = await AVCaptureDevice.requestAccess(for: .audio)
        if granted { return true }

        if #available(macOS 14.0, *) {
            return await AVAudioApplication.requestRecordPermission()
        }
        return false
    }

    nonisolated private func requestSpeechPermission() async -> Bool {
        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized: return true
        case .denied, .restricted: return false
        case .notDetermined:
            return await withCheckedContinuation { cont in
                SFSpeechRecognizer.requestAuthorization { status in
                    cont.resume(returning: status == .authorized)
                }
            }
        @unknown default: return false
        }
    }

    public func requestScreenCapturePermission() -> Bool {
        if CGPreflightScreenCaptureAccess() {
            self.hasSystemAudioPermission = true
            return true
        }
        _ = CGRequestScreenCaptureAccess()
        self.hasSystemAudioPermission = CGPreflightScreenCaptureAccess()
        return self.hasSystemAudioPermission
    }

    // MARK: - Start Meeting Recording
    @discardableResult
    public func startMeeting(
        title: String = "",
        mode: MeetingMode = .online,
        attendees: [String] = [],
        language: AppLanguage = LocalizationService.shared.language
    ) async -> Bool {
        _ = stopMeeting()
        AudioRecordingService.shared.stopRecording()

        self.selectedMode = mode
        self.meetingTitle = title.isEmpty ? defaultMeetingTitle() : title
        self.attendees = attendees
        self.transcriptEntries = []
        self.activeLiveTranscript = ""
        self.userNotes = ""
        self.elapsedSeconds = 0
        self.isPaused = false
        self.meetingStartDate = Date()
        self.recordingNotice = nil

        // Cleanly prompt for mic/speech if not yet determined (without popping open settings)
        if !hasMicPermission {
            _ = await requestMicPermission()
        }
        if !hasSpeechPermission {
            _ = await requestSpeechPermission()
        }
        checkExistingPermissions()

        let locale = Locale(identifier: language.speechLocale)
        setupSpeechRecognizers(locale: locale)

        // Setup File for recording
        let fileName = "Meeting_\(Int(Date().timeIntervalSince1970)).caf"
        let outputURL = NoteStore.shared.attachmentsDirectory.appendingPathComponent(fileName)
        self.currentRecordedURL = outputURL

        // Start Microphone if mode needs it
        var micSuccess = false
        if mode != .systemOnly {
            micSuccess = startMicrophoneCapture(outputURL: outputURL)
        }

        // Start System Audio if mode is online or systemOnly
        var systemSuccess = false
        if mode == .online || mode == .systemOnly {
            systemSuccess = await startSystemAudioCapture()
        }

        guard micSuccess || systemSuccess else {
            print("MeetingRecordingService: Failed to start audio sources (mic: \(micSuccess), sys: \(systemSuccess))")
            cleanupAll()
            return false
        }

        let isTR = LocalizationService.shared.language == .turkish
        if mode == .online && !systemSuccess && micSuccess {
            self.recordingNotice = isTR
                ? "Toplantı mikrofonunuz üzerinden kaydediliyor. Zoom/Teams sesini doğrudan yakalamak için sistem ayarlarından Ekran Kaydı iznini verip uygulamayı yeniden başlatabilirsiniz."
                : "Recording via microphone. To capture remote voices directly from Zoom/Teams, grant Screen Recording in System Settings and restart the app."
        }

        // Start Elapsed Timer
        startTimer()
        self.isRecording = true
        return true
    }

    // MARK: - Speech Recognizers Setup
    private func setupSpeechRecognizers(locale: Locale) {
        var micRec = SFSpeechRecognizer(locale: locale)
        if micRec == nil || !micRec!.isAvailable {
            micRec = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        }
        self.micSpeechRecognizer = micRec

        var sysRec = SFSpeechRecognizer(locale: locale)
        if sysRec == nil || !sysRec!.isAvailable {
            sysRec = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        }
        self.systemSpeechRecognizer = sysRec
    }

    // MARK: - Microphone Capture
    private func startMicrophoneCapture(outputURL: URL) -> Bool {
        let engine = AVAudioEngine()
        self.audioEngine = engine
        let inputNode = engine.inputNode
        var format = inputNode.inputFormat(forBus: 0)

        if format.sampleRate <= 0 || format.channelCount <= 0 {
            if let fallback = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1) {
                format = fallback
            } else {
                print("Invalid mic format: sampleRate=\(format.sampleRate), channels=\(format.channelCount)")
                return false
            }
        }

        do {
            self.micAudioFile = try AVAudioFile(
                forWriting: outputURL,
                settings: format.settings,
                commonFormat: format.commonFormat,
                interleaved: format.isInterleaved
            )
        } catch {
            print("Failed to create mic AVAudioFile: \(error)")
            self.micAudioFile = nil
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.addsPunctuation = true
        self.micRecognitionRequest = request

        if hasSpeechPermission, let recognizer = micSpeechRecognizer, recognizer.isAvailable {
            self.micRecognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
                Task { @MainActor [weak self] in
                    guard let self = self, self.isRecording, !self.isPaused else { return }
                    if let result = result {
                        let text = result.bestTranscription.formattedString
                        self.handleSpeechTranscription(text: text, speaker: .you, isFinal: result.isFinal)
                    }
                }
            }
        }

        let relay = MeetingMicRelay(request: request, file: micAudioFile) { [weak self] level in
            Task { @MainActor [weak self] in
                guard let self = self, self.isRecording, !self.isPaused else { return }
                self.micLevel = level
            }
        }

        installMeetingMicTap(on: inputNode, bus: 0, format: format, relay: relay)
        self.isMicTapInstalled = true

        engine.prepare()
        do {
            try engine.start()
            return true
        } catch {
            print("Failed to start AVAudioEngine: \(error)")
            return false
        }
    }

    // MARK: - ScreenCaptureKit System Audio Capture
    private func startSystemAudioCapture() async -> Bool {
        do {
            let content: SCShareableContent
            if #available(macOS 14.0, *) {
                content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
            } else {
                content = try await withCheckedThrowingContinuation { cont in
                    SCShareableContent.getExcludingDesktopWindows(false, onScreenWindowsOnly: true) { scContent, scError in
                        if let scError = scError {
                            cont.resume(throwing: scError)
                        } else if let scContent = scContent {
                            cont.resume(returning: scContent)
                        } else {
                            cont.resume(throwing: NSError(domain: "NotesMy", code: -1, userInfo: nil))
                        }
                    }
                }
            }
            guard let display = content.displays.first else {
                print("No display found for ScreenCaptureKit")
                return false
            }

            let filter = SCContentFilter(display: display, excludingWindows: [])
            let config = SCStreamConfiguration()
            config.capturesAudio = true
            config.excludesCurrentProcessAudio = true
            config.sampleRate = 48000
            config.channelCount = 2
            config.width = 64
            config.height = 64
            config.minimumFrameInterval = CMTime(value: 1, timescale: 1)

            let delegate = SystemAudioStreamDelegate()
            self.scStreamDelegate = delegate

            let sysRequest = SFSpeechAudioBufferRecognitionRequest()
            sysRequest.shouldReportPartialResults = true
            sysRequest.addsPunctuation = true
            self.systemRecognitionRequest = sysRequest

            if hasSpeechPermission, let sysRecognizer = systemSpeechRecognizer, sysRecognizer.isAvailable {
                self.systemRecognitionTask = sysRecognizer.recognitionTask(with: sysRequest) { [weak self] result, error in
                    Task { @MainActor [weak self] in
                        guard let self = self, self.isRecording, !self.isPaused else { return }
                        if let result = result {
                            let text = result.bestTranscription.formattedString
                            self.handleSpeechTranscription(text: text, speaker: .remote, isFinal: result.isFinal)
                        }
                    }
                }
            }

            let relay = SystemAudioRelay(request: sysRequest)
            let output = SystemAudioCaptureOutput { [weak self] sampleBuffer in
                // 1. Calculate VU meter level from sample buffer
                let level = calculateSystemAudioLevel(sampleBuffer: sampleBuffer)
                Task { @MainActor [weak self] in
                    guard let self = self, self.isRecording, !self.isPaused else { return }
                    self.systemLevel = level
                }

                // 2. Feed into Speech Recognition
                relay.appendSampleBuffer(sampleBuffer)
            }
            self.scStreamOutput = output

            let stream = SCStream(filter: filter, configuration: config, delegate: delegate)
            try stream.addStreamOutput(output, type: .audio, sampleHandlerQueue: scAudioQueue)
            try await stream.startCapture()

            self.scStream = stream
            self.hasSystemAudioPermission = true
            return true
        } catch {
            print("Failed to start ScreenCaptureKit system audio capture: \(error)")
            self.hasSystemAudioPermission = false
            return false
        }
    }

    // MARK: - Speech Transcription Aggregation
    private func handleSpeechTranscription(text: String, speaker: MeetingSpeaker, isFinal: Bool) {
        let cleanText = filterPhantomSpeech(text)
        guard !cleanText.isEmpty else { return }
        self.activeLiveTranscript = cleanText

        let currentElapsed = self.elapsedSeconds

        // Check if we can append or update existing utterance
        if let lastIndex = transcriptEntries.indices.last,
           transcriptEntries[lastIndex].speaker == speaker,
           !transcriptEntries[lastIndex].isFinal {
            transcriptEntries[lastIndex].text = cleanText
            transcriptEntries[lastIndex].isFinal = isFinal
        } else {
            let entry = MeetingTranscriptEntry(
                timestamp: currentElapsed,
                speaker: speaker,
                text: cleanText,
                isFinal: isFinal
            )
            transcriptEntries.append(entry)
        }
    }

    private func filterPhantomSpeech(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }

        let lowerPunct = trimmed.lowercased().trimmingCharacters(in: CharacterSet(charactersIn: " .,!?-:;\"'"))

        // Common macOS speech recognizer acoustic hallucination tokens when no speech has occurred yet
        let phantomWords: Set<String> = ["evet", "evet evet", "yes", "ıı", "hı", "hıhı", "ee", "e", "şey"]
        if (elapsedSeconds < 4.5 || transcriptEntries.isEmpty) && phantomWords.contains(lowerPunct) {
            return ""
        }

        // If recognizer prepends "Evet, " or "Evet. " or "Evet " to the very beginning of the meeting
        if (elapsedSeconds < 4.0 && transcriptEntries.isEmpty) {
            let lower = trimmed.lowercased()
            if lower.hasPrefix("evet, ") {
                let stripped = String(trimmed.dropFirst(6)).trimmingCharacters(in: .whitespaces)
                return filterPhantomSpeech(stripped)
            } else if lower.hasPrefix("evet. ") {
                let stripped = String(trimmed.dropFirst(6)).trimmingCharacters(in: .whitespaces)
                return filterPhantomSpeech(stripped)
            } else if lower.hasPrefix("evet ") {
                let stripped = String(trimmed.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                return filterPhantomSpeech(stripped)
            }
        }

        return trimmed
    }

    // MARK: - Pause & Resume
    public func pauseMeeting() {
        guard isRecording, !isPaused else { return }
        isPaused = true
        micLevel = 0
        systemLevel = 0
    }

    public func resumeMeeting() {
        guard isRecording, isPaused else { return }
        isPaused = false
    }

    // MARK: - Stop Meeting
    @discardableResult
    public func stopMeeting() -> (metadata: MeetingMetadata, transcript: [MeetingTranscriptEntry], audioURL: URL?, userNotes: String) {
        let meta = MeetingMetadata(
            title: meetingTitle.isEmpty ? defaultMeetingTitle() : meetingTitle,
            date: meetingStartDate ?? Date(),
            duration: elapsedSeconds,
            mode: selectedMode,
            attendees: attendees,
            audioFileURL: currentRecordedURL
        )

        let finalTranscript = transcriptEntries
        let finalURL = currentRecordedURL
        let finalNotes = userNotes

        cleanupAll()

        return (metadata: meta, transcript: finalTranscript, audioURL: finalURL, userNotes: finalNotes)
    }

    // MARK: - Cancel Meeting
    public func cancelMeeting() {
        cleanupAll()
    }

    // MARK: - Cleanup
    private func cleanupAll() {
        timer?.invalidate()
        timer = nil

        // Cleanup Microphone
        if let engine = audioEngine {
            if isMicTapInstalled {
                engine.inputNode.removeTap(onBus: 0)
                isMicTapInstalled = false
            }
            if engine.isRunning {
                engine.stop()
            }
            audioEngine = nil
        }
        micAudioFile = nil

        // Cleanup System Audio Stream
        if let stream = scStream {
            Task {
                try? await stream.stopCapture()
            }
            scStream = nil
            scStreamOutput = nil
            scStreamDelegate = nil
        }

        // Cancel Recognition
        micRecognitionRequest?.endAudio()
        micRecognitionTask?.cancel()
        micRecognitionRequest = nil
        micRecognitionTask = nil

        systemRecognitionRequest?.endAudio()
        systemRecognitionTask?.cancel()
        systemRecognitionRequest = nil
        systemRecognitionTask = nil

        isRecording = false
        isPaused = false
        micLevel = 0
        systemLevel = 0
    }

    // MARK: - Timer
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self, self.isRecording, !self.isPaused else { return }
                self.elapsedSeconds += 1
            }
        }
    }

    public var formattedDuration: String {
        let total = Int(elapsedSeconds)
        let hours = total / 3600
        let mins = (total % 3600) / 60
        let secs = total % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, mins, secs)
        } else {
            return String(format: "%02d:%02d", mins, secs)
        }
    }

    private func defaultMeetingTitle() -> String {
        let dateStr = Date().formatted(date: .abbreviated, time: .shortened)
        let isTR = LocalizationService.shared.language == .turkish
        switch selectedMode {
        case .online:
            return isTR ? "Online Toplantı (\(dateStr))" : "Online Meeting (\(dateStr))"
        case .inPerson:
            return isTR ? "Yüz Yüze Toplantı (\(dateStr))" : "In-Person Meeting (\(dateStr))"
        case .systemOnly:
            return isTR ? "Ekran Sesi Kaydı (\(dateStr))" : "Screen Audio Session (\(dateStr))"
        case .micOnly:
            return isTR ? "Sesli Not (\(dateStr))" : "Voice Memo (\(dateStr))"
        }
    }
}

// MARK: - Helper Function to Compute System Audio RMS Level
private nonisolated func calculateSystemAudioLevel(sampleBuffer: CMSampleBuffer) -> Float {
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

    guard status == noErr else { return 0.0 }

    let buffers = UnsafeMutableAudioBufferListPointer(&audioBufferList)
    var sum: Float = 0
    var count: Int = 0

    for buf in buffers {
        guard let mData = buf.mData else { continue }
        let sampleCount = Int(buf.mDataByteSize) / MemoryLayout<Float>.size
        if sampleCount > 0 {
            let samples = mData.assumingMemoryBound(to: Float.self)
            let step = max(1, sampleCount / 64)
            for i in stride(from: 0, to: sampleCount, by: step) {
                let s = samples[i]
                sum += s * s
                count += 1
            }
        }
    }

    guard count > 0 else { return 0.0 }
    let rms = sqrt(sum / Float(count))
    return min(1.0, rms * 5.0)
}
