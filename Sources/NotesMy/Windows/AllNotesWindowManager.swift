import AppKit
import SwiftUI

@MainActor
public final class AllNotesWindowManager: NSObject, NSWindowDelegate {
    public static let shared = AllNotesWindowManager()

    private var window: NSWindow?

    public func show(filter: AllNotesWindowView.NoteFilter = .active, viewMode: AllNotesWindowView.ViewMode = .list) {
        if let win = window {
            let allNotesView = AllNotesWindowView(initialFilter: filter, initialViewMode: viewMode)
            win.contentView = NSHostingView(rootView: allNotesView)
            win.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 880, height: 580),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        win.title = "NotesMy — All Notes"
        win.titlebarAppearsTransparent = true
        win.center()
        win.isReleasedWhenClosed = false
        win.setFrameAutosaveName("NotesMyAllNotesWindow")
        win.delegate = self

        let allNotesView = AllNotesWindowView(initialFilter: filter, initialViewMode: viewMode)
        win.contentView = NSHostingView(rootView: allNotesView)

        self.window = win
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    public func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.orderOut(nil)
        return false
    }

    public func windowWillClose(_ notification: Notification) {
        window = nil
    }
}
