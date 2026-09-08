import SwiftUI

public struct EdgeDeckView: View {
    @ObservedObject var store = NoteStore.shared
    @ObservedObject var loc = LocalizationService.shared
    public var onSelectNote: (UUID) -> Void
    public var onNewNote: () -> Void
    public var onOpenAllNotes: () -> Void
    public var onOpenArchive: () -> Void
    public var onQuickCapture: () -> Void
    public var onOpenSettings: () -> Void

    @State private var hoveredCardId: UUID? = nil
    @State private var showClipboardDrawer: Bool = false

    public init(
        store: NoteStore = .shared,
        onSelectNote: @escaping (UUID) -> Void,
        onNewNote: @escaping () -> Void,
        onOpenAllNotes: @escaping () -> Void,
        onOpenArchive: @escaping () -> Void,
        onQuickCapture: @escaping () -> Void,
        onOpenSettings: @escaping () -> Void
    ) {
        self.store = store
        self.onSelectNote = onSelectNote
        self.onNewNote = onNewNote
        self.onOpenAllNotes = onOpenAllNotes
        self.onOpenArchive = onOpenArchive
        self.onQuickCapture = onQuickCapture
        self.onOpenSettings = onOpenSettings
    }

    private var displayedNotes: [NoteItem] {
        store.activeNotes(for: store.selectedCategory)
    }

    public var body: some View {
        ZStack(alignment: alignmentForDockSide) {
            if store.isDeckHovered {
                fannedDeckView
                    .transition(.asymmetric(
                        insertion: .move(edge: transitionEdge).combined(with: .opacity),
                        removal: .move(edge: transitionEdge).combined(with: .opacity)
                    ))
            } else {
                restingPillView
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.32, dampingFraction: 0.82), value: store.isDeckHovered)
    }

    // MARK: - Resting State (14pt Pill)

