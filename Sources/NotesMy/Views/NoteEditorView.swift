import SwiftUI
import AppKit

public struct NoteEditorView: View {
    @ObservedObject var store = NoteStore.shared
    public var noteId: UUID
    public var onClose: () -> Void

    @State private var localTitle: String = ""
    @State private var localBody: String = ""
    @State private var localColor: NoteColor = .amber
    @State private var isPinned: Bool = false
    @State private var detectedDates: [SmartDateInfo] = []
    @State private var isDragTargetActive: Bool = false
    @State private var showDeleteConfirm: Bool = false

    public init(noteId: UUID, store: NoteStore = .shared, onClose: @escaping () -> Void) {
        self.noteId = noteId
        self.store = store
        self.onClose = onClose
    }

    private var currentNote: NoteItem? {
        store.notes.first(where: { $0.id == noteId })
    }

    public var body: some View {
        VStack(spacing: 0) {
            headerBar

            if !detectedDates.isEmpty {
                smartDateBanner
            }

            // Interactive Checklists quick-toggle strip if items exist
            if let note = currentNote, !note.checklistItems.isEmpty {
                checklistPreviewStrip(items: note.checklistItems)
            }

            editorArea

            footerBar
        }
        .frame(minWidth: 320, idealWidth: 360, minHeight: 340, idealHeight: 400)
        .background(localColor.primaryColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(localColor.borderTone, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 6)
        .onAppear {
            loadNoteData()
        }
        .onChange(of: noteId) { _ in
            loadNoteData()
        }
        .onChange(of: localTitle) { _ in
            persistChanges()
        }
        .onChange(of: localBody) { _ in
            persistChanges()
            updateSmartDates()
        }
        .onDrop(of: [.fileURL, .image], isTargeted: $isDragTargetActive) { providers in
            handleDrop(providers: providers)
        }
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack(spacing: 8) {
            // Color cycle button
            Button(action: cycleColor) {
                Circle()
                    .fill(localColor.dotColor)
                    .frame(width: 14, height: 14)
                    .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .help("Change Color (⌘.)")

            // Title Field
            TextField("Note Title...", text: $localTitle)
                .textFieldStyle(.plain)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(localColor.textColor)

            Spacer()

            // Flip through notes (< and >)
            Button(action: { store.cycleNote(forward: false) }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(localColor.secondaryTextColor)
            }
            .buttonStyle(.plain)
            .help("Previous Note (⌘[)")

            Button(action: { store.cycleNote(forward: true) }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(localColor.secondaryTextColor)
            }
            .buttonStyle(.plain)
            .help("Next Note (⌘])")

            Divider().frame(height: 12)

            // Checklist insert button
            Button(action: insertChecklistItem) {
                Image(systemName: "checkmark.square")
                    .font(.system(size: 11))
                    .foregroundColor(localColor.secondaryTextColor)
            }
            .buttonStyle(.plain)
            .help("Insert Checklist Item")

            // Pin / Floating toggle
            Button(action: togglePin) {
                Image(systemName: isPinned ? "pin.fill" : "pin")
                    .font(.system(size: 11))
                    .foregroundColor(isPinned ? Color.accentColor : localColor.secondaryTextColor)
            }
            .buttonStyle(.plain)
            .help(isPinned ? "Unpin from desktop" : "Pin to desktop")

            // Archive button
            Button(action: archiveNote) {
                Image(systemName: "archivebox")
                    .font(.system(size: 11))
                    .foregroundColor(localColor.secondaryTextColor)
            }
            .buttonStyle(.plain)
            .help("Archive Note")

            // Close button
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 13))
                    .foregroundColor(localColor.secondaryTextColor.opacity(0.6))
            }
            .buttonStyle(.plain)
            .help("Close (Esc)")
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
        .padding(.bottom, 6)
    }

    // MARK: - Smart NLP Date Banner

