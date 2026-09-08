import Foundation
import AVFoundation
import Speech

@MainActor
public final class AudioRecordingService: NSObject, ObservableObject {
    public static let shared = AudioRecordingService()

    @Published public var isRecording: Bool = false
    @Published public var liveTranscript: String = ""
    @Published public var audioMeterLevel: Float = 0.0

    private var audioRecorder: AVAudioRecorder?
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var currentRecordingURL: URL?

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

    public func startRecording(isTurkish: Bool = true, onTranscription: @escaping (String) -> Void) {
        stopRecording()

        let locale = isTurkish ? Locale(identifier: "tr-TR") : Locale(identifier: "en-US")
        speechRecognizer = SFSpeechRecognizer(locale: locale)

        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            print("Speech recognizer is not available for locale: \(locale.identifier)")
            return
        }

        let inputNode = audioEngine.inputNode
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }

        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.addsPunctuation = true

        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
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

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
            isRecording = true
            liveTranscript = ""
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }

    public func stopRecording() {
        guard isRecording else { return }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
    }
}
