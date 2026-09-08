import Foundation
import SwiftUI
import Combine
import AppKit

public enum DockSide: String, Codable, CaseIterable, Identifiable, Sendable {
    case right = "Right Edge"
    case left = "Left Edge"
    case bottom = "Bottom Edge"

    public var id: String { rawValue }
}

@MainActor
public final class NoteStore: ObservableObject {
    public static let shared = NoteStore()

    @Published public var notes: [NoteItem] = []
    @Published public var selectedNoteId: UUID?
    @Published public var isDeckVisible: Bool = true
    @Published public var isDeckHovered: Bool = false
    @Published public var dockSide: DockSide = .right
    @Published public var activationDelay: Double = 0.08
    @Published public var showOverFullScreen: Bool = true
    @Published public var recentlyDeletedNote: NoteItem? = nil

    // Appearance settings
    @Published public var selectedFont: FontFamilyOption = .modern
    @Published public var fontSize: CGFloat = 13
    @Published public var cardSize: CardSizeOption = .standard

    // Categories & Collections (SideNotes feature)
    @Published public var categories: [String] = ["General", "Work", "Personal", "Code", "Ideas"]
    @Published public var selectedCategory: String = "All"

    // Clipboard History Hub (Unclutter feature)
    @Published public var clipboardHistory: [String] = []
    private var lastPasteboardChangeCount: Int = 0
    private var clipboardTimer: Timer?

    private var saveCancellable: AnyCancellable?
    private let fileManager = FileManager.default

