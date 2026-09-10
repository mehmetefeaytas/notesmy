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
    @ObservedObject var loc = LocalizationService.shared
    @ObservedObject var audioService = AudioRecordingService.shared
    @State private var opacity: Double = 1.0
    @State private var isCodeMode: Bool = false
    @State private var isFavorite: Bool = false
    @State private var detectedDates: [SmartDateInfo] = []
    @State private var isDragTargetActive: Bool = false
    @State private var showDeleteConfirm: Bool = false
    @State private var copiedFeedback: Bool = false
    @State private var showOpacityPopover: Bool = false
    @State private var showReminderPopover: Bool = false
    @State private var reminderDate: Date = Date().addingTimeInterval(3600)
    @State private var isRecordingVoice: Bool = false
    @State private var isPerformingOCR: Bool = false
    @State private var showVersionHistory: Bool = false
    @State private var showTemplatePicker: Bool = false
    @State private var showPencilDrawing: Bool = false
    @State private var showColorPickerPopover: Bool = false
    @State private var showNewCategoryAlert: Bool = false
    @State private var newCategoryName: String = ""
    @State private var aiStatusMessage: String? = nil
    @State private var isMarkdownPreview: Bool = false
    @State private var showMarkdownFormatBar: Bool = true
    @State private var showTablePopover: Bool = false

    public init(noteId: UUID, store: NoteStore = .shared, onClose: @escaping () -> Void) {
        self.noteId = noteId
        self.store = store
        self.onClose = onClose
    }

    private var currentNote: NoteItem? {
        store.notes.first(where: { $0.id == noteId })
    }

    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                headerBar

                if !isFolded {
                    if isRecordingVoice {
                        voiceRecordingBanner
                    }

                    if !detectedDates.isEmpty {
                        smartDateBanner
                    }

                    if let message = aiStatusMessage {
                        aiBanner(message: message)
                    }

                    if let note = currentNote, !note.checklistItems.isEmpty {
                        checklistPreviewStrip(items: note.checklistItems)
                    }

                    if let note = currentNote {
                        let backlinks = store.getBacklinks(for: note.title)
                        if !backlinks.isEmpty {
                            backlinksPreviewStrip(links: backlinks)
                        }
                    }

                    attachmentsGalleryStrip

                    editorArea

                    footerBar
                }
            }
            .background(
                localColor.primaryColor
                    .opacity(opacity)
            )

            // In-place drawing canvas overlay (completely eliminates sheet freezing on macOS NSPanel)
            if showPencilDrawing {
                PencilDrawingView(
                    noteId: noteId,
                    onSave: { url in
                        let name = url.lastPathComponent
                        let attachment = NoteAttachment(
                            fileName: name,
                            relativePath: name,
                            mimeType: "image/png"
                        )
                        store.addAttachment(noteId: noteId, attachment: attachment)
                        if localBody.isEmpty {
                            localBody = "![\(name)](\(name))"
                        } else {
                            localBody += "\n\n![\(name)](\(name))\n"
                        }
                        persistChanges()
                        showPencilDrawing = false
                        aiStatusMessage = loc.language == .turkish ? "Çizim nota eklendi" : "Drawing saved to note"
                    },
                    onDismiss: {
                        showPencilDrawing = false
                    }
                )
                .background(Color(nsColor: .windowBackgroundColor))
                .cornerRadius(12)
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .frame(
            minWidth: 340,
            idealWidth: store.cardSize.dimensions.width,
            minHeight: isFolded ? 46 : 340,
            idealHeight: isFolded ? 46 : store.cardSize.dimensions.height
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(localColor.borderTone, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 6)
        .animation(.spring(response: 0.28, dampingFraction: 0.82), value: isFolded)
        .popover(isPresented: $showVersionHistory) {
            NoteVersionHistoryView(noteId: noteId) {
                loadNoteData()
                showVersionHistory = false
            }
        }
        .popover(isPresented: $showTemplatePicker) {
            TemplatePickerView(noteId: noteId) { template in
                store.applyTemplate(noteId: noteId, template: template, isTurkish: loc.language == .turkish)
                loadNoteData()
                showTemplatePicker = false
            }
        }
        .popover(isPresented: $showOpacityPopover) {
            opacityPopoverContent
        }
        .alert(loc.language == .turkish ? "Yeni Kategori Ekle" : "Add New Category", isPresented: $showNewCategoryAlert) {
            TextField(loc.language == .turkish ? "Kategori Adı" : "Category Name", text: $newCategoryName)
            Button(loc.language == .turkish ? "Ekle" : "Add") {
                let clean = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
                if !clean.isEmpty {
                    store.addCategory(clean)
                    localCategory = clean
                    persistChanges()
                }
            }
            Button(loc.language == .turkish ? "İptal" : "Cancel", role: .cancel) {}
        }
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
        HStack(spacing: 12) {
            // Fold / Accordion Toggle
            Button(action: { isFolded.toggle() }) {
                Image(systemName: isFolded ? "chevron.right" : "chevron.down")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(localColor.secondaryTextColor)
                    .frame(width: 26, height: 26)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(isFolded ? "Expand Note" : "Fold / Collapse Note")

            // Color picker button
            Button(action: { showColorPickerPopover.toggle() }) {
                Circle()
                    .fill(localColor.dotColor)
                    .frame(width: 19, height: 19)
                    .overlay(Circle().stroke(Color.white.opacity(0.9), lineWidth: 1.5))
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showColorPickerPopover) {
                colorPickerPopoverContent
            }
            .help("Choose Color")

            // Title Field
            TextField("", text: $localTitle, prompt: Text("Note Title...").foregroundColor(localColor.secondaryTextColor))
                .textFieldStyle(.plain)
                .font(.system(size: 14, weight: .bold, design: isCodeMode ? .monospaced : .rounded))
                .foregroundColor(localColor.textColor)

            Spacer()

            // Category Menu
            Menu {
                ForEach(store.categories, id: \.self) { cat in
                    Button(loc.localizedCategory(cat)) {
                        localCategory = cat
                    }
                }
                Divider()
                Button(action: {
                    newCategoryName = ""
                    showNewCategoryAlert = true
                }) {
                    Label(loc.language == .turkish ? "+ Yeni Kategori..." : "+ New Category...", systemImage: "folder.badge.plus")
                }
            } label: {
                Text(loc.localizedCategory(localCategory))
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(localColor.secondaryTextColor)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4.5)
                    .background(Color.black.opacity(0.06))
                    .cornerRadius(6)
            }
            .menuStyle(.borderlessButton)

            // Favorite Toggle
            Button(action: toggleFavorite) {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .font(.system(size: 14))
                    .foregroundColor(isFavorite ? .yellow : localColor.secondaryTextColor)
                    .frame(width: 28, height: 28)
                    .background(Color.black.opacity(0.04))
                    .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .help(isFavorite ? "Remove from Favorites" : "Add to Favorites")

            // Voice Note Record Button
            Button(action: toggleVoiceRecording) {
                Image(systemName: isRecordingVoice ? "stop.circle.fill" : "mic.fill")
                    .font(.system(size: 14))
                    .foregroundColor(isRecordingVoice ? .white : localColor.secondaryTextColor)
                    .frame(width: 28, height: 28)
                    .background(isRecordingVoice ? Color.red : Color.black.opacity(0.04))
                    .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .help(isRecordingVoice ? loc.text(.speechStop) : loc.text(.speechRecord))

            // Meeting Studio Button (Prominent & Accentuated)
            Button(action: { MeetingStudioWindowManager.shared.show() }) {
                Image(systemName: "person.2.wave.2.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)
                    .frame(width: 32, height: 28)
                    .background(Color.blue.opacity(0.14))
                    .cornerRadius(7)
            }
            .buttonStyle(.plain)
            .help(loc.language == .turkish ? "Toplantı Stüdyosu: Canlı Transkripsiyon & EA Özeti (Zoom / Teams / Yüz yüze)" : "Meeting Studio: Live Transcribe & AI Recap (Zoom / Teams / In-Person)")

            // Templates Button
            Button(action: { showTemplatePicker.toggle() }) {
                Image(systemName: "square.dashed.inset.filled")
                    .font(.system(size: 14))
                    .foregroundColor(localColor.secondaryTextColor)
                    .frame(width: 28, height: 28)
                    .background(Color.black.opacity(0.04))
                    .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .help(loc.language == .turkish ? "Not Şablonu Uygula" : "Apply Note Template")

            // Version History Button
            Button(action: { showVersionHistory.toggle() }) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 14))
                    .foregroundColor(localColor.secondaryTextColor)
                    .frame(width: 28, height: 28)
                    .background(Color.black.opacity(0.04))
                    .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .help(loc.language == .turkish ? "Versiyon Geçmişi" : "Version History")

            // Apple Intelligence Sparkles Menu
            aiToolsMenu

            // Pin / Floating toggle
            Button(action: togglePin) {
                Image(systemName: isPinned ? "pin.fill" : "pin")
                    .font(.system(size: 14))
                    .foregroundColor(isPinned ? Color.accentColor : localColor.secondaryTextColor)
                    .frame(width: 28, height: 28)
                    .background(isPinned ? Color.accentColor.opacity(0.15) : Color.black.opacity(0.04))
                    .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .help(isPinned ? "Unpin from desktop" : "Pin to desktop")

            // Close button
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 17))
                    .foregroundColor(localColor.secondaryTextColor.opacity(0.8))
                    .frame(width: 28, height: 28)
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
                    applyAICleanMessyNote()
                } label: {
                    Label(loc.text(.cleanMessyNote), systemImage: "wand.and.stars")
                }

                Button {
                    applyAISummarize()
                } label: {
                    Label(loc.text(.summarize), systemImage: "sparkles")
                }

                Button {
                    applyAITasks()
                } label: {
                    Label(loc.text(.extractTasks), systemImage: "checklist")
                }

                Button {
                    applyAITitle()
                } label: {
                    Label(loc.text(.smartTitle), systemImage: "character.textbox")
                }

                Button {
                    applyAICategory()
                } label: {
                    Label(loc.text(.autoCategorize), systemImage: "folder.badge.gearshape")
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

            Section(loc.language == .turkish ? "Toplantı & Transkripsiyon" : "Meeting & Live Transcribe") {
                Button {
                    MeetingStudioWindowManager.shared.show()
                } label: {
                    Label(loc.language == .turkish ? "Toplantı Stüdyosu (Zoom / Teams)..." : "Meeting Studio (Zoom / Teams)...", systemImage: "person.2.wave.2")
                }
            }
        } label: {
            HStack(spacing: 3) {
                Image(systemName: "sparkles")
                    .font(.system(size: 11, weight: .bold))
                Text("AI")
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 2.5)
            .background(
                LinearGradient(
                    colors: [Color.purple, Color.indigo],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(6)
            .shadow(color: Color.purple.opacity(0.35), radius: 2, x: 0, y: 1)
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
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)

            Text(message)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)

            Spacer()

            Button(action: { withAnimation { aiStatusMessage = nil } }) {
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white.opacity(0.85))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            LinearGradient(
                colors: [Color.purple.opacity(0.92), Color.indigo.opacity(0.92)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(6)
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }

    private var voiceRecordingBanner: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.red)
                .frame(width: 8, height: 8)

            Text(audioService.liveTranscript.isEmpty ? loc.text(.speechRecording) : audioService.liveTranscript)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.red)
                .lineLimit(2)

            Spacer()

            Button(action: toggleVoiceRecording) {
                Text(loc.text(.speechStop))
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.red.opacity(0.15))
                    .foregroundColor(.red)
                    .cornerRadius(4)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.red.opacity(0.08))
        .cornerRadius(6)
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }

    private var reminderPopoverContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(loc.text(.addReminder))
                    .font(.system(size: 12, weight: .bold))
                Spacer()
                if currentNote?.reminderDate != nil {
                    Button(action: {
                        store.setReminder(noteId: noteId, date: nil)
                        showReminderPopover = false
                    }) {
                        Text(loc.language == .turkish ? "Temizle" : "Clear")
                            .font(.system(size: 11))
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                }
            }

            // Quick presets
            HStack(spacing: 6) {
                Button(loc.language == .turkish ? "+1 Saat" : "+1 Hour") {
                    reminderDate = Date().addingTimeInterval(3600)
                }
                .font(.system(size: 10))

                Button(loc.language == .turkish ? "Yarın Sabah" : "Tomorrow 9AM") {
                    var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date().addingTimeInterval(86400))
                    comps.hour = 9
                    comps.minute = 0
                    if let d = Calendar.current.date(from: comps) {
                        reminderDate = d
                    }
                }
                .font(.system(size: 10))

                Button(loc.language == .turkish ? "Gelecek Hafta" : "Next Week") {
                    reminderDate = Date().addingTimeInterval(86400 * 7)
                }
                .font(.system(size: 10))
            }

            DatePicker(
                "",
                selection: $reminderDate,
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.graphical)
            .labelsHidden()

            HStack {
                Spacer()
                Button(loc.language == .turkish ? "Kaydet" : "Set Reminder") {
                    store.setReminder(noteId: noteId, date: reminderDate)
                    showReminderPopover = false
                }
                .font(.system(size: 11, weight: .semibold))
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(12)
        .frame(width: 270)
    }

    private var opacityPopoverContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(loc.language == .turkish ? "Pencere Saydamlığı" : "Window Transparency")
                    .font(.system(size: 11, weight: .bold))
                Spacer()
                Text("\(Int(opacity * 100))%")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            Slider(value: $opacity, in: 0.25...1.0)
                .onChange(of: opacity) { newOpacity in
                    NoteWindowManager.shared.updateOpacity(id: noteId, opacity: newOpacity)
                    persistChanges()
                }

            HStack(spacing: 6) {
                Button("50%") {
                    opacity = 0.5
                    NoteWindowManager.shared.updateOpacity(id: noteId, opacity: 0.5)
                    persistChanges()
                }
                .font(.system(size: 10))

                Button("75%") {
                    opacity = 0.75
                    NoteWindowManager.shared.updateOpacity(id: noteId, opacity: 0.75)
                    persistChanges()
                }
                .font(.system(size: 10))

                Button("100%") {
                    opacity = 1.0
                    NoteWindowManager.shared.updateOpacity(id: noteId, opacity: 1.0)
                    persistChanges()
                }
                .font(.system(size: 10))
            }
        }
        .padding(12)
        .frame(width: 200)
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

    // MARK: - Backlinks Strip (Bidirectional Linking)

    private func backlinksPreviewStrip(links: [NoteItem]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                Image(systemName: "link")
                    .font(.system(size: 9))
                    .foregroundColor(localColor.secondaryTextColor)

                Text(loc.language == .turkish ? "Bağlantılı:" : "Linked from:")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(localColor.secondaryTextColor)

                ForEach(links) { link in
                    Button(action: {
                        NoteWindowManager.shared.openNote(id: link.id)
                    }) {
                        HStack(spacing: 3) {
                            Circle().fill(link.color.dotColor).frame(width: 5, height: 5)
                            Text(link.displayTitle)
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.35))
                        .cornerRadius(4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 4)
        }
    }

    // MARK: - Attachments Gallery Strip (Screenshots & Images)

    @ViewBuilder
    private var attachmentsGalleryStrip: some View {
        if let note = currentNote, !note.attachments.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(note.attachments) { att in
                        attachmentThumbnailCard(att)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
            }
        }
    }

    private func attachmentThumbnailCard(_ att: NoteAttachment) -> some View {
        let fullURL = store.attachmentsDirectory.appendingPathComponent(att.relativePath)
        let isImage = att.mimeType.contains("image") || ["png", "jpg", "jpeg"].contains(fullURL.pathExtension.lowercased())

        return ZStack(alignment: .topTrailing) {
            if isImage, let nsImage = NSImage(contentsOf: fullURL) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 52, height: 52)
                    .clipped()
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
                    .onTapGesture {
                        NSWorkspace.shared.open(fullURL)
                    }
            } else {
                VStack(spacing: 2) {
                    Image(systemName: "doc.fill")
                        .font(.system(size: 18))
                        .foregroundColor(localColor.secondaryTextColor)
                    Text(att.fileName)
                        .font(.system(size: 8))
                        .foregroundColor(localColor.textColor)
                        .lineLimit(1)
                }
                .frame(width: 52, height: 52)
                .background(Color.white.opacity(0.35))
                .cornerRadius(8)
                .onTapGesture {
                    NSWorkspace.shared.open(fullURL)
                }
            }

            // Remove button
            Button(action: {
                store.removeAttachment(noteId: noteId, attachmentId: att.id)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 11))
                    .foregroundColor(.red.opacity(0.9))
                    .background(Circle().fill(Color.white))
            }
            .buttonStyle(.plain)
            .offset(x: 4, y: -4)
        }
        .help("Click to view full image")
    }

    // MARK: - Color Picker Popover Content

    private var colorPickerPopoverContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(loc.language == .turkish ? "Not Rengi Seç" : "Note Color")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.primary)

            HStack(spacing: 8) {
                ForEach(NoteColor.allCases) { color in
                    colorSwatchButton(color)
                }
            }
        }
        .padding(12)
        .frame(width: 210)
    }

    private func colorSwatchButton(_ color: NoteColor) -> some View {
        let isSelected = (localColor == color)
        return Button(action: {
            localColor = color
            persistChanges()
            showColorPickerPopover = false
        }) {
            ZStack {
                Circle()
                    .fill(color.dotColor)
                    .frame(width: 22, height: 22)

                if isSelected {
                    Circle()
                        .stroke(Color.primary, lineWidth: 2)
                        .frame(width: 26, height: 26)

                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(color == .slate ? .white : .black)
                }
            }
            .frame(width: 28, height: 28)
        }
        .buttonStyle(.plain)
        .help(color.rawValue.capitalized)
    }

    // MARK: - Main Editor

    private var editorFont: Font {
        if isCodeMode {
            return .system(size: store.fontSize, design: .monospaced)
        } else {
            return store.selectedFont.font(size: store.fontSize)
        }
    }

    @ViewBuilder
    private var editorArea: some View {
        VStack(spacing: 0) {
            if showMarkdownFormatBar && !isCodeMode {
                markdownFormatBar
            }

            if isMarkdownPreview {
                MarkdownRendererView(
                    markdown: localBody,
                    localColor: localColor,
                    fontSize: store.fontSize,
                    fontFamily: store.selectedFont,
                    onToggleChecklist: { lineIndex in
                        store.toggleChecklist(noteId: noteId, lineIndex: lineIndex)
                        if let updated = store.notes.first(where: { $0.id == noteId }) {
                            localBody = updated.body
                        }
                    },
                    onOpenWikiLink: { targetTitle in
                        if let target = store.notes.first(where: { $0.title.localizedCaseInsensitiveCompare(targetTitle) == .orderedSame }) {
                            NoteWindowManager.shared.openNote(id: target.id)
                        }
                    },
                    onEditRequest: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            isMarkdownPreview = false
                        }
                    }
                )
                .background(Color.clear)
            } else {
                if #available(macOS 15.0, *) {
                    TextEditor(text: $localBody)
                        .font(editorFont)
                        .foregroundColor(localColor.textColor)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, 10)
                        .background(Color.clear)
                        .writingToolsBehavior(.complete)
                } else {
                    TextEditor(text: $localBody)
                        .font(editorFont)
                        .foregroundColor(localColor.textColor)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, 10)
                        .background(Color.clear)
                }
            }
        }
    }

    // MARK: - Markdown Format Bar

    private var markdownFormatBar: some View {
        HStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    formatButton(symbol: "bold", tooltip: "Kalın / Bold (**metin**) [⌘B]", action: {
                        insertMarkdown(prefix: "**", suffix: "**", placeholder: "kalın metin")
                    })

                    formatButton(symbol: "italic", tooltip: "İtalik / Italic (*metin*) [⌘I]", action: {
                        insertMarkdown(prefix: "*", suffix: "*", placeholder: "italik metin")
                    })

                    formatButton(symbol: "strikethrough", tooltip: "Üstü Çizili (~~metin~~)", action: {
                        insertMarkdown(prefix: "~~", suffix: "~~", placeholder: "çizili metin")
                    })

                    formatButton(symbol: "highlighter", tooltip: loc.language == .turkish ? "Vurgula / Highlight (==metin==)" : "Highlight (==text==)", action: {
                        insertMarkdown(prefix: "==", suffix: "==", placeholder: "vurgulu metin")
                    })

                    formatButton(symbol: "chevron.left.forwardslash.chevron.right", tooltip: "Satır İçi Kod (`kod`)", action: {
                        insertMarkdown(prefix: "`", suffix: "`", placeholder: "kod")
                    })

                    formatButton(symbol: "curlybraces", tooltip: loc.language == .turkish ? "Kod Bloğu (```kod```)" : "Code Block (```code```)", action: {
                        insertRawMarkdown("```swift\n// Kod bloğu\n```")
                    })

                    formatButton(symbol: "number", tooltip: "Başlık / Heading (## Başlık)", action: {
                        insertMarkdown(prefix: "\n## ", suffix: "\n", placeholder: "Başlık")
                    })

                    // Table Popover Trigger
                    Button(action: { showTablePopover.toggle() }) {
                        Image(systemName: "tablecells")
                            .font(.system(size: 11.5, weight: .semibold))
                            .foregroundColor(showTablePopover ? Color.accentColor : localColor.secondaryTextColor)
                            .frame(width: 24, height: 24)
                            .background(showTablePopover ? Color.accentColor.opacity(0.15) : Color.black.opacity(0.04))
                            .cornerRadius(5)
                    }
                    .buttonStyle(.plain)
                    .help(loc.language == .turkish ? "Tablo Ekle (Matris / Şablonlar)" : "Insert Table (Grid / Presets)")
                    .popover(isPresented: $showTablePopover) {
                        TableInsertPopoverView(
                            onInsertTable: { tableMarkdown in
                                insertRawMarkdown(tableMarkdown)
                                showTablePopover = false
                                aiStatusMessage = loc.language == .turkish ? "Tablo nota eklendi ✨" : "Table inserted to note ✨"
                            },
                            onDismiss: {
                                showTablePopover = false
                            }
                        )
                    }

                    // Callout / Info Box Menu
                    Menu {
                        Button(action: { insertCallout(type: .note) }) {
                            Label(loc.language == .turkish ? "📌 Not Kutusu" : "📌 Note Callout", systemImage: "pin")
                        }
                        Button(action: { insertCallout(type: .tip) }) {
                            Label(loc.language == .turkish ? "💡 İpucu Kutusu" : "💡 Tip Callout", systemImage: "lightbulb")
                        }
                        Button(action: { insertCallout(type: .warning) }) {
                            Label(loc.language == .turkish ? "⚠️ Uyarı Kutusu" : "⚠️ Warning Callout", systemImage: "exclamationmark.triangle")
                        }
                        Button(action: { insertCallout(type: .important) }) {
                            Label(loc.language == .turkish ? "⚡ Önemli Kutusu" : "⚡ Important Callout", systemImage: "bolt")
                        }
                        Button(action: { insertCallout(type: .success) }) {
                            Label(loc.language == .turkish ? "✅ Başarı Kutusu" : "✅ Success Callout", systemImage: "checkmark.circle")
                        }
                        Button(action: { insertCallout(type: .info) }) {
                            Label(loc.language == .turkish ? "ℹ️ Bilgi Kutusu" : "ℹ️ Info Callout", systemImage: "info.circle")
                        }
                    } label: {
                        Image(systemName: "quote.bubble")
                            .font(.system(size: 11.5, weight: .medium))
                            .foregroundColor(localColor.secondaryTextColor)
                            .frame(width: 24, height: 24)
                            .background(Color.black.opacity(0.04))
                            .cornerRadius(5)
                    }
                    .menuStyle(.borderlessButton)
                    .help(loc.language == .turkish ? "Bilgi / Uyarı Kutusu (Callout)" : "Callout Box (Note / Tip / Warning)")

                    // Collapsible Toggle Block (<details>)
                    formatButton(symbol: "chevron.right.circle", tooltip: loc.language == .turkish ? "Açılır/Kapanır Detay Bloğu (<details>)" : "Toggle List (<details>)", action: {
                        let title = loc.language == .turkish ? "Detay Başlığı" : "Toggle Title"
                        let desc = loc.language == .turkish ? "Gizli içerik buraya gelecek..." : "Hidden details go here..."
                        insertRawMarkdown("<details>\n<summary>\(title)</summary>\n\(desc)\n</details>")
                    })

                    formatButton(symbol: "quote.opening", tooltip: "Alıntı / Quote (> alıntı)", action: {
                        insertMarkdown(prefix: "\n> ", suffix: "\n", placeholder: "alıntı")
                    })

                    formatButton(symbol: "list.bullet", tooltip: "Madde İmleri (- liste)", action: {
                        insertMarkdown(prefix: "\n- ", suffix: "", placeholder: "madde")
                    })

                    formatButton(symbol: "list.number", tooltip: loc.language == .turkish ? "Numaralı Liste (1. liste)" : "Numbered List (1. item)", action: {
                        insertMarkdown(prefix: "\n1. ", suffix: "", placeholder: "madde")
                    })

                    formatButton(symbol: "checklist", tooltip: "Görev Listesi (- [ ] görev)", action: {
                        insertMarkdown(prefix: "\n- [ ] ", suffix: "", placeholder: "yapılacak iş")
                    })

                    formatButton(symbol: "minus", tooltip: loc.language == .turkish ? "Yatay Ayırıcı Çizgi (---)" : "Horizontal Rule (---)", action: {
                        insertRawMarkdown("---")
                    })

                    formatButton(symbol: "link", tooltip: "Bağlantı ([başlık](url))", action: {
                        insertMarkdown(prefix: "[", suffix: "](https://...)", placeholder: "bağlantı metni")
                    })
                }
            }

            Spacer()

            Button(action: {
                withAnimation(.easeInOut(duration: 0.15)) {
                    isMarkdownPreview.toggle()
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: isMarkdownPreview ? "pencil" : "eye")
                        .font(.system(size: 10, weight: .bold))
                    Text(isMarkdownPreview ? (loc.language == .turkish ? "Düzenle" : "Edit") : (loc.language == .turkish ? "Önizle" : "Preview"))
                        .font(.system(size: 10, weight: .semibold))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3.5)
                .background(isMarkdownPreview ? Color.accentColor : Color.black.opacity(0.08))
                .foregroundColor(isMarkdownPreview ? .white : localColor.secondaryTextColor)
                .cornerRadius(5)
            }
            .buttonStyle(.plain)
            .help("Markdown Önizleme (⌘P)")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.04))
        .cornerRadius(7)
        .padding(.horizontal, 10)
        .padding(.bottom, 3)
    }

    private func formatButton(symbol: String, tooltip: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 11.5, weight: .medium))
                .foregroundColor(localColor.secondaryTextColor)
                .frame(width: 24, height: 24)
                .background(Color.black.opacity(0.04))
                .cornerRadius(5)
        }
        .buttonStyle(.plain)
        .help(tooltip)
    }

    private func insertMarkdown(prefix: String, suffix: String, placeholder: String) {
        if isMarkdownPreview {
            isMarkdownPreview = false
        }
        if localBody.isEmpty {
            localBody = "\(prefix)\(placeholder)\(suffix)"
        } else {
            if prefix.hasPrefix("\n") {
                localBody += "\(prefix)\(placeholder)\(suffix)"
            } else {
                localBody += " \(prefix)\(placeholder)\(suffix)"
            }
        }
        persistChanges()
    }

    private func insertCallout(type: CalloutType) {
        let isTr = loc.language == .turkish
        let title = type.defaultTitle(isTurkish: isTr)
        let sample = isTr ? "Açıklama veya detay metni..." : "Details or description text..."
        let calloutText = "> [!\(type.rawValue.uppercased())] \(title)\n> \(sample)"
        insertRawMarkdown(calloutText)
        aiStatusMessage = isTr ? "\(title) kutusu eklendi ✨" : "\(title) callout added ✨"
    }

    private func insertRawMarkdown(_ text: String) {
        if isMarkdownPreview {
            isMarkdownPreview = false
        }
        if localBody.isEmpty {
            localBody = text
        } else {
            localBody += "\n\n\(text)\n"
        }
        persistChanges()
    }

    // MARK: - Footer Bar

    private var footerBar: some View {
        HStack(spacing: 6) {
            let wordCount = localBody.split { $0.isWhitespace || $0.isNewline }.count
            let charCount = localBody.count

            Text("\(wordCount)w · \(charCount)c")
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(localColor.secondaryTextColor.opacity(0.85))

            Spacer()

            // Flip through notes (< and >)
            HStack(spacing: 4) {
                Button(action: { store.cycleNote(forward: false) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(localColor.secondaryTextColor)
                        .frame(width: 22, height: 22)
                        .background(Color.black.opacity(0.04))
                        .cornerRadius(4)
                }
                .buttonStyle(.plain)
                .help("Previous Note (⌘[)")

                Button(action: { store.cycleNote(forward: true) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(localColor.secondaryTextColor)
                        .frame(width: 22, height: 22)
                        .background(Color.black.opacity(0.04))
                        .cornerRadius(4)
                }
                .buttonStyle(.plain)
                .help("Next Note (⌘])")
            }

            Spacer()

            // Quick Actions
            HStack(spacing: 10) {
                // Screenshot
                Button(action: captureScreenshot) {
                    Image(systemName: "camera")
                        .font(.system(size: 13))
                        .foregroundColor(localColor.secondaryTextColor)
                        .frame(width: 24, height: 24)
                        .background(Color.black.opacity(0.04))
                        .cornerRadius(5)
                }
                .buttonStyle(.plain)
                .help(loc.text(.captureScreen))

                // Paste Image from Clipboard
                Button(action: {
                    if !pasteImageFromClipboard() {
                        aiStatusMessage = loc.language == .turkish ? "Panoda görsel bulunamadı" : "No image found on clipboard"
                    }
                }) {
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 13))
                        .foregroundColor(localColor.secondaryTextColor)
                        .frame(width: 24, height: 24)
                        .background(Color.black.opacity(0.04))
                        .cornerRadius(5)
                }
                .buttonStyle(.plain)
                .help(loc.language == .turkish ? "Panodaki Görseli Yapıştır" : "Paste Image from Clipboard")

                // Screen OCR
                Button(action: captureScreenOCR) {
                    Image(systemName: "text.viewfinder")
                        .font(.system(size: 13))
                        .foregroundColor(isPerformingOCR ? Color.accentColor : localColor.secondaryTextColor)
                        .frame(width: 24, height: 24)
                        .background(isPerformingOCR ? Color.accentColor.opacity(0.15) : Color.black.opacity(0.04))
                        .cornerRadius(5)
                }
                .buttonStyle(.plain)
                .help(loc.language == .turkish ? "Ekrandan Metin Yakala (OCR)" : "Capture Screen Text (OCR)")

                // Checklist
                Button(action: insertChecklistItem) {
                    Image(systemName: "checkmark.square")
                        .font(.system(size: 13))
                        .foregroundColor(localColor.secondaryTextColor)
                        .frame(width: 24, height: 24)
                        .background(Color.black.opacity(0.04))
                        .cornerRadius(5)
                }
                .buttonStyle(.plain)
                .help("Insert Checklist Item")

                // Markdown Preview Toggle
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isMarkdownPreview.toggle()
                    }
                }) {
                    Image(systemName: isMarkdownPreview ? "pencil.circle.fill" : "eye")
                        .font(.system(size: 13))
                        .foregroundColor(isMarkdownPreview ? Color.accentColor : localColor.secondaryTextColor)
                        .frame(width: 24, height: 24)
                        .background(isMarkdownPreview ? Color.accentColor.opacity(0.15) : Color.black.opacity(0.04))
                        .cornerRadius(5)
                }
                .buttonStyle(.plain)
                .help(isMarkdownPreview ? (loc.language == .turkish ? "Düzenleme Modu (⌘P)" : "Edit Mode (⌘P)") : (loc.language == .turkish ? "Markdown Önizleme (⌘P)" : "Markdown Preview (⌘P)"))

                // Reminder
                Button(action: { showReminderPopover.toggle() }) {
                    Image(systemName: currentNote?.reminderDate != nil ? "bell.fill" : "bell")
                        .font(.system(size: 13))
                        .foregroundColor(currentNote?.reminderDate != nil ? Color.orange : localColor.secondaryTextColor)
                        .frame(width: 24, height: 24)
                        .background(currentNote?.reminderDate != nil ? Color.orange.opacity(0.15) : Color.black.opacity(0.04))
                        .cornerRadius(5)
                }
                .buttonStyle(.plain)
                .help("Set Reminder")
                .popover(isPresented: $showReminderPopover) {
                    reminderPopoverContent
                }

                // Apple Pencil
                Button(action: { showPencilDrawing = true }) {
                    Image(systemName: "pencil.tip.crop.circle")
                        .font(.system(size: 13))
                        .foregroundColor(localColor.secondaryTextColor)
                        .frame(width: 24, height: 24)
                        .background(Color.black.opacity(0.04))
                        .cornerRadius(5)
                }
                .buttonStyle(.plain)
                .help("Freehand Sketch & Canvas")

                // More Menu (All extra features cleanly accessible)
                Menu {
                    Button(action: { AllNotesWindowManager.shared.show() }) {
                        Label(loc.language == .turkish ? "Ana Pencereyi Aç (Tüm Notlar)" : "Open Main Dashboard (All Notes)", systemImage: "macwindow.on.rectangle")
                    }

                    Divider()

                    Button(action: { showTablePopover = true }) {
                        Label(loc.language == .turkish ? "Tablo Ekle (Matris / Şablon)..." : "Insert Table (Grid / Presets)...", systemImage: "tablecells")
                    }

                    Button(action: {
                        withAnimation {
                            showMarkdownFormatBar.toggle()
                        }
                    }) {
                        Label(showMarkdownFormatBar ? (loc.language == .turkish ? "Format Çubuğunu Gizle" : "Hide Format Bar") : (loc.language == .turkish ? "Format Çubuğunu Göster" : "Show Format Bar"), systemImage: "textformat")
                    }

                    Divider()

                    Button(action: { isCodeMode.toggle() }) {
                        Label(isCodeMode ? "Disable Code Mode" : "Enable Code Mode", systemImage: "chevron.left.forwardslash.chevron.right")
                    }

                    Button(action: { showOpacityPopover.toggle() }) {
                        Label("Transparency (\(Int(opacity * 100))%)", systemImage: "circle.lefthalf.filled")
                    }

                    Button(action: extractOCRFromAttachmentsOrFile) {
                        Label(loc.language == .turkish ? "Ek/Dosyadan Metin Çıkar (OCR)" : "Extract OCR from Attachments", systemImage: "doc.text.viewfinder")
                    }

                    Divider()

                    // Export Options Submenu
                    Menu {
                        Button(action: exportAsPDF) {
                            Label(loc.language == .turkish ? "📄 PDF Belgesi Olarak Kaydet (.pdf)..." : "Save as PDF Document (.pdf)...", systemImage: "doc.richtext")
                        }
                        Button(action: exportAsHTML) {
                            Label(loc.language == .turkish ? "🌐 Web Sayfası Olarak Kaydet (.html)..." : "Save as HTML (.html)...", systemImage: "globe")
                        }
                        Button(action: exportAsMarkdown) {
                            Label(loc.language == .turkish ? "📝 Markdown Olarak Kaydet (.md)..." : "Save as Markdown (.md)...", systemImage: "text.alignleft")
                        }
                        Button(action: exportAsRTF) {
                            Label(loc.language == .turkish ? "📑 Zengin Metin Olarak Kaydet (.rtf)..." : "Save as Rich Text (.rtf)...", systemImage: "doc.text")
                        }

                        Divider()

                        Button(action: printCurrentNote) {
                            Label(loc.language == .turkish ? "🖨️ Yazdır / macOS PDF... [⌘P]" : "Print / PDF... [⌘P]", systemImage: "printer")
                        }

                        Divider()

                        Button(action: exportToCalendar) {
                            Label("Add to Calendar (.ics)", systemImage: "calendar")
                        }

                        Button(action: sendToAppleNotes) {
                            Label("Export to Apple Notes", systemImage: "apple.logo")
                        }

                        Button(action: sendToReminders) {
                            Label("Export to Apple Reminders", systemImage: "checklist")
                        }
                    } label: {
                        Label(loc.language == .turkish ? "Dışa Aktar..." : "Export...", systemImage: "square.and.arrow.up")
                    }

                    Button(action: copyToClipboard) {
                        Label("Copy Note", systemImage: copiedFeedback ? "checkmark" : "doc.on.doc")
                    }

                    Button(action: shareNote) {
                        Label("Share...", systemImage: "square.and.arrow.up")
                    }

                    Divider()

                    Button(action: archiveNote) {
                        Label(loc.text(.archive), systemImage: "archivebox")
                    }

                    Button(role: .destructive, action: {
                        store.deleteNote(id: noteId)
                        onClose()
                    }) {
                        Label(loc.language == .turkish ? "Notu Sil" : "Delete Note", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 13))
                        .foregroundColor(localColor.secondaryTextColor)
                        .frame(width: 24, height: 24)
                        .background(Color.black.opacity(0.04))
                        .cornerRadius(5)
                }
                .menuStyle(.borderlessButton)
                .help("More Actions")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.04))
    }

    // MARK: - Apple Intelligence Actions

    private func applyAICleanMessyNote() {
        let isTurkish = (loc.language == .turkish)
        let cleaned = SmartAIService.shared.cleanAndFormatMessyNote(text: localBody, isTurkish: isTurkish)
        if !cleaned.isEmpty {
            localBody = cleaned
            aiStatusMessage = isTurkish ? "Dağınık not düzenlendi & biçimlendirildi ✨" : "Messy note organized & structured ✨"
        }
    }

    private func applyAISmartSummary() {
        let isTurkish = (loc.language == .turkish)
        let summary = SmartAIService.shared.smartSummary(text: localBody, isTurkish: isTurkish)
        if !summary.isEmpty {
            localBody = "\(summary)\n\n---\n\n\(localBody)"
            aiStatusMessage = isTurkish ? "Akıllı özet nota eklendi" : "Smart summary added to note"
        }
    }

    private func applyAISummarize() {
        let isTurkish = (loc.language == .turkish)
        let summary = SmartAIService.shared.smartSummary(text: localBody, isTurkish: isTurkish)
        if !summary.isEmpty {
            localBody = "\(summary)\n\n---\n\n\(localBody)"
            aiStatusMessage = isTurkish ? "AI Özeti nota eklendi" : "AI Summary added to top of note"
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

    // MARK: - Media & Hardware Actions

    private func captureScreenOCR() {
        isPerformingOCR = true
        Task {
            aiStatusMessage = loc.language == .turkish ? "Ekrandan metin alanı seçin..." : "Select screen area with text..."
            let text = await OCRService.shared.captureScreenAndExtractText()
            isPerformingOCR = false
            if !text.isEmpty {
                if localBody.isEmpty {
                    localBody = text
                } else {
                    localBody += "\n\n" + text
                }
                persistChanges()
                aiStatusMessage = loc.language == .turkish ? "Metin ekrandan yakalandı & kopyalandı! ✨" : "Text captured & copied to clipboard! ✨"
            } else {
                aiStatusMessage = loc.language == .turkish ? "Metin bulunamadı veya iptal edildi" : "No text found or cancelled"
            }
        }
    }

    private func captureScreenshot() {
        Task {
            if let screenshotURL = await ScreenshotService.shared.captureInteractiveScreenshot(noteId: noteId) {
                let attachmentName = screenshotURL.lastPathComponent
                let attachment = NoteAttachment(
                    fileName: attachmentName,
                    relativePath: attachmentName,
                    mimeType: "image/png"
                )
                store.addAttachment(noteId: noteId, attachment: attachment)

                if localBody.isEmpty {
                    localBody = "![\(attachmentName)](\(attachmentName))"
                } else {
                    localBody += "\n\n![\(attachmentName)](\(attachmentName))\n"
                }
                persistChanges()
                aiStatusMessage = loc.language == .turkish ? "Ekran resmi nota eklendi" : "Screenshot attached to note"
            }
        }
    }

    private func extractOCRFromAttachmentsOrFile() {
        isPerformingOCR = true
        Task {
            var extractedTexts: [String] = []
            let attachDir = store.attachmentsDirectory

            let pattern = "!\\[.*?\\]\\((.*?)\\)"
            if let regex = try? NSRegularExpression(pattern: pattern) {
                let nsString = localBody as NSString
                let matches = regex.matches(in: localBody, range: NSRange(location: 0, length: nsString.length))
                for match in matches {
                    if match.numberOfRanges > 1 {
                        let path = nsString.substring(with: match.range(at: 1))
                        let fullURL = attachDir.appendingPathComponent(path)
                        if FileManager.default.fileExists(atPath: fullURL.path) {
                            let text = await OCRService.shared.extractText(from: fullURL)
                            if !text.isEmpty {
                                extractedTexts.append(text)
                            }
                        }
                    }
                }
            }

            if extractedTexts.isEmpty {
                let panel = NSOpenPanel()
                panel.canChooseFiles = true
                panel.canChooseDirectories = false
                panel.allowsMultipleSelection = false
                panel.prompt = "Select Image for OCR"
                if panel.runModal() == .OK, let fileURL = panel.url {
                    let text = await OCRService.shared.extractText(from: fileURL)
                    if !text.isEmpty {
                        extractedTexts.append(text)
                    }
                }
            }

            isPerformingOCR = false
            if !extractedTexts.isEmpty {
                let combined = extractedTexts.joined(separator: "\n\n")
                localBody += "\n\n### 📝 OCR Text:\n\(combined)\n"
                aiStatusMessage = "Extracted text via Apple Vision OCR"
            } else {
                aiStatusMessage = "No text detected or no image found"
            }
        }
    }

    private func toggleVoiceRecording() {
        if audioService.isRecording {
            let (savedURL, transcript) = audioService.stopRecording()
            isRecordingVoice = false

            if let fileURL = savedURL {
                let fileName = fileURL.lastPathComponent
                let attachment = NoteAttachment(
                    fileName: fileName,
                    relativePath: fileName,
                    mimeType: "audio/x-caf"
                )
                store.addAttachment(noteId: noteId, attachment: attachment)
            }

            if !transcript.isEmpty {
                if localBody.isEmpty {
                    localBody = "🎙️ \(transcript)"
                } else {
                    localBody += "\n\n🎙️ \(transcript)\n"
                }
            }
            persistChanges()
            aiStatusMessage = loc.language == .turkish ? "Ses kaydı & transkript eklendi" : "Audio recording & transcript attached"
        } else {
            Task {
                let granted = await audioService.requestPermissions()
                guard granted else {
                    aiStatusMessage = loc.language == .turkish ? "Mikrofon ve konuşma tanıma izni gerekli" : "Microphone & speech recognition permission required"
                    return
                }
                let started = audioService.startRecording(language: loc.language) { _ in }
                if started {
                    isRecordingVoice = true
                    aiStatusMessage = loc.language == .turkish ? "Ses kaydediliyor... (Bitirmek için tekrar basın)" : "Recording audio... (Click again to stop)"
                } else {
                    isRecordingVoice = false
                    aiStatusMessage = loc.language == .turkish ? "Ses kaydı başlatılamadı (Giriş cihazı bulunamadı)" : "Failed to start recording (No audio input device)"
                }
            }
        }
    }

    @discardableResult
    private func pasteImageFromClipboard() -> Bool {
        let pb = NSPasteboard.general
        if let image = NSImage(pasteboard: pb) {
            if let tiffData = image.tiffRepresentation,
               let bitmap = NSBitmapImageRep(data: tiffData),
               let pngData = bitmap.representation(using: .png, properties: [:]) {
                let fileName = "Pasted_\(Int(Date().timeIntervalSince1970)).png"
                let targetURL = store.attachmentsDirectory.appendingPathComponent(fileName)
                try? pngData.write(to: targetURL)

                let attachment = NoteAttachment(
                    fileName: fileName,
                    relativePath: fileName,
                    mimeType: "image/png"
                )
                store.addAttachment(noteId: noteId, attachment: attachment)

                if localBody.isEmpty {
                    localBody = "![\(fileName)](\(fileName))"
                } else {
                    localBody += "\n\n![\(fileName)](\(fileName))\n"
                }
                persistChanges()
                aiStatusMessage = loc.language == .turkish ? "Görsel yapıştırıldı" : "Image pasted"
                return true
            }
        }
        return false
    }

    private func toggleFavorite() {
        isFavorite.toggle()
        store.toggleFavorite(noteId: noteId)
    }

    private func exportToCalendar() {
        guard let note = currentNote else { return }
        CalendarSyncService.shared.openInCalendarApp(note: note)
        aiStatusMessage = loc.language == .turkish ? "Takvim etkinliği oluşturuldu (.ics)" : "Calendar event generated (.ics)"
    }

    private func exportAsPDF() {
        guard let note = currentNote else { return }
        ExportService.shared.promptSaveNoteAsPDF(note: note)
        aiStatusMessage = loc.language == .turkish ? "PDF dışa aktarma hazırlandı" : "PDF export prepared"
    }

    private func exportAsHTML() {
        guard let note = currentNote else { return }
        ExportService.shared.promptSaveNoteAsHTML(note: note)
        aiStatusMessage = loc.language == .turkish ? "HTML dışa aktarma hazırlandı" : "HTML export prepared"
    }

    private func exportAsMarkdown() {
        guard let note = currentNote else { return }
        ExportService.shared.promptSaveNoteAsMarkdown(note: note)
        aiStatusMessage = loc.language == .turkish ? "Markdown dışa aktarma hazırlandı" : "Markdown export prepared"
    }

    private func exportAsRTF() {
        guard let note = currentNote else { return }
        ExportService.shared.promptSaveNoteAsRTF(note: note)
        aiStatusMessage = loc.language == .turkish ? "RTF dışa aktarma hazırlandı" : "RTF export prepared"
    }

    private func printCurrentNote() {
        guard let note = currentNote else { return }
        ExportService.shared.printNote(note: note)
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
        self.isFavorite = note.isFavorite
        if let rem = note.reminderDate {
            self.reminderDate = rem
        }
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
        note.isFavorite = isFavorite
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
        NoteWindowManager.shared.updatePin(id: noteId, isPinned: isPinned)
        persistChanges()
    }

    private func archiveNote() {
        store.archiveNote(id: noteId)
        DispatchQueue.main.async {
            self.onClose()
        }
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
                            let fileName = "\(Int(Date().timeIntervalSince1970))_\(url.lastPathComponent)"
                            let dest = self.store.attachmentsDirectory.appendingPathComponent(fileName)
                            try? FileManager.default.copyItem(at: url, to: dest)
                            let att = NoteAttachment(fileName: fileName, relativePath: fileName, mimeType: "image/png")
                            self.store.addAttachment(noteId: self.noteId, attachment: att)
                            self.localBody += "\n\n![\(fileName)](\(fileName))\n"
                            self.persistChanges()
                        }
                    }
                }
                return true
            }
        }
        return false
    }
}
