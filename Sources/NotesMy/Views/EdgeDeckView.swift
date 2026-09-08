import SwiftUI

public struct EdgeDeckView: View {
    @ObservedObject var store = NoteStore.shared
    public var onSelectNote: (UUID) -> Void
    public var onNewNote: () -> Void
    public var onOpenAllNotes: () -> Void
    public var onOpenArchive: () -> Void
    public var onQuickCapture: () -> Void
    public var onOpenSettings: () -> Void

    @State private var hoveredCardId: UUID? = nil

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
        VStack(alignment: .trailing, spacing: 10) {
            // Deck Card Stack
            VStack(alignment: .trailing, spacing: 6) {
                ForEach(Array(store.activeNotes.prefix(6).enumerated()), id: \.element.id) { index, note in
                    deckCard(note: note, index: index)
                }

                if store.activeNotes.count > 6 {
                    Text("+\(store.activeNotes.count - 6) more in All Notes")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.black.opacity(0.06)))
                }
            }

            // Quick Control Bar
            HStack(spacing: 8) {
                Button(action: onNewNote) {
                    Label("New", systemImage: "plus")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Color.accentColor.opacity(0.15))
                        .foregroundColor(.accentColor)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .help("Create Note (⌥⌘N)")

                Button(action: onQuickCapture) {
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 11))
                        .padding(5)
                        .background(Color.secondary.opacity(0.12))
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .help("Capture Clipboard (⌥⌘V)")

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
                    .fill(Color(nsColor: .windowBackgroundColor).opacity(0.92))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 2)
            )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
        .onHover { hovering in
            if !hovering {
                // Return to resting pill state
                withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                    store.isDeckHovered = false
                }
            }
        }
    }

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
                    Text(note.displayTitle)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(note.color.textColor)
                        .lineLimit(1)

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
                            .font(.system(size: 10, design: .rounded))
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
            .frame(width: isHovered ? 210 : 190)
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
