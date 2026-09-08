import SwiftUI
import AppKit

public struct GraphNode: Identifiable {
    public var id: UUID
    public var title: String
    public var category: String
    public var color: NoteColor
    public var position: CGPoint
    public var linkCount: Int
    public var tags: [String]
    public var previewSnippet: String
}

public struct GraphEdge: Identifiable {
    public var id: String
    public var sourceId: UUID
    public var targetId: UUID
    public var isWikiLink: Bool
}

public struct KnowledgeGraphView: View {
    @ObservedObject var store = NoteStore.shared
    @ObservedObject var loc = LocalizationService.shared

    @State private var nodePositions: [UUID: CGPoint] = [:]
    @State private var draggingNodeId: UUID?
    @State private var dragInitialPos: CGPoint = .zero

    @State private var selectedNodeId: UUID?
    @State private var filterCategory: String = "All"
    @State private var searchQuery: String = ""
    @State private var offset: CGSize = .zero
    @State private var dragCurrent: CGSize = .zero
    @State private var zoomScale: CGFloat = 1.0

    public init() {}

    private var filteredNotes: [NoteItem] {
        let active = store.activeNotes
        var notes = active
        if filterCategory != "All" {
            notes = notes.filter { $0.category == filterCategory }
        }
        if !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty {
            let q = searchQuery.lowercased()
            notes = notes.filter { $0.title.lowercased().contains(q) || $0.body.lowercased().contains(q) }
        }
        return notes
    }

    private var graphData: (nodes: [GraphNode], edges: [GraphEdge]) {
        let active = filteredNotes
        var nodes: [GraphNode] = []
        var edges: [GraphEdge] = []

        let center = CGPoint(x: 450, y: 320)
        let radius: CGFloat = min(300, CGFloat(max(140, active.count * 36)))

        for (index, note) in active.enumerated() {
            let angle = (CGFloat(index) / CGFloat(max(1, active.count))) * 2.0 * .pi
            let defaultPos = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            let pos = nodePositions[note.id] ?? defaultPos

            var linkCount = 0
            let outgoing = note.outgoingWikiLinks

            // 1. Direct wiki links
            for targetTitle in outgoing {
                if let targetNote = active.first(where: { $0.title.lowercased() == targetTitle.lowercased() && $0.id != note.id }) {
                    let edgeId = "\(note.id.uuidString)->\(targetNote.id.uuidString)"
                    if !edges.contains(where: { $0.id == edgeId }) {
                        edges.append(GraphEdge(
                            id: edgeId,
                            sourceId: note.id,
                            targetId: targetNote.id,
                            isWikiLink: true
                        ))
                        linkCount += 1
                    }
                }
            }

            // 2. Same category connections
            for other in active where other.id != note.id && other.category == note.category && other.category != "General" {
                let edgeId = [note.id.uuidString, other.id.uuidString].sorted().joined(separator: "<->")
                if !edges.contains(where: { $0.id == edgeId }) {
                    edges.append(GraphEdge(
                        id: edgeId,
                        sourceId: note.id,
                        targetId: other.id,
                        isWikiLink: false
                    ))
                    linkCount += 1
                }
            }

            nodes.append(GraphNode(
                id: note.id,
                title: note.displayTitle,
                category: note.category,
                color: note.color,
                position: pos,
                linkCount: linkCount,
                tags: note.tags,
                previewSnippet: note.previewSnippet
            ))
        }

        return (nodes, edges)
    }

