import Testing
import Foundation
@testable import NotesMy

@Suite("NotesMy Model & Logic Tests")
struct NotesMyTests {

    @Test("NoteColor properties and palettes")
    func testNoteColor() {
        let colors = NoteColor.allCases
        #expect(colors.count == 6)
        #expect(NoteColor.amber.displayName == "Amber Yellow")
        #expect(NoteColor.slate.displayName == "Slate Noir")
        #expect(!NoteColor.mint.backgroundHex.isEmpty)
    }

    @Test("NoteItem display title, checklist and codable")
    func testNoteItemChecklist() throws {
        let body = """
        This is a demo task list:
        - [ ] Buy oat milk
        - [x] Write Swift desktop app
        - [ ] Review PRs
        """

        let note = NoteItem(
            title: "",
            body: body,
            color: .amber,
            category: "Work",
            isFavorite: true,
            reminderDate: Date()
        )

        #expect(note.displayTitle == "This is a demo task list:")
        #expect(note.checklistItems.count == 3)
        #expect(note.checklistItems[0].isChecked == false)
        #expect(note.checklistItems[1].isChecked == true)
        #expect(note.isFavorite == true)
        #expect(note.reminderDate != nil)

        let progress = note.checklistProgress
        #expect(progress != nil)
        #expect(progress?.completed == 1)
        #expect(progress?.total == 3)

        // Test JSON Codable Roundtrip
        let data = try JSONEncoder().encode(note)
        let decoded = try JSONDecoder().decode(NoteItem.self, from: data)
        #expect(decoded.id == note.id)
        #expect(decoded.isFavorite == true)
        #expect(decoded.reminderDate != nil)
    }

    @Test("SmartDateDetector natural language detection")
    func testSmartDateDetection() {
        let text = "Let's schedule a review tomorrow at 4:00 PM for the new release."
        let detected = SmartDateDetector.shared.detectDates(in: text)

        #expect(!detected.isEmpty)
        #expect(detected.first?.date != nil)
        #expect(!detected.first!.formattedDescription.isEmpty)
    }

    @Test("Apple Intelligence SmartAIService capabilities")
    func testAppleIntelligenceService() {
        let sampleText = """
        We need to deploy the new macOS application by Friday.
        Remember to update the changelog on GitHub.
        Review the pull requests and run unit tests.
        """

        // Test Action Items Extraction
        let tasks = SmartAIService.shared.extractActionItems(from: sampleText)
        #expect(!tasks.isEmpty)
        #expect(tasks.contains(where: { $0.lowercased().contains("deploy") || $0.lowercased().contains("changelog") || $0.lowercased().contains("review") }))

        // Test Smart Title Generation
        let title = SmartAIService.shared.generateSmartTitle(for: sampleText)
        #expect(!title.isEmpty)

        // Test Category Prediction
        let codeSnippet = "func processNotes() { let x = 10; return x }"
        let predictedCat = SmartAIService.shared.predictCategory(for: codeSnippet)
        #expect(predictedCat == "Code")

        // Test Summary Generation
        let summary = SmartAIService.shared.summarize(text: sampleText)
        #expect(!summary.isEmpty)
        #expect(summary.contains("Summary"))

        // Test Turkish Smart Summary
        let trSummary = SmartAIService.shared.smartSummary(text: "Bu uygulama macOS için geliştirilmiştir. Çok hızlı çalışır.", isTurkish: true)
        #expect(!trSummary.isEmpty)
        #expect(trSummary.contains("Yapay Zeka"))

        // Test Messy Note Clean & Format
        let messy = "yarın toplantı var saat 3te unutma faturaları öde bide kodları rebase et"
        let cleaned = SmartAIService.shared.cleanAndFormatMessyNote(text: messy, isTurkish: true)
        #expect(!cleaned.isEmpty)
        #expect(cleaned.contains("Eylem Maddeleri") || cleaned.contains("Düzenlenmiş Not"))

        // Test Rewrite
        let bullets = SmartAIService.shared.rewrite(text: sampleText, style: .bulletPoints)
        #expect(bullets.contains("•"))
    }

    @Test("LocalizationService TR and EN support")
    @MainActor
    func testLocalizationService() {
        let loc = LocalizationService.shared

        loc.language = .english
        #expect(loc.text(.newNote) == "New Note")
        #expect(loc.text(.stickyBoard) == "Sticky Board")

        loc.language = .turkish
        #expect(loc.text(.newNote) == "Yeni Not")
        #expect(loc.text(.stickyBoard) == "Mantar Pano")
    }

