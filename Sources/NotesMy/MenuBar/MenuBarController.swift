import AppKit
import SwiftUI

@MainActor
public final class MenuBarController: NSObject {
    public static let shared = MenuBarController()

    private var statusItem: NSStatusItem?

    public func setup() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            let image = NSImage(systemSymbolName: "note.text", accessibilityDescription: "NotesMy")
            image?.isTemplate = true
            button.image = image
        }

        buildMenu(for: item)
        self.statusItem = item
    }

    private func buildMenu(for item: NSStatusItem) {
        let menu = NSMenu()

        let newNoteItem = NSMenuItem(title: "New Note", action: #selector(handleNewNote), keyEquivalent: "n")
        newNoteItem.keyEquivalentModifierMask = [.option, .command]
        newNoteItem.target = self
        menu.addItem(newNoteItem)

        let captureItem = NSMenuItem(title: "Quick Capture from Clipboard", action: #selector(handleQuickCapture), keyEquivalent: "v")
        captureItem.keyEquivalentModifierMask = [.option, .command]
        captureItem.target = self
        menu.addItem(captureItem)

        menu.addItem(NSMenuItem.separator())

        let toggleDeckItem = NSMenuItem(title: "Toggle Deck Visibility", action: #selector(handleToggleDeck), keyEquivalent: "h")
        toggleDeckItem.keyEquivalentModifierMask = [.control, .option, .command]
        toggleDeckItem.target = self
        menu.addItem(toggleDeckItem)

        let allNotesItem = NSMenuItem(title: "All Notes & Search...", action: #selector(handleAllNotes), keyEquivalent: "l")
        allNotesItem.keyEquivalentModifierMask = [.option, .command]
        allNotesItem.target = self
        menu.addItem(allNotesItem)

        menu.addItem(NSMenuItem.separator())

        // Recents Submenu
        let recentsMenu = NSMenu()
        let active = NoteStore.shared.activeNotes.prefix(5)
        if active.isEmpty {
            let emptyItem = NSMenuItem(title: "No notes yet", action: nil, keyEquivalent: "")
            emptyItem.isEnabled = false
            recentsMenu.addItem(emptyItem)
        } else {
            for note in active {
                let noteItem = NSMenuItem(title: note.displayTitle, action: #selector(handleOpenRecentNote(_:)), keyEquivalent: "")
                noteItem.representedObject = note.id
                noteItem.target = self
                recentsMenu.addItem(noteItem)
            }
        }
        let recentsMenuItem = NSMenuItem(title: "Recent Notes", action: nil, keyEquivalent: "")
        recentsMenuItem.submenu = recentsMenu
        menu.addItem(recentsMenuItem)

        menu.addItem(NSMenuItem.separator())

        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(handleSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit NotesMy", action: #selector(handleQuit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        item.menu = menu
    }

    @objc private func handleNewNote() {
        let note = NoteStore.shared.createNote()
        NoteWindowManager.shared.openNote(id: note.id)
    }

    @objc private func handleQuickCapture() {
        if let note = ClipboardService.shared.captureToNewNote() {
            NoteWindowManager.shared.openNote(id: note.id)
        }
    }

    @objc private func handleToggleDeck() {
        EdgeDeckWindowManager.shared.toggleVisibility()
    }

    @objc private func handleAllNotes() {
        AllNotesWindowManager.shared.show()
    }

    @objc private func handleOpenRecentNote(_ sender: NSMenuItem) {
        if let id = sender.representedObject as? UUID {
            NoteWindowManager.shared.openNote(id: id)
        }
    }

    @objc private func handleSettings() {
        SettingsWindowManager.shared.show()
    }

    @objc private func handleQuit() {
        NSApp.terminate(nil)
    }
}