    public var body: some View {
        ZStack {
            // Background Canvas
            Color(nsColor: .windowBackgroundColor)
                .edgesIgnoringSafeArea(.all)
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

            // Edges Layer
            Canvas { context, size in
                let (nodes, edges) = graphData
                let nodeDict = Dictionary(uniqueKeysWithValues: nodes.map { ($0.id, $0.position) })

                for edge in edges {
                    if let start = nodeDict[edge.sourceId], let end = nodeDict[edge.targetId] {
                        var path = Path()
                        let startX = (start.x + offset.width + dragCurrent.width)
                        let startY = (start.y + offset.height + dragCurrent.height)
                        let endX = (end.x + offset.width + dragCurrent.width)
                        let endY = (end.y + offset.height + dragCurrent.height)

                        path.move(to: CGPoint(x: startX * zoomScale, y: startY * zoomScale))
                        path.addLine(to: CGPoint(x: endX * zoomScale, y: endY * zoomScale))

                        if edge.isWikiLink {
                            context.stroke(
                                path,
                                with: .color(Color.accentColor.opacity(0.85)),
                                lineWidth: 2.2 * zoomScale
                            )
                        } else {
                            context.stroke(
                                path,
                                with: .color(Color.secondary.opacity(0.25)),
                                style: StrokeStyle(lineWidth: 1.0 * zoomScale, dash: [4, 4])
                            )
                        }
                    }
                }
            }

            // Nodes Layer
            GeometryReader { _ in
                let (nodes, _) = graphData
                ForEach(nodes) { node in
                    let isSelected = selectedNodeId == node.id
                    VStack(spacing: 4) {
                        Circle()
                            .fill(node.color.dotColor)
                            .frame(
                                width: max(22, min(44, CGFloat(24 + node.linkCount * 3))),
                                height: max(22, min(44, CGFloat(24 + node.linkCount * 3)))
                            )
                            .overlay(
                                Circle()
                                    .stroke(isSelected ? Color.white : Color.primary.opacity(0.2), lineWidth: isSelected ? 3 : 1)
                            )
                            .shadow(color: Color.black.opacity(isSelected ? 0.35 : 0.15), radius: isSelected ? 6 : 3, x: 0, y: 2)

                        Text(node.title)
                            .font(.system(size: 11, weight: isSelected ? .bold : .medium, design: .rounded))
                            .foregroundColor(isSelected ? .white : .primary)
                            .lineLimit(1)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(isSelected ? Color.accentColor : Color(nsColor: .controlBackgroundColor).opacity(0.85))
                            .cornerRadius(4)
                    }
                    .position(
                        x: (node.position.x + offset.width + dragCurrent.width) * zoomScale,
                        y: (node.position.y + offset.height + dragCurrent.height) * zoomScale
                    )
                    .onTapGesture {
                        selectedNodeId = (selectedNodeId == node.id) ? nil : node.id
                    }
                    .onTapGesture(count: 2) {
                        NoteWindowManager.shared.openNote(id: node.id)
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { val in
                                if draggingNodeId != node.id {
                                    draggingNodeId = node.id
                                    dragInitialPos = nodePositions[node.id] ?? node.position
                                }
                                let newX = dragInitialPos.x + (val.translation.width / zoomScale)
                                let newY = dragInitialPos.y + (val.translation.height / zoomScale)
                                nodePositions[node.id] = CGPoint(x: max(60, newX), y: max(60, newY))
                            }
                            .onEnded { _ in
                                draggingNodeId = nil
                            }
                    )
                }
            }

            // Floating Controls Overlay (Top)
            VStack {
                HStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "circle.hexagongrid.fill")
                            .foregroundColor(.purple)
                        Text(loc.language == .turkish ? "Bağlantı Ağı" : "Knowledge Graph")
                            .font(.system(size: 13, weight: .bold, design: .rounded))

                        Text("\(filteredNotes.count) \(loc.language == .turkish ? "Düğüm" : "Nodes")")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.06))
                            .cornerRadius(4)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)

                    // Category Filter
                    Picker("", selection: $filterCategory) {
                        Text(loc.language == .turkish ? "Tüm Kategoriler" : "All Categories").tag("All")
                        ForEach(store.categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 140)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)

                    // Search field
                    HStack(spacing: 4) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        TextField(loc.language == .turkish ? "Düğüm Ara..." : "Search graph...", text: $searchQuery)
                            .textFieldStyle(.plain)
                            .font(.system(size: 11))
                            .frame(width: 110)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)

                    Spacer()

                    // Controls: Auto Layout, Reset, Zoom
                    HStack(spacing: 6) {
                        Button(action: autoLayoutRadial) {
                            HStack(spacing: 3) {
                                Image(systemName: "sparkles")
                                Text(loc.language == .turkish ? "Düzenle" : "Layout")
                                    .font(.system(size: 11, weight: .medium))
                            }
                        }
                        .help(loc.language == .turkish ? "Ağı Çember/Küme Düzeniyle Düzenle" : "Auto Arrange Graph")

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
                        .help("Reset Graph View")

                        Button(action: {
                            withAnimation { zoomScale = max(0.5, zoomScale - 0.1) }
                        }) {
                            Image(systemName: "minus.magnifyingglass")
                                .font(.system(size: 11))
                        }
                        .help("Zoom Out")

                        Button(action: {
                            withAnimation { zoomScale = min(2.0, zoomScale + 0.1) }
                        }) {
                            Image(systemName: "plus.magnifyingglass")
                                .font(.system(size: 11))
                        }
                        .help("Zoom In")
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                }
                .padding(12)

                Spacer()

                // Selected Node Inspector Card (Bottom-Right)
                if let selectedId = selectedNodeId, let node = graphData.nodes.first(where: { $0.id == selectedId }) {
                    HStack {
                        Spacer()
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Circle()
                                    .fill(node.color.dotColor)
                                    .frame(width: 10, height: 10)
                                Text(node.title)
                                    .font(.system(size: 12, weight: .bold))
                                    .lineLimit(1)
                                Spacer()
                                Button(action: { selectedNodeId = nil }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(.plain)
                            }

                            Text(node.previewSnippet)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .lineLimit(3)

                            HStack {
                                Text("📁 \(node.category)")
                                    .font(.system(size: 9, weight: .medium))
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 1)
                                    .background(Color.secondary.opacity(0.12))
                                    .cornerRadius(3)

                                Text("🔗 \(node.linkCount) \(loc.language == .turkish ? "bağlantı" : "links")")
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)

                                Spacer()

                                Button(action: {
                                    NoteWindowManager.shared.openNote(id: node.id)
                                }) {
                                    Text(loc.language == .turkish ? "Notu Aç" : "Open Note")
                                        .font(.system(size: 11, weight: .semibold))
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.small)
                            }
                        }
                        .padding(10)
                        .frame(width: 260)
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 3)
                        .padding(.trailing, 16)
                        .padding(.bottom, 16)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    // Bottom Legend & Hint
                    HStack {
                        Text(loc.language == .turkish ? "💡 İpucu: Notlarınızda [[Not Başlığı]] yazarak notları bağlayın veya aynı kategoriye koyun. Açmak için çift tıklayın." : "💡 Tip: Link notes via [[Note Title]] or same category. Double-click node to open.")
                            .font(.system(size: 11))
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
    }

    private func autoLayoutRadial() {
        withAnimation(.spring()) {
            let active = filteredNotes
            let center = CGPoint(x: 450, y: 320)
            let radius: CGFloat = min(300, CGFloat(max(140, active.count * 36)))

            for (index, note) in active.enumerated() {
                let angle = (CGFloat(index) / CGFloat(max(1, active.count))) * 2.0 * .pi
                nodePositions[note.id] = CGPoint(
                    x: center.x + radius * cos(angle),
                    y: center.y + radius * sin(angle)
                )
            }
        }
    }
}