    @Test("NoteAppearance typography and card sizes")
    func testNoteAppearance() {
        let fonts = FontFamilyOption.allCases
        #expect(fonts.count >= 5)
        #expect(fonts.contains(.rounded))
        #expect(fonts.contains(.modern))
        #expect(fonts.contains(.monospace))

        let cards = CardSizeOption.allCases
        #expect(cards.count >= 3)
        let standardDim = CardSizeOption.standard.dimensions
        #expect(standardDim.width > 300)
        #expect(standardDim.height > 350)
    }

    @Test("SearchEngine lexical & semantic filtering")
    func testSearchEngine() {
        let note1 = NoteItem(title: "Meeting Notes", body: "Discuss Swift release timeline", category: "Work", isFavorite: true)
        let note2 = NoteItem(title: "Grocery Shopping", body: "Milk, bread, eggs, cheese", category: "Personal", isFavorite: false)
        let note3 = NoteItem(title: "Database Architecture", body: "Postgres schema migrations", category: "Code", isFavorite: true)

        let allNotes = [note1, note2, note3]

        // Exact match
        var filters = SearchFilters()
        filters.query = "timeline"
        var results = SearchEngine.shared.search(notes: allNotes, with: filters)
        #expect(results.count == 1)
        #expect(results.first?.id == note1.id)

        // Category filter
        filters = SearchFilters()
        filters.category = "Code"
        results = SearchEngine.shared.search(notes: allNotes, with: filters)
        #expect(results.count == 1)
        #expect(results.first?.id == note3.id)

        // Semantic / conceptual search
        filters = SearchFilters()
        filters.query = "food supper"
        filters.isSemanticSearchEnabled = true
        results = SearchEngine.shared.search(notes: allNotes, with: filters)
        #expect(!results.isEmpty)
    }

    @Test("Categories, Fold and Favorites (SideNotes & Tot inspired)")
    @MainActor
    func testAdvancedFeatures() {
        let store = NoteStore()

        let devNote = store.createNote(
            title: "Swift Terminal",
            body: "swift build -c release",
            color: .slate,
            category: "Code",
            isCodeMode: true
        )

        #expect(devNote.category == "Code")
        #expect(devNote.isCodeMode == true)

        // Test category filter
        let codeNotes = store.activeNotes(for: "Code")
        #expect(codeNotes.contains(where: { $0.id == devNote.id }))

        // Test Fold / Accordion
        store.toggleFold(noteId: devNote.id)
        let folded = store.notes.first(where: { $0.id == devNote.id })
        #expect(folded?.isFolded == true)

        // Test Favorite Toggle
        store.toggleFavorite(noteId: devNote.id)
        #expect(store.favoriteNotes.contains(where: { $0.id == devNote.id }))
    }

    @Test("NoteStore CRUD operations")
    @MainActor
    func testNoteStoreCRUD() {
        let store = NoteStore()

        let initialCount = store.activeNotes.count
        let newNote = store.createNote(title: "Test Note", body: "Hello world!", color: .coral)

        #expect(store.activeNotes.count == initialCount + 1)
        #expect(newNote.title == "Test Note")

        // Test Checklist toggle
        let noteWithChecklist = store.createNote(title: "Tasks", body: "- [ ] Step 1\n- [ ] Step 2")
        store.toggleChecklist(noteId: noteWithChecklist.id, lineIndex: 0)

        let updated = store.notes.first(where: { $0.id == noteWithChecklist.id })
        #expect(updated?.body.contains("- [x] Step 1") == true)

        // Test Pin Toggle
        store.togglePin(noteId: newNote.id)
        #expect(store.pinnedNotes.contains(where: { $0.id == newNote.id }))

        // Test Archive
        store.archiveNote(id: newNote.id)
        #expect(store.archivedNotes.contains(where: { $0.id == newNote.id }))

        // Test Unarchive
        store.unarchiveNote(id: newNote.id)
        #expect(store.activeNotes.contains(where: { $0.id == newNote.id }))

        // Test Delete & Undo
        store.deleteNote(id: newNote.id)
        #expect(store.recentlyDeletedNote?.id == newNote.id)
        store.undoDelete()
        #expect(store.notes.contains(where: { $0.id == newNote.id }))
    }
}
