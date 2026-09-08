import Foundation
import AVFoundation
import Speech

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

    public override init() {
        super.init()
    }

    public func requestPermissions() async -> Bool {
        let audioPermission: Bool
        if #available(macOS 14.0, *) {
            audioPermission = await AVAudioApplication.requestRecordPermission()
        } else {
            audioPermission = true
        }

        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }

        return audioPermission && speechStatus
    }

    public func startRecording(language: AppLanguage = .english, onTranscription: @escaping (String) -> Void) {
        stopRecording()

        // Verify speech recognition authorization
        let authStatus = SFSpeechRecognizer.authorizationStatus()
        guard authStatus == .authorized || authStatus == .notDetermined else {
            print("Speech recognition not authorized (status: \(authStatus.rawValue))")
            return
        }

        // Initialize recognizer with requested locale, with fallback to en-US
        let locale = Locale(identifier: language.speechLocale)
        var targetRecognizer = SFSpeechRecognizer(locale: locale)

        if targetRecognizer == nil || !targetRecognizer!.isAvailable {
            let fallbackLocale = Locale(identifier: AppLanguage.english.speechLocale)
            targetRecognizer = SFSpeechRecognizer(locale: fallbackLocale)
        }

        guard let recognizer = targetRecognizer, recognizer.isAvailable else {
            print("Speech recognizer unavailable for \(language.displayName)")
            return
        }
        self.speechRecognizer = recognizer

        let engine = AVAudioEngine()
        self.audioEngine = engine

        let inputNode = engine.inputNode
        let bus = 0
        let format = inputNode.inputFormat(forBus: bus)

        guard format.sampleRate > 0, format.channelCount > 0 else {
            print("Invalid audio input format: sampleRate=\(format.sampleRate), channels=\(format.channelCount)")
            return
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.addsPunctuation = true
        self.recognitionRequest = request

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor [weak self] in
                if let result = result {
                    let text = result.bestTranscription.formattedString
                    self?.liveTranscript = text
                    onTranscription(text)
                }
                if error != nil || result?.isFinal == true {
                    self?.stopRecording()
                }
            }
        }

        inputNode.installTap(onBus: bus, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        engine.prepare()
        do {
            try engine.start()
            isRecording = true
            liveTranscript = ""
        } catch {
            print("Failed to start AVAudioEngine: \(error)")
            stopRecording()
        }
    }

    public func stopRecording() {
        guard isRecording || audioEngine != nil else { return }

        if let engine = audioEngine {
            if engine.isRunning {
                engine.stop()
            }
            engine.inputNode.removeTap(onBus: 0)
            audioEngine = nil
        }

        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
    }
}
