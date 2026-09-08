import AppKit
import SwiftUI

@MainActor
public final class AllNotesWindowManager: NSObject, NSWindowDelegate {
    public static let shared = AllNotesWindowManager()

    private var window: NSWindow?

    public func show(filter: AllNotesWindowView.NoteFilter = .active, viewMode: AllNotesWindowView.ViewMode = .list) {
        let targetScreen = NSScreen.screens.first(where: { $0.localizedName.contains("DELL") }) ?? NSScreen.main ?? NSScreen.screens.first ?? NSScreen()
        let sFrame = targetScreen.visibleFrame

        if let win = window {
            let width: CGFloat = min(980, sFrame.width - 80)
            let height: CGFloat = min(660, sFrame.height - 80)
            let x = sFrame.midX - (width / 2)
            let y = sFrame.midY - (height / 2)
            win.setFrame(NSRect(x: x, y: y, width: width, height: height), display: true)

            let allNotesView = AllNotesWindowView(initialFilter: filter, initialViewMode: viewMode)
            win.contentView = NSHostingView(rootView: allNotesView)
            win.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let width: CGFloat = min(980, sFrame.width - 80)
        let height: CGFloat = min(660, sFrame.height - 80)
        let x = sFrame.midX - (width / 2)
        let y = sFrame.midY - (height / 2)

        let win = NSWindow(
            contentRect: NSRect(x: x, y: y, width: width, height: height),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        win.title = "NotesMy — All Notes"
        win.titlebarAppearsTransparent = true
        win.setFrame(NSRect(x: x, y: y, width: width, height: height), display: true)
        win.isReleasedWhenClosed = false
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