    private var storageDirectory: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let notesDir = appSupport.appendingPathComponent("NotesMy", isDirectory: true)
        if !fileManager.fileExists(atPath: notesDir.path) {
            try? fileManager.createDirectory(at: notesDir, withIntermediateDirectories: true)
        }
        return notesDir
    }

    public var attachmentsDirectory: URL {
        let attachDir = storageDirectory.appendingPathComponent("Attachments", isDirectory: true)
        if !fileManager.fileExists(atPath: attachDir.path) {
            try? fileManager.createDirectory(at: attachDir, withIntermediateDirectories: true)
        }
        return attachDir
    }

    private var storageFileURL: URL {
        storageDirectory.appendingPathComponent("notes.json")
    }

    private var settingsFileURL: URL {
        storageDirectory.appendingPathComponent("settings.json")
    }

    public init() {
        loadSettings()
        loadNotes()

        if notes.isEmpty {
            createSampleNotes()
        }

        // Auto-save debounce
        $notes
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveNotes()
            }
            .store(in: &cancellables)

        startClipboardMonitor()
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Clipboard History Monitor

    private func startClipboardMonitor() {
        lastPasteboardChangeCount = NSPasteboard.general.changeCount
        // Poll pasteboard every 1.5 seconds unobtrusively
        clipboardTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkPasteboard()
            }
        }
    }

    private func checkPasteboard() {
        let currentCount = NSPasteboard.general.changeCount
        guard currentCount != lastPasteboardChangeCount else { return }
        lastPasteboardChangeCount = currentCount

        if let string = NSPasteboard.general.string(forType: .string),
           !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let clean = string.trimmingCharacters(in: .whitespacesAndNewlines)
            if !clipboardHistory.contains(clean) {
                clipboardHistory.insert(clean, at: 0)
                if clipboardHistory.count > 10 {
                    clipboardHistory.removeLast()
                }
            }
        }
    }

    // MARK: - Computed Properties

    public var activeNotes: [NoteItem] {
        notes.filter { !$0.isArchived }
            .sorted(by: { $0.updatedAt > $1.updatedAt })
    }

    public func activeNotes(for category: String) -> [NoteItem] {
        if category == "All" {
            return activeNotes
        }
        return activeNotes.filter { $0.category == category }
    }

    public var archivedNotes: [NoteItem] {
        notes.filter { $0.isArchived }
            .sorted(by: { $0.updatedAt > $1.updatedAt })
    }

    public var favoriteNotes: [NoteItem] {
        notes.filter { !$0.isArchived && $0.isFavorite }
            .sorted(by: { $0.updatedAt > $1.updatedAt })
    }

    public var pinnedNotes: [NoteItem] {
        notes.filter { !$0.isArchived && $0.isPinned }
            .sorted(by: { $0.updatedAt > $1.updatedAt })
    }

    public var selectedNote: NoteItem? {
        guard let id = selectedNoteId else { return nil }
        return notes.first(where: { $0.id == id })
    }

    // MARK: - CRUD Operations

    @discardableResult
    public func createNote(
        title: String = "",
        body: String = "",
        color: NoteColor? = nil,
        category: String = "General",
        isCodeMode: Bool = false
    ) -> NoteItem {
        let selectedColor: NoteColor
        if let color = color {
            selectedColor = color
        } else {
            let colors = NoteColor.allCases
            let count = activeNotes.count
            selectedColor = colors[count % colors.count]
        }

        let newNote = NoteItem(
            title: title,
            body: body,
            color: selectedColor,
            category: category,
            isCodeMode: isCodeMode
        )
        notes.insert(newNote, at: 0)
        selectedNoteId = newNote.id
        saveNotes()
        return newNote
    }

    public func updateNote(_ note: NoteItem) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            var updated = note
            updated.updatedAt = Date()
            notes[index] = updated
        }
    }

    public func toggleChecklist(noteId: UUID, lineIndex: Int) {
        guard let noteIndex = notes.firstIndex(where: { $0.id == noteId }) else { return }
        var note = notes[noteIndex]
        var lines = note.body.components(separatedBy: .newlines)
        guard lineIndex < lines.count else { return }

        let line = lines[lineIndex]
        let trimmed = line.trimmingCharacters(in: .whitespaces)

        if trimmed.hasPrefix("- [ ] ") {
            let rest = String(trimmed.dropFirst(6))
            lines[lineIndex] = "- [x] \(rest)"
        } else if trimmed.hasPrefix("- [x] ") || trimmed.hasPrefix("- [X] ") {
            let rest = String(trimmed.dropFirst(6))
            lines[lineIndex] = "- [ ] \(rest)"
        }

        note.body = lines.joined(separator: "\n")
        note.updatedAt = Date()
        notes[noteIndex] = note
    }

    public func toggleFold(noteId: UUID) {
        if let index = notes.firstIndex(where: { $0.id == noteId }) {
            notes[index].isFolded.toggle()
            notes[index].updatedAt = Date()
            saveNotes()
        }
    }

    public func toggleFavorite(noteId: UUID) {
        if let index = notes.firstIndex(where: { $0.id == noteId }) {
            notes[index].isFavorite.toggle()
            notes[index].updatedAt = Date()
            saveNotes()
        }
    }

    public func togglePin(noteId: UUID) {
        if let index = notes.firstIndex(where: { $0.id == noteId }) {
            notes[index].isPinned.toggle()
            notes[index].updatedAt = Date()
            saveNotes()
        }
    }

    public func setReminder(noteId: UUID, date: Date?) {
        if let index = notes.firstIndex(where: { $0.id == noteId }) {
            notes[index].reminderDate = date
            notes[index].updatedAt = Date()
            saveNotes()
            if let targetDate = date {
                let note = notes[index]
                ReminderService.shared.scheduleReminder(
                    noteId: note.id,
                    title: note.displayTitle,
                    body: note.previewSnippet,
                    date: targetDate
                )
            } else {
                ReminderService.shared.cancelReminder(for: noteId)
            }
        }
    }

    public func archiveNote(id: UUID) {
        if let index = notes.firstIndex(where: { $0.id == id }) {
            notes[index].isArchived = true
            notes[index].updatedAt = Date()
            if selectedNoteId == id {
                selectedNoteId = activeNotes.first?.id
            }
            saveNotes()
        }
    }

    public func unarchiveNote(id: UUID) {
        if let index = notes.firstIndex(where: { $0.id == id }) {
            notes[index].isArchived = false
            notes[index].updatedAt = Date()
            selectedNoteId = id
            saveNotes()
        }
    }

    public func deleteNote(id: UUID) {
        if let index = notes.firstIndex(where: { $0.id == id }) {
            recentlyDeletedNote = notes[index]
            notes.remove(at: index)
            if selectedNoteId == id {
                selectedNoteId = activeNotes.first?.id
            }
            saveNotes()
        }
    }

    public func undoDelete() {
        guard let deleted = recentlyDeletedNote else { return }
        notes.insert(deleted, at: 0)
        selectedNoteId = deleted.id
        recentlyDeletedNote = nil
        saveNotes()
    }

    public func cycleNote(forward: Bool) {
        let active = activeNotes
        guard !active.isEmpty else { return }
        guard let currentId = selectedNoteId,
              let currentIndex = active.firstIndex(where: { $0.id == currentId }) else {
            selectedNoteId = active.first?.id
            return
        }

        let newIndex: Int
        if forward {
            newIndex = (currentIndex + 1) % active.count
        } else {
            newIndex = (currentIndex - 1 + active.count) % active.count
        }
        selectedNoteId = active[newIndex].id
    }

    // MARK: - Import / Export

    public func exportNotesAsMarkdown(to destinationFolder: URL) throws {
        for note in notes {
            let cleanTitle = note.displayTitle
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .joined(separator: "_")
            let fileName = "\(cleanTitle)_\(note.id.uuidString.prefix(6)).md"
            let fileURL = destinationFolder.appendingPathComponent(fileName)

            var content = "# \(note.displayTitle)\n\n"
            content += "> Created: \(note.createdAt.formatted()) | Category: \(note.category) | Color: \(note.color.rawValue)\n\n"
            content += note.body

            try content.write(to: fileURL, atomically: true, encoding: .utf8)
        }
    }

    public func exportAllAsSingleFile(to destinationURL: URL) throws {
        var fullText = "# NotesMy Export - \(Date().formatted())\n\n"
        for note in notes {
            fullText += "---\n\n"
            fullText += "## \(note.displayTitle)\n"
            fullText += "*Category: \(note.category) | Status: \(note.isArchived ? "Archived" : "Active") | Updated: \(note.updatedAt.formatted())*\n\n"
            fullText += "\(note.body)\n\n"
        }
        try fullText.write(to: destinationURL, atomically: true, encoding: .utf8)
    }

    // MARK: - Persistence

    public func saveNotes() {
        do {
            let data = try JSONEncoder().encode(notes)
            try data.write(to: storageFileURL, options: .atomic)
        } catch {
            print("Failed to save notes: \(error)")
        }
    }

    public func loadNotes() {
        guard fileManager.fileExists(atPath: storageFileURL.path) else { return }
        do {
            let data = try Data(contentsOf: storageFileURL)
            let loaded = try JSONDecoder().decode([NoteItem].self, from: data)
            self.notes = loaded
            self.selectedNoteId = loaded.filter({ !$0.isArchived }).first?.id
        } catch {
            print("Failed to load notes: \(error)")
        }
    }

    public func saveSettings() {
        struct Settings: Codable {
            var dockSide: DockSide
            var activationDelay: Double
            var showOverFullScreen: Bool
            var categories: [String]
            var selectedFont: FontFamilyOption?
            var fontSize: CGFloat?
            var cardSize: CardSizeOption?
        }
        let settings = Settings(
            dockSide: dockSide,
            activationDelay: activationDelay,
            showOverFullScreen: showOverFullScreen,
            categories: categories,
            selectedFont: selectedFont,
            fontSize: fontSize,
            cardSize: cardSize
        )
        if let data = try? JSONEncoder().encode(settings) {
            try? data.write(to: settingsFileURL, options: .atomic)
        }
    }

    public func loadSettings() {
        guard fileManager.fileExists(atPath: settingsFileURL.path),
              let data = try? Data(contentsOf: settingsFileURL) else { return }
        struct Settings: Codable {
            var dockSide: DockSide
            var activationDelay: Double
            var showOverFullScreen: Bool
            var categories: [String]?
            var selectedFont: FontFamilyOption?
            var fontSize: CGFloat?
            var cardSize: CardSizeOption?
        }
        if let settings = try? JSONDecoder().decode(Settings.self, from: data) {
            self.dockSide = settings.dockSide
            self.activationDelay = settings.activationDelay
            self.showOverFullScreen = settings.showOverFullScreen
            if let cats = settings.categories, !cats.isEmpty {
                self.categories = cats
            }
            if let font = settings.selectedFont {
                self.selectedFont = font
            }
            if let size = settings.fontSize {
                self.fontSize = size
            }
            if let card = settings.cardSize {
                self.cardSize = card
            }
        }
    }

    private func createSampleNotes() {
        let note1 = NoteItem(
            title: "Welcome to NotesMy 🚀",
            body: """
            Welcome to your new edge-docked sticky notes deck!

            ✨ **Top New Features (SideNotes & Tot inspired)**:
            - **Folders / Collections:** Filter by Work, Personal, or Code!
            - **Code Mode:** Monospace fonts for clean snippet drafting.
            - **Opacity Slider:** See through your floating note while typing.
            - **Accordion Fold:** Click `⌃` to collapse a note into just a title bar.
            - **Clipboard History:** Convert recently copied items into notes in 1 click!

            - [x] Try hovering over the screen edge
            - [ ] Toggle Code Mode on the code snippet card
            - [ ] Test the opacity / transparency slider
            - [ ] Check out All Notes window (`⌥⌘L`)
            """,
            color: .amber,
            category: "General"
        )

        let note2 = NoteItem(
            title: "Quick Shell Snippet 💻",
            body: """
            # Useful Git & Docker shortcuts
            git checkout -b feature/awesome
            docker compose up -d --build
            curl -I https://api.github.com
            """,
            color: .slate,
            category: "Code",
            isCodeMode: true
        )

        let note3 = NoteItem(
            title: "Q3 Sprint Planning 🎯",
            body: """
            Team kickoff tomorrow at 10:00 AM.
            - Review Q3 UX milestones
            - Deliver glassmorphism floating panel
            - Polish native macOS sharing sheet
            """,
            color: .mint,
            category: "Work"
        )

        notes = [note1, note2, note3]
        selectedNoteId = note1.id
        saveNotes()
    }
}
