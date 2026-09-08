import Foundation
import AppKit

public final class ClipboardService: Sendable {
    public static let shared = ClipboardService()

    @MainActor
    public func captureToNewNote() -> NoteItem? {
        let pasteboard = NSPasteboard.general
        guard let items = pasteboard.pasteboardItems, let first = items.first else {
            return nil
        }

        // Try text first
        if let string = first.string(forType: .string), !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let lines = string.components(separatedBy: .newlines)
            let title = lines.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Quick Capture"
            let rest = lines.dropFirst().joined(separator: "\n")
            let note = NoteStore.shared.createNote(
                title: String(title.prefix(50)),
                body: rest.isEmpty ? string : rest,
                color: .amber
            )
            return note
        }

        return nil
    }
}
