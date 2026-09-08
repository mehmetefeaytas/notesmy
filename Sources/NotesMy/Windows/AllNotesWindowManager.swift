import AppKit
import SwiftUI

@MainActor
public final class AllNotesWindowManager: NSObject, NSWindowDelegate {
    public static let shared = AllNotesWindowManager()

    private var window: NSWindow?

    public func show() {
        if let win = window {
            win.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 540),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        win.title = "NotesMy — All Notes"
        win.titlebarAppearsTransparent = true
        win.center()
        win.setFrameAutosaveName("NotesMyAllNotesWindow")
        win.delegate = self

        let allNotesView = AllNotesWindowView()
        win.contentView = NSHostingView(rootView: allNotesView)

        self.window = win
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    public func windowWillClose(_ notification: Notification) {
        window = nil
    }
}
