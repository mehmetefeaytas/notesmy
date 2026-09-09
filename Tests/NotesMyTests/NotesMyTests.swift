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

        // Test Category Management
        store.addCategory("Projects")
        #expect(store.categories.contains("Projects"))
        store.removeCategory("Projects")
        #expect(!store.categories.contains("Projects"))

        // Test Window Coordinates
        var winNote = store.createNote(title: "Window Note", body: "Checking coords")
        winNote.windowX = 450
        winNote.windowY = 320
        store.updateNote(winNote)
        let retrieved = store.notes.first(where: { $0.id == winNote.id })
        #expect(retrieved?.windowX == 450)
        #expect(retrieved?.windowY == 320)
    }

    @MainActor
    @Test("CloudKit safe initialization and entitlement check")
    func testCloudKitSafeInitialization() {
        let ck = CloudKitSyncService.shared
        // In local test runner or unentitled environment, isEntitled is false and it must not crash
        #expect(ck.syncStatusMessage == "Local Storage")
        #expect(ck.isCloudKitAvailable == false)
        #expect(ck.isSyncing == false)
    }

    @MainActor
    @Test("WebClipperService URL clipping")
    func testWebClipper() {
        guard let url = URL(string: "https://apple.com/newsroom") else { return }
        let note = WebClipperService.shared.clipURL(url)
        #expect(note != nil)
        #expect(note?.title.contains("apple.com") == true)
        #expect(note?.body.contains("Source URL") == true)
    }

    @MainActor
    @Test("AudioRecordingService initial safe state")
    func testAudioRecordingSafeState() {
        let audio = AudioRecordingService.shared
        #expect(audio.isRecording == false)
        #expect(audio.liveTranscript == "")
    }

    @MainActor
    @Test("Inactive notes filtering and archiving")
    func testInactiveNotesManagement() {
        let store = NoteStore.shared
        var oldNote = store.createNote(title: "Old Untouched Note", body: "35 days old")
        // Manually age the note by 40 days
        let fortyDaysAgo = Date().addingTimeInterval(-40 * 86400)
        oldNote.updatedAt = fortyDaysAgo
        store.updateNote(oldNote, touchUpdatedAt: false)

        let inactive = store.inactiveNotes(olderThanDays: 30)
        #expect(inactive.contains(where: { $0.id == oldNote.id }))

        // Archive inactive notes
        store.archiveInactiveNotes(olderThanDays: 30)
        let archived = store.notes.first(where: { $0.id == oldNote.id })
        #expect(archived?.isArchived == true)

        // Cleanup
        store.deleteNote(id: oldNote.id)
    }

    @Test("UpdateService semantic version comparisons")
    func testUpdateServiceVersionComparison() {
        #expect(UpdateService.isVersion("1.6.3", higherThan: "1.6.2") == true)
        #expect(UpdateService.isVersion("v1.7.0", higherThan: "1.6.9") == true)
        #expect(UpdateService.isVersion("2.0.0", higherThan: "1.9.9") == true)
        #expect(UpdateService.isVersion("1.6.2", higherThan: "1.6.2") == false)
        #expect(UpdateService.isVersion("1.6.1", higherThan: "1.6.2") == false)
        #expect(UpdateService.isVersion("1.6.2.1", higherThan: "1.6.2") == true)
    }

    @Test("AppReleaseInfo decoding and DMG asset discovery")
    func testReleaseDecoding() throws {
        let json = """
        {
            "id": 998877,
            "tag_name": "v1.7.0",
            "name": "NotesMy 1.7.0",
            "body": "Added automatic update checks and fast installer.",
            "html_url": "https://github.com/mehmetefeaytas/notesmy/releases/tag/v1.7.0",
            "published_at": "2026-09-08T20:00:00Z",
            "assets": [
                {
                    "name": "NotesMy-1.7.0.dmg",
                    "browser_download_url": "https://github.com/mehmetefeaytas/notesmy/releases/download/v1.7.0/NotesMy-1.7.0.dmg",
                    "size": 18000000
                }
            ]
        }
        """.data(using: .utf8)!

        let release = try JSONDecoder().decode(AppReleaseInfo.self, from: json)
        #expect(release.version == "1.7.0")
        #expect(release.displayTitle == "NotesMy 1.7.0")
        #expect(release.dmgDownloadURL?.absoluteString == "https://github.com/mehmetefeaytas/notesmy/releases/download/v1.7.0/NotesMy-1.7.0.dmg")
    }

    @Test("Markdown format stripping and snippet presentation")
    func testMarkdownSnippets() {
        let note = NoteItem(
            title: "Markdown Test",
            body: "# Header 1\nThis is **bold** text and `code` and ~~strike~~\n- [ ] Task 1"
        )
        let snippet = note.previewSnippet
        #expect(!snippet.contains("**"))
        #expect(!snippet.contains("~~"))
        #expect(!snippet.contains("`"))
        #expect(!snippet.hasPrefix("#"))
        #expect(snippet.contains("Header 1"))
        #expect(snippet.contains("bold text"))
    }

    @Test("TableMarkdownHelper generation, alignments, and CSV/TSV export")
    func testTableMarkdownHelper() {
        // Test Table Generation
        let tableMD = TableMarkdownHelper.generateMarkdown(cols: 3, rows: 2, isTurkish: true)
        #expect(tableMD.contains("| Başlık 1 | Başlık 2 | Başlık 3 |"))
        #expect(tableMD.contains("| :--- | :--- | :--- |"))
        #expect(tableMD.contains("| Veri 1.1 | Veri 1.2 | Veri 1.3 |"))
        #expect(tableMD.contains("| Veri 2.1 | Veri 2.2 | Veri 2.3 |"))

        // Test Separator Detection
        #expect(TableMarkdownHelper.isTableSeparator(line: "| :--- | :---: | ---: |"))
        #expect(TableMarkdownHelper.isTableSeparator(line: "--- | --- | ---"))
        #expect(!TableMarkdownHelper.isTableSeparator(line: "| Normal | Row |"))
        #expect(!TableMarkdownHelper.isTableSeparator(line: "Hello world"))

        // Test Alignment Parsing
        let alignments = TableMarkdownHelper.parseAlignments(separatorLine: "| :--- | :---: | ---: |")
        #expect(alignments.count == 3)
        #expect(alignments[0] == .left)
        #expect(alignments[1] == .center)
        #expect(alignments[2] == .right)

        // Test CSV & TSV Export
        let tableData = MarkdownTableData(
            headers: ["Feature", "Status", "Notes"],
            alignments: [.left, .center, .left],
            rows: [
                ["Table Support", "Done", "Works with CSV, TSV"],
                ["Callouts", "Done", "Notion-style"]
            ]
        )
        let csv = tableData.toCSV()
        #expect(csv.contains("Feature,Status,Notes"))
        #expect(csv.contains("\"Works with CSV, TSV\""))

        let tsv = tableData.toTSV()
        #expect(tsv.contains("Feature\tStatus\tNotes"))
        #expect(tsv.contains("Table Support\tDone\tWorks with CSV, TSV"))

        // Test Built-in Presets
        #expect(TableMarkdownHelper.builtInPresets.count >= 5)
        #expect(TableMarkdownHelper.builtInPresets.contains(where: { $0.id == "comparison" }))
        #expect(TableMarkdownHelper.builtInPresets.contains(where: { $0.id == "budget_tracker" }))
    }

    @Test("NoteItem table and highlight snippet cleaning")
    func testTableAndHighlightSnippetCleaning() {
        let noteWithTable = NoteItem(
            title: "Project Plan",
            body: """
            ## Sprint Overview
            ==High Priority== update for release.
            > [!NOTE]
            > Review table below before merge.
            | Task | Status |
            | :--- | :---: |
            | App Store submission | In Progress |
            """
        )
        let snippet = noteWithTable.previewSnippet
        #expect(!snippet.contains("=="))
        #expect(!snippet.contains("| :---"))
        #expect(!snippet.contains("> [!NOTE]"))
        #expect(snippet.contains("High Priority"))
        #expect(snippet.contains("Task · Status") || snippet.contains("Sprint Overview"))
    }

    @Test("NoteTemplate table templates coverage")
    func testNoteTemplatesWithTables() {
        let templates = NoteTemplate.builtInTemplates
        let roadmap = templates.first(where: { $0.id == "project_roadmap" })
        let budget = templates.first(where: { $0.id == "budget_planner" })
        let habit = templates.first(where: { $0.id == "habit_tracker" })

        #expect(roadmap != nil)
        #expect(budget != nil)
        #expect(habit != nil)

        #expect(roadmap?.bodyTemplate.contains("| Feature |") == true)
        #expect(budget?.bodyTemplate.contains("| Expense Item |") == true)
        #expect(habit?.bodyTemplate.contains("| Habit / Routine |") == true)
    }

    @Test("ExportService HTML, PDF, RTF and Markdown generation")
    @MainActor
    func testExportService() {
        let note = NoteItem(
            title: "Q3 Release Strategy",
            body: """
            # Strategy Overview
            This is a **high priority** deliverable with ==highlighted goals==.

            > [!NOTE]
            > Ensure test coverage before releasing to GitHub.

            | Module | Status | Priority |
            | :--- | :---: | ---: |
            | Table Formatting | Done | High |
            | PDF Export | Done | Critical |

            - [x] Complete Swift unit tests
            - [ ] Deploy DMG to GitHub releases
            """,
            color: .amber,
            tags: ["release", "v1.7.0"],
            category: "Work"
        )

        // Test HTML generation
        let html = ExportService.shared.exportNoteToHTML(note: note)
        #expect(html.contains("Q3 Release Strategy"))
        #expect(html.contains("<table"))
        #expect(html.contains("Table Formatting"))
        #expect(html.contains("callout callout-note"))
        #expect(html.contains("<mark>highlighted goals</mark>"))
        #expect(html.contains("task-list-item"))

        // Test Markdown with YAML Frontmatter
        let md = ExportService.shared.exportNoteToMarkdownString(note: note)
        #expect(md.hasPrefix("---"))
        #expect(md.contains("title: \"Q3 Release Strategy\""))
        #expect(md.contains("category: \"Work\""))
        #expect(md.contains("# Q3 Release Strategy"))

        // Test PDF Data generation
        let pdfData = ExportService.shared.exportNoteToPDFData(note: note)
        #expect(pdfData != nil)
        #expect(pdfData!.count > 1000)
        let pdfHeader = String(data: pdfData!.prefix(5), encoding: .ascii)
        #expect(pdfHeader == "%PDF-")

        // Test RTF Data generation
        let rtfData = ExportService.shared.exportNoteToRTFData(note: note)
        #expect(rtfData != nil)
        #expect(rtfData!.count > 500)

        // Test Multiple Notes PDF generation
        let multiPDF = ExportService.shared.exportMultipleNotesToPDFData(notes: [note], bookTitle: "Archive 2026")
        #expect(multiPDF != nil)
        #expect(multiPDF!.count > 1000)
    }
}
