import SwiftUI
import AppKit

public struct AllNotesWindowView: View {
    @ObservedObject var store = NoteStore.shared
    @ObservedObject var loc = LocalizationService.shared

    @State private var searchText: String = ""
    @State private var selectedFilter: NoteFilter
    @State private var selectedCategory: String = "All"
    @State private var selectedColorFilter: NoteColor? = nil
    @State private var selectedNoteId: UUID? = NoteStore.shared.activeNotes.first?.id
    @State private var viewMode: ViewMode = .list
    @State private var isSemanticSearchEnabled: Bool = false
    @State private var showNewCategoryAlert: Bool = false
    @State private var newCategoryName: String = ""
    @State private var showWebClipAlert: Bool = false
    @State private var webClipURLText: String = ""
    @State private var showStaleBanner: Bool = true
    @State private var keyMonitor: Any? = nil

    @ObservedObject var cloudKit = CloudKitSyncService.shared

    public enum ViewMode: String, CaseIterable, Identifiable {
        case list = "List View"
        case board = "Sticky Board"
        case graph = "Knowledge Graph"
        case secondBrain = "AI Second Brain"
        public var id: String { rawValue }
    }

    public enum NoteFilter: String, CaseIterable, Identifiable {
        case active = "Active"
        case favorites = "Favorites"
        case pinned = "Pinned"
        case checklists = "Tasks"
        case archived = "Archived"
        case all = "All"

        public var id: String { rawValue }

        @MainActor
        public func title(loc: LocalizationService) -> String {
            switch self {
            case .active: return loc.text(.filterActive)
            case .favorites: return "⭐ \(loc.text(.favorites))"
            case .pinned: return "📌 \(loc.text(.pinned))"
            case .checklists: return "☑️ Checklist"
            case .archived: return loc.text(.filterArchived)
            case .all: return loc.text(.filterAll)
            }
        }
    }

    public init(initialFilter: NoteFilter = .active, initialViewMode: ViewMode = .list) {
        _selectedFilter = State(initialValue: initialFilter)
        _viewMode = State(initialValue: initialViewMode)
        if initialFilter == .archived {
            _selectedNoteId = State(initialValue: NoteStore.shared.archivedNotes.first?.id)
        }
    }

    private var filteredNotes: [NoteItem] {
        var baseNotes = store.notes

        switch selectedFilter {
        case .active:
            baseNotes = baseNotes.filter { !$0.isArchived }
        case .favorites:
            baseNotes = baseNotes.filter { !$0.isArchived && $0.isFavorite }
        case .pinned:
            baseNotes = baseNotes.filter { !$0.isArchived && $0.isPinned }
        case .checklists:
            baseNotes = baseNotes.filter { !$0.isArchived && !$0.checklistItems.isEmpty }
        case .archived:
            baseNotes = baseNotes.filter { $0.isArchived }
        case .all:
            break
        }

        var filters = SearchFilters()
        filters.query = searchText
        filters.category = selectedCategory
        filters.color = selectedColorFilter
        filters.isSemanticSearchEnabled = isSemanticSearchEnabled

        return SearchEngine.shared.search(notes: baseNotes, with: filters)
    }

