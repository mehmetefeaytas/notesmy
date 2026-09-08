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

        // Initialize Menu Bar
        MenuBarController.shared.setup()

        // Initialize Edge Deck
        EdgeDeckWindowManager.shared.showDeck()

        // Setup Global Hotkeys
        setupGlobalHotkeys()
    }

    public func setupGlobalHotkeys() {
        HotKeyManager.shared.unregisterAll()

        let mod = NoteStore.shared.hotkeyModifier.carbonModifier
        let ctrlOptCmd: UInt32 = UInt32(cmdKey | optionKey | controlKey)

        // New Note (ANSI N = 45)
        HotKeyManager.shared.registerHotKey(keyCode: 45, modifiers: mod) {
            let note = NoteStore.shared.createNote()
            NoteWindowManager.shared.openNote(id: note.id)
        }

        // Quick Capture from Clipboard (ANSI V = 9)
        HotKeyManager.shared.registerHotKey(keyCode: 9, modifiers: mod) {
            if let note = ClipboardService.shared.captureToNewNote() {
                NoteWindowManager.shared.openNote(id: note.id)
            }
        }

        // All Notes & Search (ANSI L = 37)
        HotKeyManager.shared.registerHotKey(keyCode: 37, modifiers: mod) {
            AllNotesWindowManager.shared.show()
        }

        // Archive (ANSI A = 0)
        HotKeyManager.shared.registerHotKey(keyCode: 0, modifiers: mod) {
            AllNotesWindowManager.shared.show()
        }

        // Sticky Board (ANSI B = 11)
        HotKeyManager.shared.registerHotKey(keyCode: 11, modifiers: mod) {
            AllNotesWindowManager.shared.show()
        }

        // Toggle Deck (ANSI H = 4)
        HotKeyManager.shared.registerHotKey(keyCode: 4, modifiers: ctrlOptCmd) {
            EdgeDeckWindowManager.shared.toggleVisibility()
        }
    }
}
