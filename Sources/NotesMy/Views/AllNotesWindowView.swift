import SwiftUI
import AppKit

public struct AllNotesWindowView: View {
    @ObservedObject var store = NoteStore.shared
    @ObservedObject var loc = LocalizationService.shared

    @State private var searchText: String = ""
    @State private var selectedFilter: NoteFilter = .active
    @State private var selectedCategory: String = "All"
    @State private var selectedColorFilter: NoteColor? = nil
    @State private var selectedNoteId: UUID? = NoteStore.shared.activeNotes.first?.id
    @State private var viewMode: ViewMode = .list
    @State private var isSemanticSearchEnabled: Bool = false

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

    public init() {}

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
                        .navigationSplitViewColumnWidth(min: 280, ideal: 320, max: 440)
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
            if let id = selectedNoteId, !filteredNotes.contains(where: { $0.id == id }) {
                selectedNoteId = filteredNotes.first?.id
            }
        }
        .onChange(of: filteredNotes) { newNotes in
            if let id = selectedNoteId, !newNotes.contains(where: { $0.id == id }) {
                selectedNoteId = newNotes.first?.id
            }
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
                // Web Clipper
                Button(action: clipWebURL) {
                    Label("Web Clip", systemImage: "globe")
                }
                .help("Clip URL from Clipboard")

                // iCloud Sync Button
                Button(action: {
                    Task {
                        await cloudKit.syncNotes()
                    }
                }) {
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
                    Button("Export as Markdown (.md)") {
                        exportMarkdown()
                    }
                    Button("Export as Single Document (.txt)") {
                        exportSingleDocument()
                    }
                    Divider()
                    Button(loc.text(.sendToAppleNotes)) {
                        if let id = selectedNoteId, let note = store.notes.first(where: { $0.id == id }) {
                            AppleNotesService.shared.sendToAppleNotes(title: note.displayTitle, body: note.body)
                        }
                    }
                } label: {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
            }
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

            // Segmented Filter Picker (Active, Favorites, Pinned, Tasks, Archived, All)
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
                    }
                }
                .padding(.horizontal, 10)
            }

            // Categories Filter (SideNotes inspired)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    categoryButton(title: "All")
                    ForEach(store.categories, id: \.self) { cat in
                        categoryButton(title: cat)
                    }
                }
                .padding(.horizontal, 10)
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

            // Notes List
            List(filteredNotes, selection: $selectedNoteId) { note in
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(note.color.dotColor)
                        .frame(width: 4, height: 42)

                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text(note.displayTitle)
                                .font(.system(size: 12, weight: .semibold, design: note.isCodeMode ? .monospaced : .default))
                                .lineLimit(1)

                            Spacer()

                            if note.isFavorite {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 9))
                                    .foregroundColor(.yellow)
                            }

                            if note.isPinned {
                                Image(systemName: "pin.fill")
                                    .font(.system(size: 9))
                                    .foregroundColor(Color.accentColor)
                            }

                            if note.isCodeMode {
                                Image(systemName: "chevron.left.forwardslash.chevron.right")
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                            }
                        }

                        Text(note.previewSnippet)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .lineLimit(1)

                        HStack(spacing: 6) {
                            Text(loc.localizedCategory(note.category))
                                .font(.system(size: 9, weight: .medium))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color.secondary.opacity(0.15))
                                .cornerRadius(3)

                            if let progress = note.checklistProgress {
                                Text("\(progress.completed)/\(progress.total) ☑️")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(.secondary)
                            }

                            if let reminder = note.reminderDate {
                                HStack(spacing: 2) {
                                    Image(systemName: "bell.fill")
                                    Text(reminder.formatted(date: .omitted, time: .shortened))
                                }
                                .font(.system(size: 8, weight: .semibold))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color.orange.opacity(0.15))
                                .foregroundColor(.orange)
                                .cornerRadius(3)
                            }

                            Text(note.updatedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)

                            if note.isArchived {
                                Text(loc.text(.filterArchived))
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, 4)
                                    .background(Color.orange.opacity(0.12))
                                    .cornerRadius(3)
                            }
                        }
                    }
                }
                .tag(note.id)
            }
            .listStyle(.sidebar)
            .frame(minHeight: 250, maxHeight: .infinity)

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
        .frame(minWidth: 300)
    }

    private func categoryButton(title: String) -> some View {
        let isSelected = selectedCategory == title
        let displayTitle = loc.localizedCategory(title)
        return Button(action: {
            selectedCategory = title
        }) {
            Text(displayTitle)
                .font(.system(size: 11, weight: isSelected ? .bold : .regular))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
                .foregroundColor(isSelected ? Color.accentColor : Color.secondary)
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Detail Pane

    private var detailContent: some View {
        Group {
            if let noteId = selectedNoteId, store.notes.contains(where: { $0.id == noteId }) {
                NoteEditorView(noteId: noteId, store: store) {
                    selectedNoteId = nil
                }
                .padding(16)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "note.text")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("Select a note to view or edit")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    // MARK: - Export Helpers

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

    private func clipWebURL() {
        if let note = WebClipperService.shared.clipCurrentURLFromPasteboard() {
            selectedNoteId = note.id
            viewMode = .list
        }
    }
}