    private var restingPillView: some View {
        VStack(spacing: 5) {
            ForEach(store.activeNotes.prefix(8)) { note in
                Capsule()
                    .fill(note.color.dotColor)
                    .frame(width: 4, height: 16)
                    .shadow(color: note.color.dotColor.opacity(0.4), radius: 1, x: 0, y: 0)
            }

            if store.activeNotes.isEmpty {
                Circle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 5, height: 5)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
        .background(
            Capsule()
                .fill(Color(nsColor: .windowBackgroundColor).opacity(0.85))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.18), radius: 6, x: -1, y: 2)
        )
        .frame(width: 14)
        .contentShape(Rectangle())
        .onHover { hovering in
            if hovering {
                withAnimation {
                    store.isDeckHovered = true
                }
            }
        }
    }

    // MARK: - Fanned Deck View (Hover State)

    private var fannedDeckView: some View {
        VStack(alignment: .trailing, spacing: 8) {
            // Category Filter Bar (SideNotes feature)
            categoryFilterBar

            // Clipboard History Drawer (Unclutter feature)
            if showClipboardDrawer {
                clipboardHistoryDrawer
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            // Deck Card Stack
            VStack(alignment: .trailing, spacing: 6) {
                ForEach(Array(displayedNotes.prefix(6).enumerated()), id: \.element.id) { index, note in
                    deckCard(note: note, index: index)
                }

                if displayedNotes.isEmpty {
                    Text("No notes in \(loc.localizedCategory(store.selectedCategory))")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(8)
                }

                if displayedNotes.count > 6 {
                    Text("+\(displayedNotes.count - 6) \(loc.text(.allNotes))")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.black.opacity(0.06)))
                }
            }

            // Quick Control Bar
            HStack(spacing: 6) {
                Button(action: onNewNote) {
                    Label(loc.text(.newNote), systemImage: "plus")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Color.accentColor.opacity(0.15))
                        .foregroundColor(.accentColor)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .help("Create Note (⌥⌘N)")

                // Clipboard Drawer toggle
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showClipboardDrawer.toggle()
                    }
                }) {
                    Image(systemName: showClipboardDrawer ? "doc.on.clipboard.fill" : "doc.on.clipboard")
                        .font(.system(size: 11))
                        .foregroundColor(showClipboardDrawer ? Color.accentColor : Color.primary)
                        .padding(5)
                        .background(showClipboardDrawer ? Color.accentColor.opacity(0.2) : Color.secondary.opacity(0.12))
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .help("Clipboard History Hub")

                Button(action: onOpenAllNotes) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 11))
                        .padding(5)
                        .background(Color.secondary.opacity(0.12))
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .help("All Notes (⌥⌘L)")

                Button(action: onOpenArchive) {
                    Image(systemName: "archivebox")
                        .font(.system(size: 11))
                        .padding(5)
                        .background(Color.secondary.opacity(0.12))
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .help("Archive (⌥⌘A)")

                Button(action: onOpenSettings) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 11))
                        .padding(5)
                        .background(Color.secondary.opacity(0.12))
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .help("Settings")
            }
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(nsColor: .windowBackgroundColor).opacity(0.94))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 2)
            )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
        .onHover { hovering in
            if !hovering {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                    store.isDeckHovered = false
                    showClipboardDrawer = false
                }
            }
        }
    }

    // MARK: - Category Filter Bar

    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
                categoryTab(key: "All")
                ForEach(store.categories, id: \.self) { cat in
                    categoryTab(key: cat)
                }
            }
            .padding(4)
        }
        .frame(maxWidth: 240)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(nsColor: .windowBackgroundColor).opacity(0.9))
        )
    }

    private func categoryTab(key: String) -> some View {
        let isSelected = store.selectedCategory == key
        let displayTitle = loc.localizedCategory(key)
        return Button(action: {
            withAnimation(.easeInOut(duration: 0.15)) {
                store.selectedCategory = key
            }
        }) {
            Text(displayTitle)
                .font(.system(size: 10, weight: isSelected ? .bold : .medium, design: .rounded))
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
                .foregroundColor(isSelected ? Color.accentColor : Color.secondary)
                .cornerRadius(5)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Clipboard History Drawer

    private var clipboardHistoryDrawer: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Recent Clipboard")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)

            if store.clipboardHistory.isEmpty {
                Text("Copy text anywhere to see it here")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .padding(4)
            } else {
                ForEach(store.clipboardHistory.prefix(3), id: \.self) { snippet in
                    HStack {
                        Text(snippet.prefix(35))
                            .font(.system(size: 10, design: .monospaced))
                            .lineLimit(1)
                            .foregroundColor(.primary)

                        Spacer()

                        Button("+ Note") {
                            let note = store.createNote(
                                title: String(snippet.prefix(25)),
                                body: snippet,
                                color: .amber
                            )
                            onSelectNote(note.id)
                        }
                        .font(.system(size: 9, weight: .bold))
                        .buttonStyle(.plain)
                        .foregroundColor(.accentColor)
                    }
                    .padding(4)
                    .background(Color.black.opacity(0.04))
                    .cornerRadius(4)
                }
            }
        }
        .padding(8)
        .frame(width: 230)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(nsColor: .windowBackgroundColor).opacity(0.96))
                .shadow(radius: 4)
        )
    }

    // MARK: - Deck Card Item

    private func deckCard(note: NoteItem, index: Int) -> some View {
        let isHovered = hoveredCardId == note.id
        let isCurrent = store.selectedNoteId == note.id

        return Button(action: {
            onSelectNote(note.id)
        }) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(note.color.dotColor)
                    .frame(width: 4, height: 32)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(note.displayTitle)
                            .font(.system(size: 12, weight: .semibold, design: note.isCodeMode ? .monospaced : .rounded))
                            .foregroundColor(note.color.textColor)
                            .lineLimit(1)

                        if note.isCodeMode {
                            Image(systemName: "chevron.left.forwardslash.chevron.right")
                                .font(.system(size: 8))
                                .foregroundColor(note.color.secondaryTextColor)
                        }
                    }

                    if let progress = note.checklistProgress {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 9))
                                .foregroundColor(note.color.dotColor)
                            Text("\(progress.completed)/\(progress.total) tasks")
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(note.color.secondaryTextColor)
                        }
                    } else {
                        Text(note.previewSnippet)
                            .font(.system(size: 10, design: note.isCodeMode ? .monospaced : .rounded))
                            .foregroundColor(note.color.secondaryTextColor)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(note.color.secondaryTextColor.opacity(0.7))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .frame(width: isHovered ? 220 : 200)
            .background(
                RoundedRectangle(cornerRadius: 9)
                    .fill(note.color.cardColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 9)
                            .stroke(isCurrent ? Color.accentColor : note.color.borderTone, lineWidth: isCurrent ? 1.5 : 0.8)
                    )
                    .shadow(color: Color.black.opacity(isHovered ? 0.16 : 0.08), radius: isHovered ? 6 : 3, x: -1, y: 2)
            )
            .offset(x: isHovered ? -8 : 0)
        }
        .buttonStyle(.plain)
        .onHover { hover in
            withAnimation(.easeInOut(duration: 0.15)) {
                if hover {
                    hoveredCardId = note.id
                } else if hoveredCardId == note.id {
                    hoveredCardId = nil
                }
            }
        }
    }

    private var alignmentForDockSide: Alignment {
        switch store.dockSide {
        case .right: return .trailing
        case .left: return .leading
        case .bottom: return .bottom
        }
    }

    private var transitionEdge: Edge {
        switch store.dockSide {
        case .right: return .trailing
        case .left: return .leading
        case .bottom: return .bottom
        }
    }
}
