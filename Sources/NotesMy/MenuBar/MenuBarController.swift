import AppKit
import SwiftUI

@MainActor
public final class MenuBarController: NSObject, NSMenuDelegate {
    public static let shared = MenuBarController()

    private var statusItem: NSStatusItem?
    private var mainMenu: NSMenu?

    public func setup() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            let image = NSImage(systemSymbolName: "note.text", accessibilityDescription: "NotesMy")
            image?.isTemplate = true
            button.image = image
        }

        let menu = NSMenu()
        menu.delegate = self
        self.mainMenu = menu
        item.menu = menu
        self.statusItem = item
    }

    public func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        buildMenuItems(into: menu)
    }

    private func buildMenuItems(into menu: NSMenu) {
        let isTR = LocalizationService.shared.language == .turkish

        // 1. Open Main Window (Prominent at top)
        let allNotesItem = NSMenuItem(
            title: isTR ? "📋 Ana Pencere & Arama..." : "📋 Open Main Dashboard & Search...",
            action: #selector(handleAllNotes),
            keyEquivalent: "l"
        )
        allNotesItem.keyEquivalentModifierMask = [.option, .command]
        allNotesItem.target = self
        menu.addItem(allNotesItem)

        // 2. New Note
        let newNoteItem = NSMenuItem(
            title: isTR ? "➕ Yeni Not" : "➕ New Note",
            action: #selector(handleNewNote),
            keyEquivalent: "n"
        )
        newNoteItem.keyEquivalentModifierMask = [.option, .command]
        newNoteItem.target = self
        menu.addItem(newNoteItem)

        // 3. Screen OCR
        let screenOCRItem = NSMenuItem(
            title: isTR ? "🔍 Ekrandan Metin Yakala (OCR)..." : "🔍 Capture Screen Text (OCR)...",
            action: #selector(handleScreenOCR),
            keyEquivalent: ""
        )
        screenOCRItem.target = self
        menu.addItem(screenOCRItem)

        // 4. Meeting Studio & AI Intelligence
        let meetingService = MeetingRecordingService.shared
        if meetingService.isRecording {
            let recordingItem = NSMenuItem(
                title: isTR ? "🔴 Toplantı Kaydediliyor (\(meetingService.formattedDuration))..." : "🔴 Meeting Recording Active (\(meetingService.formattedDuration))...",
                action: #selector(handleOpenMeetingStudio),
                keyEquivalent: ""
            )
            recordingItem.target = self
            menu.addItem(recordingItem)
        }

        let meetingItem = NSMenuItem(
            title: isTR ? "🎙️ Toplantı Modu: Kaydet & Özetle..." : "🎙️ Meeting Studio: Record & AI Recap...",
            action: #selector(handleOpenMeetingStudio),
            keyEquivalent: "m"
        )
        meetingItem.keyEquivalentModifierMask = [.option, .command]
        meetingItem.target = self
        menu.addItem(meetingItem)

        menu.addItem(NSMenuItem.separator())

        let captureItem = NSMenuItem(title: isTR ? "Panoyu Not Olarak Yakala" : "Quick Capture from Clipboard", action: #selector(handleQuickCapture), keyEquivalent: "v")
        captureItem.keyEquivalentModifierMask = [.option, .command]
        captureItem.target = self
        menu.addItem(captureItem)

        // Clipboard History Submenu (Unclutter inspired)
        let clipboardMenu = NSMenu()
        let history = NoteStore.shared.clipboardHistory
        if history.isEmpty {
            let empty = NSMenuItem(title: isTR ? "Pano geçmişi boş" : "No clipboard history", action: nil, keyEquivalent: "")
            empty.isEnabled = false
            clipboardMenu.addItem(empty)
        } else {
            for snippet in history.prefix(5) {
                let title = String(snippet.prefix(35))
                let item = NSMenuItem(title: "+ Note: \"\(title)...\"", action: #selector(handleCreateFromClipboardSnippet(_:)), keyEquivalent: "")
                item.representedObject = snippet
                item.target = self
                clipboardMenu.addItem(item)
            }
        }
        let clipboardMenuItem = NSMenuItem(title: isTR ? "Pano Geçmişi Merkezi" : "Clipboard History Hub", action: nil, keyEquivalent: "")
        clipboardMenuItem.submenu = clipboardMenu
        menu.addItem(clipboardMenuItem)

        menu.addItem(NSMenuItem.separator())

        let toggleDeckItem = NSMenuItem(title: isTR ? "Kenar Çekmecesini Aç/Kapat" : "Toggle Deck Visibility", action: #selector(handleToggleDeck), keyEquivalent: "h")
        toggleDeckItem.keyEquivalentModifierMask = [.control, .option, .command]
        toggleDeckItem.target = self
        menu.addItem(toggleDeckItem)

        let boardItem = NSMenuItem(title: isTR ? "📌 Mantar Pano (Sticky Board)..." : "📌 Sticky Board Canvas...", action: #selector(handleStickyBoard), keyEquivalent: "b")
        boardItem.keyEquivalentModifierMask = [.option, .command]
        boardItem.target = self
        menu.addItem(boardItem)

        let graphItem = NSMenuItem(title: isTR ? "🕸️ Bilgi Grafiği (Knowledge Graph)..." : "🕸️ Knowledge Graph...", action: #selector(handleKnowledgeGraph), keyEquivalent: "g")
        graphItem.keyEquivalentModifierMask = [.option, .command]
        graphItem.target = self
        menu.addItem(graphItem)

        menu.addItem(NSMenuItem.separator())

        // Favorites Submenu
        let favorites = NoteStore.shared.favoriteNotes
        if !favorites.isEmpty {
            let favMenu = NSMenu()
            for note in favorites.prefix(5) {
                let item = NSMenuItem(title: "⭐ \(note.displayTitle)", action: #selector(handleOpenRecentNote(_:)), keyEquivalent: "")
                item.representedObject = note.id
                item.target = self
                favMenu.addItem(item)
            }
            let favMenuItem = NSMenuItem(title: "Favorites", action: nil, keyEquivalent: "")
            favMenuItem.submenu = favMenu
            menu.addItem(favMenuItem)
        }

        // Recents Submenu
        let recentsMenu = NSMenu()
        let active = NoteStore.shared.activeNotes.prefix(5)
        if active.isEmpty {
            let emptyItem = NSMenuItem(title: "No notes yet", action: nil, keyEquivalent: "")
            emptyItem.isEnabled = false
            recentsMenu.addItem(emptyItem)
        } else {
            for note in active {
                let noteItem = NSMenuItem(title: "\(note.category): \(note.displayTitle)", action: #selector(handleOpenRecentNote(_:)), keyEquivalent: "")
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

        let updateItem = NSMenuItem(
            title: isTR ? "🔄 Güncellemeleri Denetle..." : "🔄 Check for Updates...",
            action: #selector(handleCheckForUpdates),
            keyEquivalent: ""
        )
        updateItem.target = self
        menu.addItem(updateItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit NotesMy", action: #selector(handleQuit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
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

    @objc private func handleScreenOCR() {
        Task {
            _ = await OCRService.shared.captureScreenAndExtractText()
        }
    }

    @objc private func handleOpenMeetingStudio() {
        MeetingStudioWindowManager.shared.show()
    }

    @objc private func handleStickyBoard() {
        AllNotesWindowManager.shared.show(viewMode: .board)
    }

    @objc private func handleKnowledgeGraph() {
        AllNotesWindowManager.shared.show(viewMode: .graph)
    }

    @objc private func handleCreateFromClipboardSnippet(_ sender: NSMenuItem) {
        if let text = sender.representedObject as? String {
            let note = NoteStore.shared.createNote(
                title: String(text.prefix(30)),
                body: text,
                color: .amber
            )
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

    @objc private func handleCheckForUpdates() {
        SettingsWindowManager.shared.show()
        Task {
            await UpdateService.shared.checkForUpdates(isUserInitiated: true)
        }
    }

    @objc private func handleQuit() {
        NSApp.terminate(nil)
    }
}
