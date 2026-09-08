import Foundation
import AppKit

public final class ScreenshotService: Sendable {
    public static let shared = ScreenshotService()

    private init() {}

    @MainActor
    public func captureInteractiveScreenshot(noteId: UUID) async -> URL? {
        let attachDir = NoteStore.shared.attachmentsDirectory
        let fileName = "Screenshot_\(Date().timeIntervalSince1970).png"
        let outputURL = attachDir.appendingPathComponent(fileName)

        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-i", outputURL.path]

        return await withCheckedContinuation { continuation in
            task.terminationHandler = { process in
                if process.terminationStatus == 0 && FileManager.default.fileExists(atPath: outputURL.path) {
                    continuation.resume(returning: outputURL)
                } else {
                    continuation.resume(returning: nil)
                }
            }
            do {
                try task.run()
            } catch {
                continuation.resume(returning: nil)
            }
        }
    }
}
