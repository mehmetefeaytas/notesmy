import AppKit
import SwiftUI

@MainActor
public final class MeetingStudioWindowManager: NSObject, NSWindowDelegate {
    public static let shared = MeetingStudioWindowManager()

    private var window: NSWindow?

    public func show() {
        if let existing = window {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let contentView = MeetingStudioView()
        let hostingView = NSHostingView(rootView: contentView)

        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 920, height: 680),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        win.title = LocalizationService.shared.language == .turkish ? "NotesMy Toplantı Stüdyosu & EA Zekası" : "NotesMy Meeting Studio & AI Intelligence"
        win.titlebarAppearsTransparent = true
        win.titleVisibility = .hidden
        win.isMovableByWindowBackground = true
        win.minSize = NSSize(width: 780, height: 560)
        win.contentView = hostingView
        win.delegate = self
        win.center()
        win.setFrameAutosaveName("NotesMyMeetingStudioWindow")

        self.window = win
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    public func close() {
        window?.close()
        window = nil
    }

    public func windowWillClose(_ notification: Notification) {
        window = nil
    }
}
