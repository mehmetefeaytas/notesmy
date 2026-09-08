import Foundation
import AppKit

public final class WebClipperService: @unchecked Sendable {
    public static let shared = WebClipperService()

    private init() {}

    @MainActor
    public func clipCurrentURLFromPasteboard() -> NoteItem? {
        guard let urlString = NSPasteboard.general.string(forType: .string)?.trimmingCharacters(in: .whitespacesAndNewlines),
              let url = URL(string: urlString) else {
            return nil
        }
        return clipURL(url)
    }

    @MainActor
    public func clipURL(_ url: URL) -> NoteItem? {
        guard url.scheme == "http" || url.scheme == "https" else {
            return nil
        }

        let urlString = url.absoluteString
        let host = url.host ?? "Web"
        let title = "Web Clip: \(host)"
        let body = """
        ## 🌐 \(title)
        **Source URL:** [\(urlString)](\(urlString))
        **Clipped on:** \(Date().formatted(date: .abbreviated, time: .shortened))

        ### 📌 Notes & Summary
        - 

        ### ✅ Action Items
        - [ ] Review web article
        """

        let note = NoteStore.shared.createNote(
            title: title,
            body: body,
            color: .sky,
            category: "Ideas"
        )
        return note
    }
}
