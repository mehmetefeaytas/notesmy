import AppKit
import SwiftUI

@MainActor
public final class NoteWindowManager: NSObject, NSWindowDelegate {
    public static let shared = NoteWindowManager()

    private var activePanels: [UUID: NSPanel] = [:]

    public func openNote(id: UUID) {
        // If already open, bring to front
        if let existing = activePanels[id] {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        guard let note = NoteStore.shared.notes.first(where: { $0.id == id }) else { return }

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 400),
            styleMask: [.borderless, .nonactivatingPanel],
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

        let editorView = NoteEditorView(noteId: id, store: NoteStore.shared) { [weak self, weak panel] in
            panel?.close()
            self?.activePanels.removeValue(forKey: id)
        }

        panel.contentView = NSHostingView(rootView: editorView)

        // Calculate initial placement
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let defaultWidth: CGFloat = 360
            let defaultHeight: CGFloat = 400

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
        }

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