    private var smartDateBanner: some View {
        HStack(spacing: 6) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 11))
                .foregroundColor(Color.accentColor)

            if let first = detectedDates.first {
                Text("\(first.formattedDescription)")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(localColor.textColor)
                    .lineLimit(1)

                Spacer()

                Button(action: {
                    SmartDateDetector.shared.createCalendarEvent(title: localTitle.isEmpty ? "Reminder" : localTitle, date: first.date)
                }) {
                    Text("Add to Calendar")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.15))
                        .foregroundColor(Color.accentColor)
                        .cornerRadius(4)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.45))
        .cornerRadius(6)
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }

    // MARK: - Checklist Preview Strip

    private func checklistPreviewStrip(items: [ChecklistItem]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(items) { item in
                    Button(action: {
                        store.toggleChecklist(noteId: noteId, lineIndex: item.lineIndex)
                        if let updated = currentNote {
                            self.localBody = updated.body
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 11))
                                .foregroundColor(item.isChecked ? localColor.dotColor : localColor.secondaryTextColor)

                            Text(item.text)
                                .font(.system(size: 11, design: .rounded))
                                .strikethrough(item.isChecked)
                                .foregroundColor(item.isChecked ? localColor.secondaryTextColor : localColor.textColor)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.35))
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 6)
        }
    }

    // MARK: - Main Editor

    private var editorArea: some View {
        TextEditor(text: $localBody)
            .font(.system(size: 13, design: .rounded))
            .foregroundColor(localColor.textColor)
            .scrollContentBackground(.hidden)
            .padding(.horizontal, 10)
            .background(Color.clear)
    }

    // MARK: - Footer Bar

    private var footerBar: some View {
        HStack {
            let wordCount = localBody.split { $0.isWhitespace || $0.isNewline }.count
            let charCount = localBody.count

            Text("\(wordCount) words · \(charCount) chars")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(localColor.secondaryTextColor.opacity(0.8))

            Spacer()

            if showDeleteConfirm {
                HStack(spacing: 6) {
                    Text("Delete?")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.red)

                    Button("Yes") {
                        store.deleteNote(id: noteId)
                        onClose()
                    }
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.red)
                    .buttonStyle(.plain)

                    Button("Cancel") {
                        showDeleteConfirm = false
                    }
                    .font(.system(size: 10))
                    .buttonStyle(.plain)
                }
            } else {
                Button(action: { showDeleteConfirm = true }) {
                    Image(systemName: "trash")
                        .font(.system(size: 10))
                        .foregroundColor(localColor.secondaryTextColor.opacity(0.7))
                }
                .buttonStyle(.plain)
                .help("Delete Note (⌘⌫)")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.04))
    }

    // MARK: - Actions & Helpers

    private func loadNoteData() {
        guard let note = currentNote else { return }
        self.localTitle = note.title
        self.localBody = note.body
        self.localColor = note.color
        self.isPinned = note.isPinned
        updateSmartDates()
    }

    private func persistChanges() {
        guard var note = currentNote else { return }
        note.title = localTitle
        note.body = localBody
        note.color = localColor
        note.isPinned = isPinned
        store.updateNote(note)
    }

    private func updateSmartDates() {
        let detected = SmartDateDetector.shared.detectDates(in: "\(localTitle) \(localBody)")
        self.detectedDates = detected
    }

    private func cycleColor() {
        let colors = NoteColor.allCases
        if let idx = colors.firstIndex(of: localColor) {
            let next = colors[(idx + 1) % colors.count]
            localColor = next
            persistChanges()
        }
    }

    private func insertChecklistItem() {
        if localBody.isEmpty {
            localBody = "- [ ] "
        } else {
            localBody += "\n- [ ] "
        }
    }

    private func togglePin() {
        isPinned.toggle()
        persistChanges()
    }

    private func archiveNote() {
        store.archiveNote(id: noteId)
        onClose()
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier("public.file-url") {
                provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, _ in
                    if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                        DispatchQueue.main.async {
                            self.localBody += "\n![Attachment](\(url.lastPathComponent))\n"
                        }
                    }
                }
                return true
            }
        }
        return false
    }
}