    public var body: some View {
        Group {
            switch viewMode {
            case .list:
                NavigationSplitView {
                    sidebarContent
                        .navigationSplitViewColumnWidth(min: 300, ideal: 340, max: 480)
                } detail: {
                    detailContent
                }
            case .board:
                StickyBoardView()
            case .graph:
                KnowledgeGraphView()
            case .secondBrain:
                SecondBrainChatView()
            }
        }
        .frame(minWidth: 800, minHeight: 540)
        .onChange(of: selectedFilter) { _ in
            ensureValidSelection()
        }
        .onChange(of: searchText) { _ in
            ensureValidSelection()
        }
        .onChange(of: selectedCategory) { _ in
            ensureValidSelection()
        }
        .alert(loc.language == .turkish ? "Yeni Kategori Ekle" : "Add New Category", isPresented: $showNewCategoryAlert) {
            TextField(loc.language == .turkish ? "Kategori Adı" : "Category Name", text: $newCategoryName)
            Button(loc.language == .turkish ? "Ekle" : "Add") {
                let clean = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
                if !clean.isEmpty {
                    store.addCategory(clean)
                    selectedCategory = clean
                }
            }
            Button(loc.language == .turkish ? "İptal" : "Cancel", role: .cancel) {}
        }
        .alert(loc.language == .turkish ? "Web Bağlantısı Kırp" : "Web Clip URL", isPresented: $showWebClipAlert) {
            TextField("https://...", text: $webClipURLText)
            Button(loc.language == .turkish ? "Kırp ve Ekle" : "Clip & Add") {
                clipEnteredURL()
            }
            Button(loc.language == .turkish ? "İptal" : "Cancel", role: .cancel) {}
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Picker("View Mode", selection: $viewMode) {
                    Label("List", systemImage: "list.bullet").tag(ViewMode.list)
                    Label(loc.text(.stickyBoard), systemImage: "square.grid.3x3.fill").tag(ViewMode.board)
                    Label("Graph", systemImage: "circle.hexagongrid.fill").tag(ViewMode.graph)
                    Label("Second Brain", systemImage: "brain.head.profile").tag(ViewMode.secondBrain)
                }
                .pickerStyle(.segmented)
            }

            ToolbarItemGroup(placement: .primaryAction) {
                // Meeting Studio Launcher
                Button(action: {
                    MeetingStudioWindowManager.shared.show()
                }) {
                    Label(loc.language == .turkish ? "Toplantı Stüdyosu" : "Meeting Studio", systemImage: "person.2.wave.2")
                }
                .help(loc.language == .turkish ? "Toplantı Modu: Ekran Sesi, Mikrofon & EA Transkripsiyon" : "Meeting Studio: Screen Audio, Mic & AI Transcription")

                // Screen Text OCR
                Button(action: {
                    Task {
                        let text = await OCRService.shared.captureScreenAndExtractText()
                        if !text.isEmpty {
                            let note = store.createNote(
                                title: String(text.prefix(30)),
                                body: text,
                                category: selectedCategory == "All" ? "General" : selectedCategory
                            )
                            selectedNoteId = note.id
                            viewMode = .list
                        }
                    }
                }) {
                    Label(loc.language == .turkish ? "Ekrandan Metin Yakala (OCR)" : "Capture Screen OCR", systemImage: "text.viewfinder")
                }
                .help(loc.language == .turkish ? "Ekrandan Metin Yakala (OCR)" : "Capture Screen OCR")

                // Web Clipper
                Button(action: handleWebClipButton) {
                    Label("Web Clip", systemImage: "globe")
                }
                .help(loc.language == .turkish ? "Panodaki veya girilen URL'yi Kırp" : "Clip URL from Clipboard or Input")

                // iCloud & Local Backup Menu
                Menu {
                    Section(header: Text(cloudKit.syncStatusMessage)) {
                        Button(loc.language == .turkish ? "📁 Notlar Klasörünü Finder'da Aç" : "Show Notes in Finder") {
                            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: store.attachmentsDirectory.deletingLastPathComponent().path)
                        }
                        Button(loc.language == .turkish ? "💾 Manuel Yedek Dosyası Al (.txt)" : "Export All Notes (.txt)") {
                            exportSingleDocument()
                        }
                        Button(loc.language == .turkish ? "📤 Markdown Olarak Dışa Aktar" : "Export as Markdown (.md)") {
                            exportMarkdown()
                        }
                        Divider()
                        Button(loc.language == .turkish ? "🔄 Senkronizasyonu Kontrol Et" : "Check iCloud Sync") {
                            Task {
                                await cloudKit.syncNotes()
                            }
                        }
                    }
                } label: {
                    Label(cloudKit.syncStatusMessage, systemImage: cloudKit.isSyncing ? "arrow.triangle.2.circlepath" : "icloud")
                }
                .help(cloudKit.syncStatusMessage)

                Button(action: {
                    let note = store.createNote(category: selectedCategory == "All" ? "General" : selectedCategory)
                    selectedNoteId = note.id
                    viewMode = .list
                }) {
                    Label(loc.text(.newNote), systemImage: "plus")
                }
                .help("Create Note (⌥⌘N)")

                Menu {
                    Button(loc.language == .turkish ? "📄 Tüm Notları PDF Olarak Kaydet (.pdf)..." : "Export All Notes as PDF (.pdf)...") {
                        exportAllAsPDF()
                    }
                    Button(loc.language == .turkish ? "📤 Markdown Klasörü Olarak Dışa Aktar (.md)" : "Export as Markdown (.md)") {
                        exportMarkdown()
                    }
                    Button(loc.language == .turkish ? "💾 Tek Metin Belgesi Olarak Dışa Aktar (.txt)" : "Export as Single Document (.txt)") {
                        exportSingleDocument()
                    }
                    Divider()
                    Button(loc.text(.sendToAppleNotes)) {
                        if let id = selectedNoteId, let note = store.notes.first(where: { $0.id == id }) {
                            AppleNotesService.shared.sendToAppleNotes(title: note.displayTitle, body: note.body)
                        }
                    }
                } label: {
                    Label(loc.language == .turkish ? "Dışa Aktar" : "Export", systemImage: "square.and.arrow.up")
                }
            }
        }
        .onAppear {
            setupKeyMonitor()
        }
        .onDisappear {
            removeKeyMonitor()
        }
    }

    // MARK: - Sidebar

    private var sidebarContent: some View {
        VStack(spacing: 8) {
            // Search field with Semantic Search Toggle
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField(loc.text(.searchPlaceholder), text: $searchText)
                    .textFieldStyle(.plain)

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                // Semantic Search Toggle Button
                Button(action: { isSemanticSearchEnabled.toggle() }) {
                    Image(systemName: isSemanticSearchEnabled ? "sparkles.rectangle.stack.fill" : "sparkles")
                        .font(.system(size: 12))
                        .foregroundColor(isSemanticSearchEnabled ? .purple : .secondary)
                }
                .buttonStyle(.plain)
                .help("Semantic Search (AI Concept & Synonym Search)")
            }
            .padding(7)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)
            .padding(.horizontal, 10)
            .padding(.top, 8)

            if isSemanticSearchEnabled {
                HStack {
                    Image(systemName: "sparkles")
                        .font(.system(size: 9))
                    Text("Semantic AI search active")
                        .font(.system(size: 10, weight: .medium))
                    Spacer()
                }
                .foregroundColor(.purple)
                .padding(.horizontal, 12)
            }

            // Segmented Filter Picker (Active, Favorites, Pinned, Tasks, Archived, All) with chevrons
            HStack(spacing: 2) {
                Button(action: { selectPreviousFilter() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)
                        .padding(4)
                }
                .buttonStyle(.plain)
                .help(loc.language == .turkish ? "Önceki Filtre (⌥←)" : "Previous Filter (⌥←)")

                ScrollViewReader { filterProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(NoteFilter.allCases) { filter in
                                Button(action: { selectedFilter = filter }) {
                                    Text(filter.title(loc: loc))
                                        .font(.system(size: 11, weight: selectedFilter == filter ? .bold : .regular))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(selectedFilter == filter ? Color.accentColor.opacity(0.18) : Color.clear)
                                        .foregroundColor(selectedFilter == filter ? Color.accentColor : Color.secondary)
                                        .cornerRadius(6)
                                }
                                .buttonStyle(.plain)
                                .id(filter)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    .onChange(of: selectedFilter) { newFilter in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            filterProxy.scrollTo(newFilter, anchor: .center)
                        }
                    }
                }

                Button(action: { selectNextFilter() }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)
                        .padding(4)
                }
                .buttonStyle(.plain)
                .help(loc.language == .turkish ? "Sonraki Filtre (⌥→)" : "Next Filter (⌥→)")
            }
            .padding(.horizontal, 6)

            // Categories Filter Bar with Header, Navigation Chevrons & Add Button
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(loc.language == .turkish ? "Kategoriler" : "Categories")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)

                    Text(loc.language == .turkish ? "• ← / → ile kaydır" : "• ← / → to scroll")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary.opacity(0.7))

                    Spacer()

                    Button(action: {
                        newCategoryName = ""
                        showNewCategoryAlert = true
                    }) {
                        HStack(spacing: 2) {
                            Image(systemName: "plus")
                                .font(.system(size: 9, weight: .bold))
                            Text(loc.language == .turkish ? "Ekle" : "Add")
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.plain)
                    .help(loc.language == .turkish ? "Yeni Kategori Ekle" : "Add Category")
                }
                .padding(.horizontal, 12)

                HStack(spacing: 2) {
                    Button(action: { selectPreviousCategory() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.secondary)
                            .padding(4)
                    }
                    .buttonStyle(.plain)
                    .help(loc.language == .turkish ? "Önceki Kategori (←)" : "Previous Category (←)")

                    ScrollViewReader { catProxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 5) {
                                let totalCount = store.notes.filter { selectedFilter == .archived ? $0.isArchived : !$0.isArchived }.count
                                categoryButton(title: "All", count: totalCount)
                                    .id("All")

                                ForEach(store.categories, id: \.self) { cat in
                                    let catCount = store.notes.filter { $0.category == cat && (selectedFilter == .archived ? $0.isArchived : !$0.isArchived) }.count
                                    categoryButton(title: cat, count: catCount)
                                        .id(cat)
                                }
                            }
                            .padding(.horizontal, 4)
                            .padding(.vertical, 3)
                        }
                        .onChange(of: selectedCategory) { newCat in
                            withAnimation(.easeInOut(duration: 0.2)) {
                                catProxy.scrollTo(newCat, anchor: .center)
                            }
                        }
                    }

                    Button(action: { selectNextCategory() }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.secondary)
                            .padding(4)
                    }
                    .buttonStyle(.plain)
                    .help(loc.language == .turkish ? "Sonraki Kategori (→)" : "Next Category (→)")
                }
                .padding(.horizontal, 6)
            }

            // Color Filter Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    Button(action: { selectedColorFilter = nil }) {
                        Text("All Colors")
                            .font(.system(size: 11, weight: selectedColorFilter == nil ? .bold : .regular))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(selectedColorFilter == nil ? Color.accentColor.opacity(0.18) : Color.clear)
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)

                    ForEach(NoteColor.allCases) { color in
                        Button(action: {
                            if selectedColorFilter == color {
                                selectedColorFilter = nil
                            } else {
                                selectedColorFilter = color
                            }
                        }) {
                            Circle()
                                .fill(color.dotColor)
                                .frame(width: 14, height: 14)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColorFilter == color ? Color.primary : Color.clear, lineWidth: 1.5)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 10)
            }
            .padding(.vertical, 2)

            Divider()

            // Header showing count of notes
            HStack {
                Text("\(filteredNotes.count) \(loc.text(.allNotes).lowercased())")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 2)

            // Inactive / Stale Notes cleanup banner (>30 days)
            let staleCount = store.inactiveNotes(olderThanDays: 30).count
            if staleCount > 0 && showStaleBanner {
                HStack(spacing: 6) {
                    Image(systemName: "clock.badge.exclamationmark")
                        .foregroundColor(.orange)
                        .font(.system(size: 11))
                    Text(loc.language == .turkish ? "\(staleCount) eski not (>30 gün)" : "\(staleCount) stale notes (>30d)")
                        .font(.system(size: 10, weight: .medium))
                        .lineLimit(1)
                    Spacer()
                    Button(loc.language == .turkish ? "Arşivle" : "Archive") {
                        store.archiveInactiveNotes(olderThanDays: 30)
                    }
                    .font(.system(size: 9, weight: .semibold))
                    .buttonStyle(.bordered)
                    .controlSize(.mini)

                    Button(loc.language == .turkish ? "Sil" : "Delete") {
                        store.deleteInactiveNotes(olderThanDays: 30)
                    }
                    .font(.system(size: 9, weight: .semibold))
                    .buttonStyle(.bordered)
                    .controlSize(.mini)

                    Button(action: { showStaleBanner = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color.orange.opacity(0.12))
                .cornerRadius(6)
                .padding(.horizontal, 10)
            }

            // Scrollable Notes List
            ScrollView(.vertical, showsIndicators: true) {
                if filteredNotes.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "note.text")
                            .font(.system(size: 28))
                            .foregroundColor(.secondary.opacity(0.5))
                        Text("No notes found")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 160)
                    .padding(.top, 40)
                } else {
                    LazyVStack(spacing: 6) {
                        ForEach(filteredNotes) { note in
                            noteCardRow(note: note)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Undo banner if item deleted
            if let deleted = store.recentlyDeletedNote {
                HStack {
                    Text("Deleted \"\(deleted.displayTitle.prefix(15))\"")
                        .font(.system(size: 11))
                        .lineLimit(1)
                    Spacer()
                    Button(loc.text(.undo)) {
                        store.undoDelete()
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.accentColor)
                    .buttonStyle(.plain)
                }
                .padding(8)
                .background(Color.black.opacity(0.06))
                .cornerRadius(6)
                .padding(8)
            }
        }
        .frame(minWidth: 300, maxHeight: .infinity)
    }

    private func noteCardRow(note: NoteItem) -> some View {
        let isSelected = selectedNoteId == note.id
        return Button(action: {
            selectedNoteId = note.id
        }) {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(note.color.dotColor)
                    .frame(width: 4, height: 42)

                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(note.displayTitle)
                            .font(.system(size: 12, weight: .semibold, design: note.isCodeMode ? .monospaced : .default))
                            .foregroundColor(isSelected ? .white : .primary)
                            .lineLimit(1)

                        Spacer()

                        Button(action: {
                            store.toggleFavorite(noteId: note.id)
                        }) {
                            Image(systemName: note.isFavorite ? "star.fill" : "star")
                                .font(.system(size: 10))
                                .foregroundColor(note.isFavorite ? .yellow : (isSelected ? .white.opacity(0.6) : .secondary.opacity(0.4)))
                        }
                        .buttonStyle(.plain)
                        .help(note.isFavorite ? "Unfavorite" : "Favorite")

                        Button(action: {
                            store.deleteNote(id: note.id)
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 9))
                                .foregroundColor(isSelected ? .white.opacity(0.6) : .secondary.opacity(0.4))
                        }
                        .buttonStyle(.plain)
                        .help(loc.language == .turkish ? "Hızlı Sil" : "Quick Delete")

                        if note.isPinned {
                            Image(systemName: "pin.fill")
                                .font(.system(size: 9))
                                .foregroundColor(isSelected ? .white : Color.accentColor)
                        }

                        if note.isCodeMode {
                            Image(systemName: "chevron.left.forwardslash.chevron.right")
                                .font(.system(size: 9))
                                .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                        }
                    }

                    Text(note.previewSnippet)
                        .font(.system(size: 11))
                        .foregroundColor(isSelected ? .white.opacity(0.85) : .secondary)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Text(loc.localizedCategory(note.category))
                            .font(.system(size: 9, weight: .medium))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(isSelected ? Color.white.opacity(0.2) : Color.secondary.opacity(0.15))
                            .foregroundColor(isSelected ? .white : .primary)
                            .cornerRadius(3)

                        if let progress = note.checklistProgress {
                            Text("\(progress.completed)/\(progress.total) ☑️")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(isSelected ? .white.opacity(0.85) : .secondary)
                        }

                        if let reminder = note.reminderDate {
                            HStack(spacing: 2) {
                                Image(systemName: "bell.fill")
                                Text(reminder.formatted(date: .omitted, time: .shortened))
                            }
                            .font(.system(size: 8, weight: .semibold))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.orange.opacity(0.25))
                            .foregroundColor(.orange)
                            .cornerRadius(3)
                        }

                        Text(note.updatedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.system(size: 9))
                            .foregroundColor(isSelected ? .white.opacity(0.75) : .secondary)

                        if note.isArchived {
                            Text(loc.text(.filterArchived))
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.orange)
                                .padding(.horizontal, 4)
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(3)
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor : Color(nsColor: .controlBackgroundColor).opacity(0.65))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.clear : Color.primary.opacity(0.06), lineWidth: 0.5)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(note.isFavorite ? "Unfavorite" : "Favorite") {
                store.toggleFavorite(noteId: note.id)
            }
            Button(note.isPinned ? "Unpin" : "Pin") {
                store.togglePin(noteId: note.id)
            }
            Button(note.isArchived ? "Unarchive" : "Archive") {
                if note.isArchived {
                    store.unarchiveNote(id: note.id)
                } else {
                    store.archiveNote(id: note.id)
                }
            }
            Divider()
            Button(loc.language == .turkish ? "📄 PDF Olarak Kaydet..." : "Save as PDF...") {
                ExportService.shared.promptSaveNoteAsPDF(note: note)
            }
            Button(loc.language == .turkish ? "🌐 HTML Olarak Kaydet..." : "Save as HTML...") {
                ExportService.shared.promptSaveNoteAsHTML(note: note)
            }
            Button(loc.language == .turkish ? "📝 Markdown Olarak Kaydet..." : "Save as Markdown...") {
                ExportService.shared.promptSaveNoteAsMarkdown(note: note)
            }
            Button(loc.language == .turkish ? "🖨️ Yazdır / PDF..." : "Print / PDF...") {
                ExportService.shared.printNote(note: note)
            }
            Divider()
            Button(role: .destructive) {
                store.deleteNote(id: note.id)
            } label: {
                Text(loc.language == .turkish ? "Sil" : "Delete")
            }
        }
    }

    private func categoryButton(title: String, count: Int? = nil) -> some View {
        let isSelected = selectedCategory == title
        let displayTitle = loc.localizedCategory(title)
        return Button(action: {
            selectedCategory = title
        }) {
            HStack(spacing: 4) {
                Text(displayTitle)
                    .font(.system(size: 11, weight: isSelected ? .bold : .regular))
                if let count = count {
                    Text("\(count)")
                        .font(.system(size: 9, weight: isSelected ? .bold : .medium))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.18))
                        .foregroundColor(isSelected ? .white : .secondary)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(isSelected ? Color.accentColor.opacity(0.15) : Color.black.opacity(0.04))
            .foregroundColor(isSelected ? Color.accentColor : Color.primary)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
        .contextMenu {
            if title != "All" && title != "General" {
                Button(role: .destructive) {
                    store.removeCategory(title)
                    if selectedCategory == title {
                        selectedCategory = "All"
                    }
                } label: {
                    Text(loc.language == .turkish ? "Kategoriyi Sil" : "Delete Category")
                }
            }
        }
    }

    // MARK: - Detail Pane

    private var detailContent: some View {
        Group {
            if let noteId = selectedNoteId, store.notes.contains(where: { $0.id == noteId }) {
                NoteEditorView(noteId: noteId, store: store) {
                    selectedNoteId = filteredNotes.first(where: { $0.id != noteId })?.id
                }
                .padding(16)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "note.text")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text(loc.language == .turkish ? "Görüntülemek veya düzenlemek için bir not seçin" : "Select a note to view or edit")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    // MARK: - Export Helpers

    private func exportAllAsPDF() {
        ExportService.shared.promptExportAllAsPDF(notes: filteredNotes)
    }

    private func exportMarkdown() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.prompt = "Export Notes"

        if panel.runModal() == .OK, let folder = panel.url {
            try? store.exportNotesAsMarkdown(to: folder)
        }
    }

    private func exportSingleDocument() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.plainText]
        panel.nameFieldStringValue = "NotesMy_Export.txt"
        if panel.runModal() == .OK, let url = panel.url {
            try? store.exportAllAsSingleFile(to: url)
        }
    }

    private func handleWebClipButton() {
        if let note = WebClipperService.shared.clipCurrentURLFromPasteboard() {
            selectedNoteId = note.id
            viewMode = .list
        } else {
            webClipURLText = ""
            showWebClipAlert = true
        }
    }

    private func clipEnteredURL() {
        let clean = webClipURLText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: clean), clean.lowercased().hasPrefix("http") else { return }
        if let note = WebClipperService.shared.clipURL(url) {
            selectedNoteId = note.id
            viewMode = .list
        }
    }

    private func ensureValidSelection() {
        let currentFiltered = filteredNotes
        if let id = selectedNoteId, !currentFiltered.contains(where: { $0.id == id }) {
            selectedNoteId = currentFiltered.first?.id
        } else if selectedNoteId == nil {
            selectedNoteId = currentFiltered.first?.id
        }
    }

    // MARK: - Keyboard Arrow Navigation & Scrolling

    public func selectPreviousCategory() {
        let allCategories = ["All"] + store.categories
        guard let currentIdx = allCategories.firstIndex(of: selectedCategory) else {
            selectedCategory = "All"
            return
        }
        let prevIdx = (currentIdx - 1 + allCategories.count) % allCategories.count
        selectedCategory = allCategories[prevIdx]
    }

    public func selectNextCategory() {
        let allCategories = ["All"] + store.categories
        guard let currentIdx = allCategories.firstIndex(of: selectedCategory) else {
            selectedCategory = "All"
            return
        }
        let nextIdx = (currentIdx + 1) % allCategories.count
        selectedCategory = allCategories[nextIdx]
    }

    public func selectPreviousFilter() {
        let allFilters = NoteFilter.allCases
        guard let currentIdx = allFilters.firstIndex(of: selectedFilter) else { return }
        let prevIdx = (currentIdx - 1 + allFilters.count) % allFilters.count
        selectedFilter = allFilters[prevIdx]
    }

    public func selectNextFilter() {
        let allFilters = NoteFilter.allCases
        guard let currentIdx = allFilters.firstIndex(of: selectedFilter) else { return }
        let nextIdx = (currentIdx + 1) % allFilters.count
        selectedFilter = allFilters[nextIdx]
    }

    private func setupKeyMonitor() {
        if keyMonitor != nil { return }
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [self] event in
            // Don't intercept if user is actively typing in a text field
            if let responder = NSApp.keyWindow?.firstResponder {
                if responder is NSTextView || responder is NSTextField {
                    return event
                }
            }

            // Left Arrow (123)
            if event.keyCode == 123 {
                if event.modifierFlags.contains(.shift) || event.modifierFlags.contains(.option) {
                    selectPreviousFilter()
                } else {
                    selectPreviousCategory()
                }
                return nil
            }

            // Right Arrow (124)
            if event.keyCode == 124 {
                if event.modifierFlags.contains(.shift) || event.modifierFlags.contains(.option) {
                    selectNextFilter()
                } else {
                    selectNextCategory()
                }
                return nil
            }

            return event
        }
    }

    private func removeKeyMonitor() {
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
            keyMonitor = nil
        }
    }
}
