import AppKit
import Carbon

public enum HotKeyModifierOption: String, CaseIterable, Identifiable, Codable {
    case optionCommand = "⌥⌘ Option + Command"
    case controlOption = "⌃⌥ Control + Option"
    case commandShift = "⇧⌘ Shift + Command"

    public var id: String { rawValue }

    public var prefix: String {
        switch self {
        case .optionCommand: return "⌥⌘"
        case .controlOption: return "⌃⌥"
        case .commandShift:  return "⇧⌘"
        }
    }

    public var carbonModifier: UInt32 {
        switch self {
        case .optionCommand: return UInt32(cmdKey | optionKey)
        case .controlOption: return UInt32(controlKey | optionKey)
        case .commandShift:  return UInt32(cmdKey | shiftKey)
        }
    }
}

@MainActor
public final class AppDelegate: NSObject, NSApplicationDelegate {
    public static private(set) var shared: AppDelegate?

    public func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self

        // Run as accessory app (no clutter in Dock, stays active in menu bar & edge)
        NSApp.setActivationPolicy(.accessory)

        // Setup standard main menu so Cmd+C, Cmd+V, Cmd+X, Cmd+A work properly in accessory app
        setupMainMenu()

        // Initialize Menu Bar
        MenuBarController.shared.setup()

        // Initialize Edge Deck
        EdgeDeckWindowManager.shared.showDeck()

        // Setup Global Hotkeys
        setupGlobalHotkeys()
    }

    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    private func setupMainMenu() {
        let mainMenu = NSMenu()

        // Application Menu
        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "Quit NotesMy", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)

        // Edit Menu (Essential for Cut / Copy / Paste / Undo / Redo in .accessory apps)
        let editMenuItem = NSMenuItem()
        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(withTitle: "Undo", action: Selector(("undo:")), keyEquivalent: "z")
        let redoItem = NSMenuItem(title: "Redo", action: Selector(("redo:")), keyEquivalent: "Z")
        redoItem.keyEquivalentModifierMask = [.command, .shift]
        editMenu.addItem(redoItem)
        editMenu.addItem(NSMenuItem.separator())
        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        editMenuItem.submenu = editMenu
        mainMenu.addItem(editMenuItem)

        NSApp.mainMenu = mainMenu
    }

    public func setupGlobalHotkeys() {
        HotKeyManager.shared.unregisterAll()

        let store = NoteStore.shared

        // New Note
        let newNoteKey = store.hotKey(for: .newNote)
        HotKeyManager.shared.registerHotKey(keyCode: newNoteKey.keyCode, modifiers: newNoteKey.modifiers) {
            let note = NoteStore.shared.createNote()
            NoteWindowManager.shared.openNote(id: note.id)
        }

        // Quick Capture from Clipboard
        let quickCaptureKey = store.hotKey(for: .quickCapture)
        HotKeyManager.shared.registerHotKey(keyCode: quickCaptureKey.keyCode, modifiers: quickCaptureKey.modifiers) {
            if let note = ClipboardService.shared.captureToNewNote() {
                NoteWindowManager.shared.openNote(id: note.id)
            }
        }

        // All Notes & Search
        let allNotesKey = store.hotKey(for: .allNotes)
        HotKeyManager.shared.registerHotKey(keyCode: allNotesKey.keyCode, modifiers: allNotesKey.modifiers) {
            AllNotesWindowManager.shared.show()
        }

        // Archive
        let archiveKey = store.hotKey(for: .archive)
        HotKeyManager.shared.registerHotKey(keyCode: archiveKey.keyCode, modifiers: archiveKey.modifiers) {
            AllNotesWindowManager.shared.show(filter: .archived)
        }

        // Sticky Board
        let stickyBoardKey = store.hotKey(for: .stickyBoard)
        HotKeyManager.shared.registerHotKey(keyCode: stickyBoardKey.keyCode, modifiers: stickyBoardKey.modifiers) {
            AllNotesWindowManager.shared.show()
        }

        // Toggle Deck
        let toggleDeckKey = store.hotKey(for: .toggleDeck)
        HotKeyManager.shared.registerHotKey(keyCode: toggleDeckKey.keyCode, modifiers: toggleDeckKey.modifiers) {
            EdgeDeckWindowManager.shared.toggleVisibility()
        }
    }
}
