import Foundation
import Vision
import AppKit

public final class OCRService: Sendable {
    public static let shared = OCRService()

    private init() {}

    public func extractText(from imageURL: URL) async -> String {
        guard let image = NSImage(contentsOf: imageURL),
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return ""
        }

        return await extractText(from: cgImage)
    }

    public func extractText(from cgImage: CGImage) async -> String {
        await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                guard error == nil, let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }

                let recognizedStrings = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }
                continuation.resume(returning: recognizedStrings.joined(separator: "\n"))
            }

            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["tr-TR", "en-US"]
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: "")
            }
        }
    }

    /// Interactive screen OCR: User draws a rectangle on screen, text is extracted and copied to system clipboard
    @MainActor
    public func captureScreenAndExtractText() async -> String {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("notesmy_ocr_\(Int(Date().timeIntervalSince1970)).png")

        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-i", "-x", tempURL.path]

        let exitCode: Int32 = await withCheckedContinuation { continuation in
            task.terminationHandler = { process in
                continuation.resume(returning: process.terminationStatus)
            }
            do {
                try task.run()
            } catch {
                continuation.resume(returning: -1)
            }
        }

        guard exitCode == 0 && FileManager.default.fileExists(atPath: tempURL.path) else {
            // Check if user copied to clipboard during screencapture (with Ctrl)
            if let clipImage = NSImage(pasteboard: .general),
               let cgImage = clipImage.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                let text = await extractText(from: cgImage)
                if !text.isEmpty {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(text, forType: .string)
                }
                return text
            }
            return ""
        }

        defer {
            try? FileManager.default.removeItem(at: tempURL)
        }

        let extracted = await extractText(from: tempURL)
        if !extracted.isEmpty {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(extracted, forType: .string)
        }
        return extracted
    }
}
