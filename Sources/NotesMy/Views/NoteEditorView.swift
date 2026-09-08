import SwiftUI
import AppKit

public struct NoteEditorView: View {
    @ObservedObject var store = NoteStore.shared
    public var noteId: UUID
    public var onClose: () -> Void

    @State private var localTitle: String = ""
    @State private var localBody: String = ""
    @State private var localColor: NoteColor = .amber
    @State private var localCategory: String = "General"
    @State private var isPinned: Bool = false
    @State private var isFolded: Bool = false
    @State private var opacity: Double = 1.0
    @State private var isCodeMode: Bool = false
    @State private var detectedDates: [SmartDateInfo] = []
    @State private var isDragTargetActive: Bool = false
    @State private var showDeleteConfirm: Bool = false
    @State private var copiedFeedback: Bool = false
    @State private var showOpacityPopover: Bool = false
    @State private var aiStatusMessage: String? = nil

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

            if !isFolded {
                if !detectedDates.isEmpty {
                    smartDateBanner
                }

                if let message = aiStatusMessage {
                    aiBanner(message: message)
                }

                if let note = currentNote, !note.checklistItems.isEmpty {
                    checklistPreviewStrip(items: note.checklistItems)
                }

                editorArea

                footerBar
            }
        }
        .frame(
            minWidth: 340,
            idealWidth: 380,
            minHeight: isFolded ? 46 : 360,
            idealHeight: isFolded ? 46 : 420
        )
        .background(
            localColor.primaryColor
                .opacity(opacity)
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(localColor.borderTone, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 6)
        .animation(.spring(response: 0.28, dampingFraction: 0.82), value: isFolded)
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
        .onChange(of: opacity) { _ in
            persistChanges()
        }
        .onChange(of: isFolded) { _ in
            persistChanges()
        }
        .onChange(of: isCodeMode) { _ in
            persistChanges()
        }
        .onChange(of: localCategory) { _ in
            persistChanges()
        }
        .onDrop(of: [.fileURL, .image], isTargeted: $isDragTargetActive) { providers in
            handleDrop(providers: providers)
        }
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack(spacing: 8) {
            // Fold / Accordion Toggle
            Button(action: { isFolded.toggle() }) {
                Image(systemName: isFolded ? "chevron.right" : "chevron.down")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(localColor.secondaryTextColor)
            }
            .buttonStyle(.plain)
            .help(isFolded ? "Expand Note" : "Fold / Collapse Note")

            // Color cycle button
            Button(action: cycleColor) {
                Circle()
                    .fill(localColor.dotColor)
                    .frame(width: 14, height: 14)
                    .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .help("Change Color (⌘.)")

            // Title Field
            TextField("", text: $localTitle, prompt: Text("Note Title...").foregroundColor(localColor.secondaryTextColor))
                .textFieldStyle(.plain)
                .font(.system(size: 13, weight: .bold, design: isCodeMode ? .monospaced : .rounded))
                .foregroundColor(localColor.textColor)

            Spacer()

            // Category Menu
            Menu {
                ForEach(store.categories, id: \.self) { cat in
                    Button(cat) {
                        localCategory = cat
                    }
                }
            } label: {
                Text(localCategory)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(localColor.secondaryTextColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.06))
                    .cornerRadius(4)
            }
            .menuStyle(.borderlessButton)

            // Apple Intelligence Sparkles Menu
            aiToolsMenu

            // Pin / Floating toggle
            Button(action: togglePin) {
                Image(systemName: isPinned ? "pin.fill" : "pin")
                    .font(.system(size: 11))
                    .foregroundColor(isPinned ? Color.accentColor : localColor.secondaryTextColor)
            }
            .buttonStyle(.plain)
            .help(isPinned ? "Unpin from desktop" : "Pin to desktop")

            // Close button
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 13))
                    .foregroundColor(localColor.secondaryTextColor.opacity(0.7))
            }
            .buttonStyle(.plain)
            .help("Close (Esc)")
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    // MARK: - Apple Intelligence Menu

    private var aiToolsMenu: some View {
        Menu {
            Section("Apple Intelligence") {
                Button {
                    applyAISummarize()
                } label: {
                    Label("Summarize Note", systemImage: "sparkles")
                }

                Button {
                    applyAITasks()
                } label: {
                    Label("Extract Action Items", systemImage: "checklist")
                }

                Button {
                    applyAITitle()
                } label: {
                    Label("Suggest Smart Title", systemImage: "character.textbox")
                }

                Button {
                    applyAICategory()
                } label: {
                    Label("Auto-Categorize Note", systemImage: "folder.badge.gearshape")
                }
            }

            Section("Rewrite & Transform") {
                Button {
                    applyAIRewrite(style: .concise)
                } label: {
                    Label("Make Concise", systemImage: "arrow.down.right.and.arrow.up.left")
                }

                Button {
                    applyAIRewrite(style: .professional)
                } label: {
                    Label("Make Professional", systemImage: "briefcase")
                }

                Button {
                    applyAIRewrite(style: .bulletPoints)
                } label: {
                    Label("Convert to Bullet Points", systemImage: "list.bullet")
                }
            }
        } label: {
            HStack(spacing: 3) {
                Image(systemName: "sparkles")
                    .font(.system(size: 11, weight: .semibold))
                Text("AI")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                LinearGradient(
                    colors: [Color.purple.opacity(0.25), Color.blue.opacity(0.25)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundColor(.purple)
            .cornerRadius(5)
        }
        .menuStyle(.borderlessButton)
        .help("Apple Intelligence Writing & Productivity Tools")
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

    private func aiBanner(message: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
                .font(.system(size: 10))
                .foregroundColor(.purple)

            Text(message)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(localColor.textColor)
                .lineLimit(1)

            Spacer()

            Button(action: { withAnimation { aiStatusMessage = nil } }) {
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color.purple.opacity(0.12))
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

    @ViewBuilder
    private var editorArea: some View {
        if #available(macOS 15.0, *) {
            TextEditor(text: $localBody)
                .font(.system(size: 13, design: isCodeMode ? .monospaced : .rounded))
                .foregroundColor(localColor.textColor)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 10)
                .background(Color.clear)
                .writingToolsBehavior(.complete)
        } else {
            TextEditor(text: $localBody)
                .font(.system(size: 13, design: isCodeMode ? .monospaced : .rounded))
                .foregroundColor(localColor.textColor)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 10)
                .background(Color.clear)
        }
    }

    // MARK: - Footer Bar

    private var footerBar: some View {
        HStack(spacing: 8) {
            let wordCount = localBody.split { $0.isWhitespace || $0.isNewline }.count
            let charCount = localBody.count

            Text("\(wordCount) words · \(charCount) chars")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(localColor.secondaryTextColor.opacity(0.8))

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

            Divider().frame(height: 10)

            // Code Mode Toggle
            Button(action: { isCodeMode.toggle() }) {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.system(size: 10, weight: isCodeMode ? .bold : .regular))
                    .foregroundColor(isCodeMode ? Color.accentColor : localColor.secondaryTextColor)
            }
            .buttonStyle(.plain)
            .help(isCodeMode ? "Disable Code Mode" : "Enable Monospace Code Mode")

            // Opacity / Translucency Popover Button
            Button(action: { showOpacityPopover.toggle() }) {
                Image(systemName: "circle.lefthalf.filled")
                    .font(.system(size: 11))
                    .foregroundColor(localColor.secondaryTextColor)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showOpacityPopover) {
                VStack(spacing: 8) {
                    Text("Window Opacity: \(Int(opacity * 100))%")
                        .font(.system(size: 11, weight: .medium))
                    Slider(value: $opacity, in: 0.4...1.0, step: 0.05)
                        .frame(width: 120)
                }
                .padding(10)
            }
            .help("Window Transparency")

            // Copy Note Text Button
            Button(action: copyToClipboard) {
                Image(systemName: copiedFeedback ? "checkmark" : "doc.on.doc")
                    .font(.system(size: 11))
                    .foregroundColor(copiedFeedback ? .green : localColor.secondaryTextColor)
            }
            .buttonStyle(.plain)
            .help("Copy Note Content")

            // Native Share Button
            Button(action: shareNote) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 11))
                    .foregroundColor(localColor.secondaryTextColor)
            }
            .buttonStyle(.plain)
            .help("Share Note...")

            // Send to Apple Notes
            Button(action: sendToAppleNotes) {
                Image(systemName: "apple.logo")
                    .font(.system(size: 11))
                    .foregroundColor(localColor.secondaryTextColor)
            }
            .buttonStyle(.plain)
            .help("Export to Apple Notes")

            // Send to Apple Reminders
            Button(action: sendToReminders) {
                Image(systemName: "checklist")
                    .font(.system(size: 11))
                    .foregroundColor(localColor.secondaryTextColor)
            }
            .buttonStyle(.plain)
            .help("Export to Apple Reminders")

            // Checklist insert button
            Button(action: insertChecklistItem) {
                Image(systemName: "checkmark.square")
                    .font(.system(size: 11))
                    .foregroundColor(localColor.secondaryTextColor)
            }
            .buttonStyle(.plain)
            .help("Insert Checklist Item")

            // Archive button
            Button(action: archiveNote) {
                Image(systemName: "archivebox")
                    .font(.system(size: 11))
                    .foregroundColor(localColor.secondaryTextColor)
            }
            .buttonStyle(.plain)
            .help("Archive Note")

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

    // MARK: - Apple Intelligence Actions

    private func applyAISummarize() {
        let summary = SmartAIService.shared.summarize(text: localBody)
        if !summary.isEmpty {
            localBody = "\(summary)\n\n---\n\n\(localBody)"
            aiStatusMessage = "AI Summary added to top of note"
        }
    }

    private func applyAITasks() {
        let tasks = SmartAIService.shared.extractActionItems(from: localBody)
        if !tasks.isEmpty {
            let checklistBlock = tasks.map { "- [ ] \($0)" }.joined(separator: "\n")
            localBody = "\(checklistBlock)\n\n\(localBody)"
            aiStatusMessage = "Extracted \(tasks.count) action items into checklist"
        } else {
            let checklist = SmartAIService.shared.rewrite(text: localBody, style: .actionItems)
            localBody = checklist
            aiStatusMessage = "Converted lines to interactive checklist"
        }
    }

    private func applyAITitle() {
        let title = SmartAIService.shared.generateSmartTitle(for: localBody)
        localTitle = title
        aiStatusMessage = "AI generated title: \"\(title)\""
    }

    private func applyAICategory() {
        let predicted = SmartAIService.shared.predictCategory(for: "\(localTitle) \(localBody)")
        localCategory = predicted
        aiStatusMessage = "Auto-categorized as \"\(predicted)\""
    }

    private func applyAIRewrite(style: AIStyle) {
        let rewritten = SmartAIService.shared.rewrite(text: localBody, style: style)
        if !rewritten.isEmpty {
            localBody = rewritten
            aiStatusMessage = "Transformed text: \(style.rawValue)"
        }
    }

    // MARK: - Actions & Helpers

    private func loadNoteData() {
        guard let note = currentNote else { return }
        self.localTitle = note.title
        self.localBody = note.body
        self.localColor = note.color
        self.localCategory = note.category
        self.isPinned = note.isPinned
        self.isFolded = note.isFolded
        self.opacity = note.opacity
        self.isCodeMode = note.isCodeMode
        updateSmartDates()
    }

    private func persistChanges() {
        guard var note = currentNote else { return }
        note.title = localTitle
        note.body = localBody
        note.color = localColor
        note.category = localCategory
        note.isPinned = isPinned
        note.isFolded = isFolded
        note.opacity = opacity
        note.isCodeMode = isCodeMode
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

    private func copyToClipboard() {
        let fullText = localTitle.isEmpty ? localBody : "# \(localTitle)\n\n\(localBody)"
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(fullText, forType: .string)
        withAnimation {
            copiedFeedback = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                copiedFeedback = false
            }
        }
    }

    private func shareNote() {
        let fullText = localTitle.isEmpty ? localBody : "# \(localTitle)\n\n\(localBody)"
        let picker = NSSharingServicePicker(items: [fullText])
        if let keyWindow = NSApp.keyWindow, let contentView = keyWindow.contentView {
            picker.show(relativeTo: contentView.bounds, of: contentView, preferredEdge: .minY)
        }
    }

    private func sendToAppleNotes() {
        let success = AppleNotesService.shared.sendToAppleNotes(title: localTitle.isEmpty ? "Note" : localTitle, body: localBody)
        withAnimation {
            aiStatusMessage = success ? "Exported to Apple Notes!" : "Failed to export to Apple Notes"
        }
    }

    private func sendToReminders() {
        let firstDate = detectedDates.first?.date
        let success = AppleNotesService.shared.sendToReminders(title: localTitle.isEmpty ? "Reminder" : localTitle, notes: localBody, dueDate: firstDate)
        withAnimation {
            aiStatusMessage = success ? "Added to Apple Reminders!" : "Failed to add to Reminders"
        }
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
