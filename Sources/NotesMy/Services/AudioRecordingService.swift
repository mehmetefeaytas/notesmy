import Foundation
import AVFoundation
import Speech

/// Relay to capture audio buffers on CoreAudio's realtime thread without Swift 6 actor-isolation assertion crashes.
private final class AudioTapRelay: @unchecked Sendable {
    private let request: SFSpeechAudioBufferRecognitionRequest
    private let file: AVAudioFile?

    init(request: SFSpeechAudioBufferRecognitionRequest, file: AVAudioFile?) {
        self.request = request
        self.file = file
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
    }
}

/// Installs tap completely outside actor isolation to guarantee no MainActor assertions on CoreAudio thread.
private nonisolated func installRealtimeAudioTap(
    on node: AVAudioNode,
    bus: AVAudioNodeBus,
    format: AVAudioFormat,
    relay: AudioTapRelay
) {
    node.installTap(onBus: bus, bufferSize: 1024, format: format) { buffer, _ in
        relay.appendBuffer(buffer)
    }
}

@MainActor
public final class AudioRecordingService: NSObject, ObservableObject {
    public static let shared = AudioRecordingService()

    @Published public var isRecording: Bool = false
    @Published public var liveTranscript: String = ""
    @Published public var audioMeterLevel: Float = 0.0

    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine: AVAudioEngine?
    private var audioFile: AVAudioFile?
    private var currentRecordedURL: URL?
    private var isTapInstalled: Bool = false

    public override init() {
        super.init()
    }

    public func requestPermissions() async -> Bool {
        let micGranted = await Self.requestMicrophoneAuth()
        let speechGranted = await Self.requestSpeechAuth()
        return micGranted && speechGranted
    }

    nonisolated private static func requestMicrophoneAuth() async -> Bool {
        if #available(macOS 14.0, *) {
            switch AVAudioApplication.shared.recordPermission {
            case .granted:
                return true
            case .denied:
                return false
            case .undetermined:
                return await AVAudioApplication.requestRecordPermission()
            @unknown default:
                return await AVAudioApplication.requestRecordPermission()
            }
        } else {
            return true
        }
    }

    nonisolated private static func requestSpeechAuth() async -> Bool {
        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized:
            return true
        case .denied, .restricted:
            return false
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                SFSpeechRecognizer.requestAuthorization { status in
                    continuation.resume(returning: status == .authorized)
                }
            }
        @unknown default:
            return false
        }
    }

    @discardableResult
    public func startRecording(language: AppLanguage = .english, onTranscription: @escaping @MainActor (String) -> Void) -> Bool {
        _ = stopRecording()

        let locale = Locale(identifier: language.speechLocale)
        var targetRecognizer = SFSpeechRecognizer(locale: locale)

        if targetRecognizer == nil || !targetRecognizer!.isAvailable {
            let fallbackLocale = Locale(identifier: AppLanguage.english.speechLocale)
            targetRecognizer = SFSpeechRecognizer(locale: fallbackLocale)
        }

        self.speechRecognizer = targetRecognizer

        let engine = AVAudioEngine()
        self.audioEngine = engine

        let inputNode = engine.inputNode
        let bus = 0
        let format = inputNode.inputFormat(forBus: bus)

        guard format.sampleRate > 0, format.channelCount > 0 else {
            print("Invalid audio input format: sampleRate=\(format.sampleRate), channels=\(format.channelCount)")
            cleanupEngine()
            return false
        }

        // Create audio output file in attachments directory
        let fileName = "Voice_\(Int(Date().timeIntervalSince1970)).caf"
        let outputURL = NoteStore.shared.attachmentsDirectory.appendingPathComponent(fileName)
        self.currentRecordedURL = outputURL

        var localFile: AVAudioFile?
        do {
            localFile = try AVAudioFile(
                forWriting: outputURL,
                settings: format.settings,
                commonFormat: format.commonFormat,
                interleaved: format.isInterleaved
            )
            self.audioFile = localFile
        } catch {
            print("Failed to initialize AVAudioFile: \(error)")
            self.audioFile = nil
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.addsPunctuation = true
        self.recognitionRequest = request

        if let recognizer = speechRecognizer, recognizer.isAvailable {
            recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
                Task { @MainActor [weak self] in
                    guard let self = self else { return }
                    if let result = result {
                        let text = result.bestTranscription.formattedString
                        self.liveTranscript = text
                        onTranscription(text)
                    }
                    if error != nil || result?.isFinal == true {
                        _ = self.stopRecording()
                    }
                }
            }
        }

        // Safe tap installation via nonisolated top-level function
        let relay = AudioTapRelay(request: request, file: localFile)
        installRealtimeAudioTap(on: inputNode, bus: bus, format: format, relay: relay)
        self.isTapInstalled = true

        engine.prepare()
        do {
            try engine.start()
            isRecording = true
            liveTranscript = ""
            return true
        } catch {
            print("Failed to start AVAudioEngine: \(error)")
            _ = stopRecording()
            return false
        }
    }

    @discardableResult
    public func stopRecording() -> (audioURL: URL?, transcript: String) {
        let finalURL = currentRecordedURL
        let finalTranscript = liveTranscript

        cleanupEngine()

        audioFile = nil
        currentRecordedURL = nil

        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false

        return (audioURL: finalURL, transcript: finalTranscript)
    }

    private func cleanupEngine() {
        if let engine = audioEngine {
            if isTapInstalled {
                engine.inputNode.removeTap(onBus: 0)
                isTapInstalled = false
            }
            if engine.isRunning {
                engine.stop()
            }
            audioEngine = nil
        }
    }
}
