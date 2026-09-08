import AppKit
import Carbon

@MainActor
public final class AppDelegate: NSObject, NSApplicationDelegate {
    public func applicationDidFinishLaunching(_ notification: Notification) {
        // Run as accessory app (no clutter in Dock, stays active in menu bar & edge)
        NSApp.setActivationPolicy(.accessory)

        // Initialize Menu Bar
        MenuBarController.shared.setup()

        // Initialize Edge Deck
        EdgeDeckWindowManager.shared.showDeck()

        // Setup Global Hotkeys
        setupGlobalHotkeys()
    }

    private func setupGlobalHotkeys() {
        let optCmd: UInt32 = UInt32(cmdKey | optionKey)
        let ctrlOptCmd: UInt32 = UInt32(cmdKey | optionKey | controlKey)

        // ⌥⌘N -> New Note (ANSI N = 45)
        HotKeyManager.shared.registerHotKey(keyCode: 45, modifiers: optCmd) {
            let note = NoteStore.shared.createNote()
            NoteWindowManager.shared.openNote(id: note.id)
        }

        // ⌥⌘V -> Quick Capture from Clipboard (ANSI V = 9)
        HotKeyManager.shared.registerHotKey(keyCode: 9, modifiers: optCmd) {
            if let note = ClipboardService.shared.captureToNewNote() {
                NoteWindowManager.shared.openNote(id: note.id)
            }
        }

        // ⌥⌘L -> All Notes (ANSI L = 37)
        HotKeyManager.shared.registerHotKey(keyCode: 37, modifiers: optCmd) {
            AllNotesWindowManager.shared.show()
        }

        // ⌥⌘A -> Archive / All Notes (ANSI A = 0)
        HotKeyManager.shared.registerHotKey(keyCode: 0, modifiers: optCmd) {
            AllNotesWindowManager.shared.show()
        }

        // ⌥⌘B -> Sticky Board (ANSI B = 11)
        HotKeyManager.shared.registerHotKey(keyCode: 11, modifiers: optCmd) {
            AllNotesWindowManager.shared.show()
        }

        // ⌃⌥⌘H -> Toggle Deck (ANSI H = 4)
        HotKeyManager.shared.registerHotKey(keyCode: 4, modifiers: ctrlOptCmd) {
            EdgeDeckWindowManager.shared.toggleVisibility()
        }
    }
}
