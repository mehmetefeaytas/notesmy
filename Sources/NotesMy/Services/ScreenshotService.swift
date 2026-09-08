import Foundation
import AppKit

public final class ScreenshotService: Sendable {
    public static let shared = ScreenshotService()

    private init() {}

    @MainActor
    public func captureInteractiveScreenshot(noteId: UUID) async -> URL? {
        let attachDir = NoteStore.shared.attachmentsDirectory
        let fileName = "Screenshot_\(Int(Date().timeIntervalSince1970)).png"
        let outputURL = attachDir.appendingPathComponent(fileName)

        // Ensure attachments directory exists
        try? FileManager.default.createDirectory(at: attachDir, withIntermediateDirectories: true)

        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-i", "-x", outputURL.path]

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

        if exitCode == 0 && FileManager.default.fileExists(atPath: outputURL.path) {
            return outputURL
        }

        // Fallback: Check if user used Ctrl to copy screenshot to pasteboard
        if let clipImage = NSImage(pasteboard: .general),
           let tiffData = clipImage.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiffData),
           let pngData = bitmap.representation(using: .png, properties: [:]) {
            try? pngData.write(to: outputURL)
            if FileManager.default.fileExists(atPath: outputURL.path) {
                return outputURL
            }
        }

        return nil
    }
}
