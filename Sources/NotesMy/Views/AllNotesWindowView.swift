import SwiftUI
import AppKit

public struct AllNotesWindowView: View {
    @ObservedObject var store = NoteStore.shared
    @State private var searchText: String = ""
    @State private var selectedFilter: NoteFilter = .active
    @State private var selectedCategory: String = "All"
    @State private var selectedColorFilter: NoteColor? = nil
    @State private var selectedNoteId: UUID? = NoteStore.shared.activeNotes.first?.id

    public enum NoteFilter: String, CaseIterable, Identifiable {
        case active = "Active"
        case archived = "Archived"
        case all = "All"
        public var id: String { rawValue }
    }

    public init() {}

    private var filteredNotes: [NoteItem] {
        var result = store.notes

        switch selectedFilter {
        case .active:
            result = result.filter { !$0.isArchived }
        case .archived:
            result = result.filter { $0.isArchived }
        case .all:
            break
        }

        if selectedCategory != "All" {
            result = result.filter { $0.category == selectedCategory }
        }

        if let color = selectedColorFilter {
            result = result.filter { $0.color == color }
        }

        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(query) ||
                $0.body.lowercased().contains(query)
            }
        }

        return result.sorted(by: { $0.updatedAt > $1.updatedAt })
    }

    public var body: some View {
        NavigationSplitView {
            sidebarContent
        } detail: {
            detailContent
        }
        .frame(minWidth: 760, minHeight: 500)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: {
                    let note = store.createNote(category: selectedCategory == "All" ? "General" : selectedCategory)
                    selectedNoteId = note.id
                }) {
                    Label("New Note", systemImage: "plus")
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
                    Button("Export to Apple Notes") {
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
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search notes...", text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(7)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)
            .padding(.horizontal, 10)
            .padding(.top, 8)

            // Segmented Filter (Active / Archived / All)
            Picker("", selection: $selectedFilter) {
                ForEach(NoteFilter.allCases) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 10)

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
                        .frame(width: 4, height: 38)

                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text(note.displayTitle)
                                .font(.system(size: 12, weight: .semibold, design: note.isCodeMode ? .monospaced : .default))
                                .lineLimit(1)

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
                            Text(note.category)
                                .font(.system(size: 9, weight: .medium))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color.secondary.opacity(0.15))
                                .cornerRadius(3)

                            Text(note.updatedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)

                            if note.isArchived {
                                Text("Archived")
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

            // Undo banner if item deleted
            if let deleted = store.recentlyDeletedNote {
                HStack {
                    Text("Deleted \"\(deleted.displayTitle.prefix(15))\"")
                        .font(.system(size: 11))
                        .lineLimit(1)
                    Spacer()
                    Button("Undo") {
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
        .frame(minWidth: 280)
    }

    private func categoryButton(title: String) -> some View {
        let isSelected = selectedCategory == title
        return Button(action: {
            selectedCategory = title
        }) {
            Text(title)
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
}
