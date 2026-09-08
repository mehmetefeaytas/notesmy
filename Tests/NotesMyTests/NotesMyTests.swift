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

    @Test("NoteItem display title and checklist extraction")
    func testNoteItemChecklist() {
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
            category: "Work"
        )

        #expect(note.displayTitle == "This is a demo task list:")
        #expect(note.checklistItems.count == 3)
        #expect(note.checklistItems[0].isChecked == false)
        #expect(note.checklistItems[1].isChecked == true)

        let progress = note.checklistProgress
        #expect(progress != nil)
        #expect(progress?.completed == 1)
        #expect(progress?.total == 3)
    }

    @Test("SmartDateDetector natural language detection")
    func testSmartDateDetection() {
        let text = "Let's schedule a review tomorrow at 4:00 PM for the new release."
        let detected = SmartDateDetector.shared.detectDates(in: text)

        #expect(!detected.isEmpty)
        #expect(detected.first?.date != nil)
        #expect(!detected.first!.formattedDescription.isEmpty)
    }

    @Test("Categories and advanced features (SideNotes & Tot inspired)")
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
