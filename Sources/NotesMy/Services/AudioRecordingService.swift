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
    private var audioFile: AVAudioFile?
    private var currentRecordedURL: URL?

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
            return await AVAudioApplication.requestRecordPermission()
        } else {
            return true
        }
    }

    nonisolated private static func requestSpeechAuth() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
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

        // Capture local references safely outside of actor isolation for real-time audio tap
        let localRequest = request
        inputNode.installTap(onBus: bus, bufferSize: 1024, format: format) { buffer, _ in
            localRequest.append(buffer)
            try? localFile?.write(from: buffer)
        }

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

        if let engine = audioEngine {
            if engine.isRunning {
                engine.stop()
            }
            engine.inputNode.removeTap(onBus: 0)
            audioEngine = nil
        }

        audioFile = nil
        currentRecordedURL = nil

        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false

        return (audioURL: finalURL, transcript: finalTranscript)
    }
}
