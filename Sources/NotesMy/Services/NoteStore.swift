import Foundation
import SwiftUI
import Combine

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
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties

    public var activeNotes: [NoteItem] {
        notes.filter { !$0.isArchived }
            .sorted(by: { $0.updatedAt > $1.updatedAt })
    }

    public var archivedNotes: [NoteItem] {
        notes.filter { $0.isArchived }
            .sorted(by: { $0.updatedAt > $1.updatedAt })
    }

    public var selectedNote: NoteItem? {
        guard let id = selectedNoteId else { return nil }
        return notes.first(where: { $0.id == id })
    }

    // MARK: - CRUD Operations

    @discardableResult
    public func createNote(title: String = "", body: String = "", color: NoteColor? = nil) -> NoteItem {
        let selectedColor: NoteColor
        if let color = color {
            selectedColor = color
        } else {
            // Cycle or pick smart color based on existing
            let colors = NoteColor.allCases
            let count = activeNotes.count
            selectedColor = colors[count % colors.count]
        }

        let newNote = NoteItem(
            title: title,
            body: body,
            color: selectedColor
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
            content += "> Created: \(note.createdAt.formatted()) | Color: \(note.color.rawValue)\n\n"
            content += note.body

            try content.write(to: fileURL, atomically: true, encoding: .utf8)
        }
    }

    public func exportAllAsSingleFile(to destinationURL: URL) throws {
        var fullText = "# NotesMy Export - \(Date().formatted())\n\n"
        for note in notes {
            fullText += "---\n\n"
            fullText += "## \(note.displayTitle)\n"
            fullText += "*Status: \(note.isArchived ? "Archived" : "Active") | Updated: \(note.updatedAt.formatted())*\n\n"
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
        }
        let settings = Settings(dockSide: dockSide, activationDelay: activationDelay, showOverFullScreen: showOverFullScreen)
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
        }
        if let settings = try? JSONDecoder().decode(Settings.self, from: data) {
            self.dockSide = settings.dockSide
            self.activationDelay = settings.activationDelay
            self.showOverFullScreen = settings.showOverFullScreen
        }
    }

    private func createSampleNotes() {
        let note1 = NoteItem(
            title: "Welcome to NotesMy 🚀",
            body: """
            Welcome to your new edge-docked sticky notes deck!

            ✨ **Quick Tips**:
            - Move your pointer to the edge of the screen to fan out your deck.
            - Click any card to open and edit in-place.
            - Press `⌥⌘N` anywhere for an instant new note.
            - Press `⌥⌘V` to capture your clipboard straight into a new note!

            - [x] Try hovering over the screen edge
            - [ ] Create your first custom sticky note
            - [ ] Check out the All Notes window with `⌥⌘L`
            """,
            color: .amber
        )

        let note2 = NoteItem(
            title: "Project Milestones 🎯",
            body: """
            Team sync tomorrow at 3:00 PM to review Q3 progress.

            - [ ] Finalize Swift desktop edge animation
            - [ ] Add NLP date detector for instant calendar events
            - [x] Setup zero-cloud local encrypted storage
            - [ ] Test multi-monitor support
            """,
            color: .mint
        )

        let note3 = NoteItem(
            title: "Book & Article Ideas 💡",
            body: """
            "Designing Frictionless Desktop Micro-Tools"
            - Deep dive into Fitts' Law and screen-edge docking
            - Memory footprint optimization on Apple Silicon
            - Native AppKit floating panels vs heavy webviews
            """,
            color: .sky
        )

        notes = [note1, note2, note3]
        selectedNoteId = note1.id
        saveNotes()
    }
}
