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
        panel.isFloatingPanel = note.isPinned
        panel.level = note.isPinned ? .floating : .normal
        panel.isMovableByWindowBackground = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.alphaValue = CGFloat(max(0.25, min(1.0, note.opacity)))
        panel.hasShadow = true
        panel.hidesOnDeactivate = false
        panel.delegate = self
        panel.minSize = NSSize(width: 320, height: 260)
        panel.maxSize = NSSize(width: 900, height: 1200)

        let editorView = NoteEditorView(noteId: id, store: NoteStore.shared) { [weak self, weak panel] in
            DispatchQueue.main.async {
                panel?.close()
                self?.activePanels.removeValue(forKey: id)
            }
        }

        panel.contentView = NSHostingView(rootView: editorView)

        let screen = targetScreen ?? NSScreen.main ?? NSScreen.screens.first ?? NSScreen()
        let screenFrame = screen.visibleFrame

        var x: CGFloat = screenFrame.maxX - defaultWidth - 280
        var y: CGFloat = screenFrame.midY - (defaultHeight / 2)

        if NoteStore.shared.dockSide == .left {
            x = screenFrame.minX + 280
        } else if NoteStore.shared.dockSide == .bottom {
            y = screenFrame.minY + 120
        }

        // Restore saved window position if exists and within screen bounds
        if let wx = note.windowX, let wy = note.windowY {
            x = CGFloat(wx)
            y = CGFloat(wy)
        }

        // Guarantee window is always fully visible within screen margins (prevents bugging out on right edge or jumping to top-left)
        x = max(screenFrame.minX + 20, min(x, screenFrame.maxX - defaultWidth - 20))
        y = max(screenFrame.minY + 20, min(y, screenFrame.maxY - defaultHeight - 20))

        panel.setFrame(NSRect(x: x, y: y, width: defaultWidth, height: defaultHeight), display: true)

        activePanels[id] = panel
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    public func updatePin(id: UUID, isPinned: Bool) {
        if let panel = activePanels[id] {
            panel.isFloatingPanel = isPinned
            panel.level = isPinned ? .floating : .normal
            if isPinned {
                panel.orderFront(nil)
            }
        }
    }

    public func updateOpacity(id: UUID, opacity: Double) {
        if let panel = activePanels[id] {
            panel.alphaValue = CGFloat(max(0.25, min(1.0, opacity)))
        }
    }

    public func closeNote(id: UUID) {
        if let panel = activePanels[id] {
            DispatchQueue.main.async {
                panel.close()
                self.activePanels.removeValue(forKey: id)
            }
        }
    }

    public func windowDidMove(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        for (id, panel) in activePanels where panel == window {
            let frame = window.frame
            if let screen = window.screen {
                let sFrame = screen.visibleFrame
                let safeX = max(sFrame.minX + 20, min(frame.minX, sFrame.maxX - frame.width - 20))
                let safeY = max(sFrame.minY + 20, min(frame.minY, sFrame.maxY - frame.height - 20))
                if var note = NoteStore.shared.notes.first(where: { $0.id == id }) {
                    note.windowX = Double(safeX)
                    note.windowY = Double(safeY)
                    NoteStore.shared.updateNote(note)
                }
            }
            break
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
