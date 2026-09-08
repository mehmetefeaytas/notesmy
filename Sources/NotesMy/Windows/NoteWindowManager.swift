import AppKit
import SwiftUI

// Custom NSPanel subclass that allows keyboard input even without a titlebar
public final class KeyableNotePanel: NSPanel {
    public override var canBecomeKey: Bool { true }
    public override var canBecomeMain: Bool { true }
}

@MainActor
public final class NoteWindowManager: NSObject, NSWindowDelegate {
    public static let shared = NoteWindowManager()

    private var activePanels: [UUID: KeyableNotePanel] = [:]

    public func openNote(id: UUID, on targetScreen: NSScreen? = nil) {
        // If already open, bring to front and focus
        if let existing = activePanels[id] {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        guard let note = NoteStore.shared.notes.first(where: { $0.id == id }) else { return }

        let defaultWidth: CGFloat = 380
        let defaultHeight: CGFloat = 420

        let panel = KeyableNotePanel(
            contentRect: NSRect(x: 0, y: 0, width: defaultWidth, height: defaultHeight),
            styleMask: [.borderless, .resizable],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.isMovableByWindowBackground = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.hidesOnDeactivate = false
        panel.delegate = self
        panel.minSize = NSSize(width: 320, height: 260)
        panel.maxSize = NSSize(width: 900, height: 1200)

        let editorView = NoteEditorView(noteId: id, store: NoteStore.shared) { [weak self, weak panel] in
            panel?.close()
            self?.activePanels.removeValue(forKey: id)
        }

        panel.contentView = NSHostingView(rootView: editorView)

        let screen = targetScreen ?? NSScreen.main ?? NSScreen.screens[0]
        let screenFrame = screen.visibleFrame

        var x: CGFloat = screenFrame.maxX - defaultWidth - 280
        var y: CGFloat = screenFrame.midY - (defaultHeight / 2)

        if NoteStore.shared.dockSide == .left {
            x = screenFrame.minX + 280
        } else if NoteStore.shared.dockSide == .bottom {
            y = screenFrame.minY + 120
        }

        // Restore saved pinned position if exists
        if let px = note.pinnedX, let py = note.pinnedY {
            x = CGFloat(px)
            y = CGFloat(py)
        }

        panel.setFrame(NSRect(x: x, y: y, width: defaultWidth, height: defaultHeight), display: true)

        activePanels[id] = panel
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    public func closeNote(id: UUID) {
        if let panel = activePanels[id] {
            panel.close()
            activePanels.removeValue(forKey: id)
        }
    }

    public func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            for (id, panel) in activePanels where panel == window {
                activePanels.removeValue(forKey: id)
                break
            }
        }
    }
}
