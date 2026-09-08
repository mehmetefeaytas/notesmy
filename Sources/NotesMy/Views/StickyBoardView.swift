import SwiftUI
import AppKit

public struct StickyBoardView: View {
    @ObservedObject var store = NoteStore.shared
    @ObservedObject var loc = LocalizationService.shared

    @State private var selectedNoteId: UUID?
    @State private var zoomScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var dragCurrent: CGSize = .zero
    @State private var filterCategory: String = "All"

    public init() {}

    private var boardNotes: [NoteItem] {
        let active = store.activeNotes
        if filterCategory == "All" {
            return active
        }
        return active.filter { $0.category == filterCategory }
    }

    public var body: some View {
        ZStack {
            // Corkboard / Textured Grid Background
            canvasBackground
                .gesture(
                    DragGesture()
                        .onChanged { val in
                            dragCurrent = val.translation
                        }
                        .onEnded { val in
                            offset.width += val.translation.width
                            offset.height += val.translation.height
                            dragCurrent = .zero
                        }
                )

            // Draggable Note Cards on Canvas
            GeometryReader { geo in
                ForEach(boardNotes) { note in
                    let cardPos = positionFor(note: note, in: geo.size)
                    StickyCardView(
                        note: note,
                        currentPosition: cardPos,
                        zoomScale: zoomScale,
                        isSelected: selectedNoteId == note.id,
                        onSelect: {
                            selectedNoteId = note.id
                        },
                        onPositionChanged: { newX, newY in
                            var updated = note
                            updated.pinnedX = Double(newX)
                            updated.pinnedY = Double(newY)
                            store.updateNote(updated)
                            store.saveNotes()
                        },
                        onOpenEditor: {
                            NoteWindowManager.shared.openNote(id: note.id)
                        }
                    )
                    .position(
                        x: cardPos.x + offset.width + dragCurrent.width,
                        y: cardPos.y + offset.height + dragCurrent.height
                    )
                }
            }
            .scaleEffect(zoomScale)

            // Floating Controls Overlay (Top-Right / Bottom-Right)
            VStack {
                HStack {
                    // Board Title & Category Filter
                    HStack(spacing: 8) {
                        Image(systemName: "square.grid.3x3.fill")
                            .foregroundColor(.accentColor)
                        Text(loc.text(.stickyBoard))
                            .font(.system(size: 13, weight: .bold, design: .rounded))

                        Picker("", selection: $filterCategory) {
                            Text("All Categories").tag("All")
                            ForEach(store.categories, id: \.self) { cat in
                                Text(cat).tag(cat)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 130)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)

                    Spacer()

                    // Controls: Zoom, Reset, Auto-Layout, Add Note
                    HStack(spacing: 6) {
                        Button(action: autoArrangeGrid) {
                            Image(systemName: "rectangle.3.group")
                                .font(.system(size: 11))
                        }
                        .help(loc.language == .turkish ? "Kartları Düzenle (Otomatik Izgara)" : "Auto Arrange Cards")

                        Button(action: {
                            withAnimation(.spring()) {
                                offset = .zero
                                dragCurrent = .zero
                                zoomScale = 1.0
                            }
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 11))
                        }
                        .help("Reset Canvas View")

                        Button(action: {
                            withAnimation { zoomScale = max(0.6, zoomScale - 0.1) }
                        }) {
                            Image(systemName: "minus.magnifyingglass")
                                .font(.system(size: 11))
                        }
                        .help("Zoom Out")

                        Text("\(Int(zoomScale * 100))%")
                            .font(.system(size: 10, design: .monospaced))
                            .frame(width: 38)

                        Button(action: {
                            withAnimation { zoomScale = min(1.6, zoomScale + 0.1) }
                        }) {
                            Image(systemName: "plus.magnifyingglass")
                                .font(.system(size: 11))
                        }
                        .help("Zoom In")

                        Divider().frame(height: 14)

                        Button(action: addNewBoardNote) {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                Text(loc.text(.newNote))
                                    .font(.system(size: 11, weight: .semibold))
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                }
                .padding(12)

                Spacer()

                // Bottom Hint
                HStack {
                    Text(loc.text(.boardHint))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .cornerRadius(6)
                    Spacer()
                }
                .padding(12)
            }
        }
    }

    private var canvasBackground: some View {
        Canvas { context, size in
            // Subtle dot-grid pattern
            let dotSpacing: CGFloat = 24
            let dotSize: CGFloat = 2.0

            let cols = Int(size.width / dotSpacing) + 2
            let rows = Int(size.height / dotSpacing) + 2

            let dotColor = Color.primary.opacity(0.08)

            for i in 0..<cols {
                for j in 0..<rows {
                    let x = CGFloat(i) * dotSpacing
                    let y = CGFloat(j) * dotSpacing
                    let rect = CGRect(x: x - dotSize / 2, y: y - dotSize / 2, width: dotSize, height: dotSize)
                    context.fill(Path(ellipseIn: rect), with: .color(dotColor))
                }
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private func positionFor(note: NoteItem, in containerSize: CGSize) -> CGPoint {
        if let x = note.pinnedX, let y = note.pinnedY {
            return CGPoint(x: x, y: y)
        }

        // Layout in a grid if not placed yet
        let index = boardNotes.firstIndex(where: { $0.id == note.id }) ?? 0
        let col = index % 3
        let row = index / 3

        let initialX: CGFloat = 160 + CGFloat(col * 240)
        let initialY: CGFloat = 140 + CGFloat(row * 220)
        return CGPoint(x: initialX, y: initialY)
    }

    private func autoArrangeGrid() {
        withAnimation(.spring()) {
            for (index, note) in boardNotes.enumerated() {
                let col = index % 3
                let row = index / 3
                let newX = 160.0 + Double(col * 240)
                let newY = 140.0 + Double(row * 220)
                var updated = note
                updated.pinnedX = newX
                updated.pinnedY = newY
                store.updateNote(updated)
            }
            store.saveNotes()
        }
    }

    private func addNewBoardNote() {
        let note = store.createNote(
            category: filterCategory == "All" ? "General" : filterCategory
        )
        selectedNoteId = note.id
    }
}

// MARK: - Sticky Card on Board

public struct StickyCardView: View {
    public var note: NoteItem
    public var currentPosition: CGPoint
    public var zoomScale: CGFloat
    public var isSelected: Bool
    public var onSelect: () -> Void
    public var onPositionChanged: (CGFloat, CGFloat) -> Void
    public var onOpenEditor: () -> Void

    @State private var dragOffset: CGSize = .zero

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header with Pushpin & Color dot
            HStack {
                // Realistic pushpin
                Image(systemName: "pin.fill")
                    .font(.system(size: 13))
                    .foregroundColor(.red)
                    .shadow(color: Color.black.opacity(0.25), radius: 2, x: 1, y: 1)

                Spacer()

                if note.isFavorite {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.yellow)
                }

                if note.reminderDate != nil {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.orange)
                }

                Text(note.category)
                    .font(.system(size: 9, weight: .semibold))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(Color.black.opacity(0.08))
                    .cornerRadius(3)
            }

            // Note Title
            Text(note.displayTitle)
                .font(.system(size: 13, weight: .bold, design: note.isCodeMode ? .monospaced : .rounded))
                .foregroundColor(note.color.textColor)
                .lineLimit(1)

            // Snippet Preview
            Text(note.previewSnippet)
                .font(.system(size: 11, design: note.isCodeMode ? .monospaced : .default))
                .foregroundColor(note.color.secondaryTextColor)
                .lineLimit(4)

            // Checklist preview
            if let progress = note.checklistProgress {
                HStack(spacing: 4) {
                    Image(systemName: "checklist")
                        .font(.system(size: 9))
                    Text("\(progress.completed)/\(progress.total) tasks")
                        .font(.system(size: 9, weight: .medium))
                }
                .foregroundColor(note.color.secondaryTextColor)
            }

            Spacer(minLength: 0)

            // Footer
            HStack {
                Text(note.updatedAt.formatted(date: .numeric, time: .omitted))
                    .font(.system(size: 9))
                    .foregroundColor(note.color.secondaryTextColor.opacity(0.7))
                Spacer()

                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 9))
                    .foregroundColor(note.color.secondaryTextColor.opacity(0.6))
            }
        }
        .padding(12)
        .frame(width: 200, height: 180)
        .background(note.color.primaryColor)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.accentColor : note.color.borderTone, lineWidth: isSelected ? 2 : 1)
        )
        .shadow(color: Color.black.opacity(isSelected ? 0.25 : 0.12), radius: isSelected ? 8 : 4, x: 0, y: 3)
        .offset(dragOffset)
        .onTapGesture {
            onSelect()
        }
        .onTapGesture(count: 2) {
            onOpenEditor()
        }
        .gesture(
            DragGesture()
                .onChanged { val in
                    dragOffset = CGSize(
                        width: val.translation.width / zoomScale,
                        height: val.translation.height / zoomScale
                    )
                    onSelect()
                }
                .onEnded { val in
                    let finalX = max(110, currentPosition.x + (val.translation.width / zoomScale))
                    let finalY = max(100, currentPosition.y + (val.translation.height / zoomScale))
                    dragOffset = .zero
                    onPositionChanged(finalX, finalY)
                }
        )
    }
}
