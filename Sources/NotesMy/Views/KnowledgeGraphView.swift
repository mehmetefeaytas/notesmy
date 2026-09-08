import SwiftUI
import AppKit

public struct GraphNode: Identifiable {
    public var id: UUID
    public var title: String
    public var category: String
    public var color: NoteColor
    public var position: CGPoint
    public var linkCount: Int
}

public struct GraphEdge: Identifiable {
    public var id: String
    public var sourceId: UUID
    public var targetId: UUID
}

public struct KnowledgeGraphView: View {
    @ObservedObject var store = NoteStore.shared
    @ObservedObject var loc = LocalizationService.shared

    @State private var nodePositions: [UUID: CGPoint] = [:]
    @State private var selectedNodeId: UUID?
    @State private var offset: CGSize = .zero
    @State private var dragCurrent: CGSize = .zero
    @State private var zoomScale: CGFloat = 1.0

    public init() {}

    private var graphData: (nodes: [GraphNode], edges: [GraphEdge]) {
        let active = store.activeNotes
        var nodes: [GraphNode] = []
        var edges: [GraphEdge] = []

        // Compute positions in circle/force layout
        let center = CGPoint(x: 400, y: 300)
        let radius: CGFloat = min(260, CGFloat(max(100, active.count * 30)))

        for (index, note) in active.enumerated() {
            let angle = (CGFloat(index) / CGFloat(max(1, active.count))) * 2.0 * .pi
            let defaultPos = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            let pos = nodePositions[note.id] ?? defaultPos

            // Count links
            let outgoing = note.outgoingWikiLinks
            var linkCount = 0

            for targetTitle in outgoing {
                if let targetNote = active.first(where: { $0.title.lowercased() == targetTitle.lowercased() }) {
                    edges.append(GraphEdge(
                        id: "\(note.id.uuidString)->\(targetNote.id.uuidString)",
                        sourceId: note.id,
                        targetId: targetNote.id
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
                linkCount: linkCount
            ))
        }

        return (nodes, edges)
    }

    public var body: some View {
        ZStack {
            // Dark/Subtle Grid Background
            Color(nsColor: .windowBackgroundColor)
                .edgesIgnoringSafeArea(.all)

            // Edges Layer
            Canvas { context, size in
                let (nodes, edges) = graphData
                let nodeDict = Dictionary(uniqueKeysWithValues: nodes.map { ($0.id, $0.position) })

                for edge in edges {
                    if let start = nodeDict[edge.sourceId], let end = nodeDict[edge.targetId] {
                        var path = Path()
                        path.move(to: CGPoint(
                            x: (start.x + offset.width + dragCurrent.width) * zoomScale,
                            y: (start.y + offset.height + dragCurrent.height) * zoomScale
                        ))
                        path.addLine(to: CGPoint(
                            x: (end.x + offset.width + dragCurrent.width) * zoomScale,
                            y: (end.y + offset.height + dragCurrent.height) * zoomScale
                        ))
                        context.stroke(path, with: .color(Color.accentColor.opacity(0.4)), lineWidth: 1.5 * zoomScale)
                    }
                }
            }

            // Nodes Layer
            GeometryReader { _ in
                let (nodes, _) = graphData
                ForEach(nodes) { node in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(node.color.dotColor)
                            .frame(width: max(18, min(36, CGFloat(20 + node.linkCount * 4))), height: max(18, min(36, CGFloat(20 + node.linkCount * 4))))
                            .overlay(
                                Circle()
                                    .stroke(selectedNodeId == node.id ? Color.white : Color.clear, lineWidth: 2)
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)

                        Text(node.title)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .lineLimit(1)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.ultraThinMaterial)
                            .cornerRadius(4)
                    }
                    .position(
                        x: (node.position.x + offset.width + dragCurrent.width) * zoomScale,
                        y: (node.position.y + offset.height + dragCurrent.height) * zoomScale
                    )
                    .onTapGesture {
                        selectedNodeId = node.id
                    }
                    .onTapGesture(count: 2) {
                        NoteWindowManager.shared.openNote(id: node.id)
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { val in
                                nodePositions[node.id] = CGPoint(
                                    x: node.position.x + val.translation.width,
                                    y: node.position.y + val.translation.height
                                )
                            }
                    )
                }
            }

            // Top Header & Controls
            VStack {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "circle.hexagongrid.fill")
                            .foregroundColor(.purple)
                        Text(loc.language == .turkish ? "Bağlantı Ağı (Knowledge Graph)" : "Knowledge Graph")
                            .font(.system(size: 13, weight: .bold, design: .rounded))

                        Text("\(store.activeNotes.count) \(loc.language == .turkish ? "Düğüm" : "Nodes")")
                            .font(.system(size: 10))
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

                    Spacer()

                    HStack(spacing: 6) {
                        Button(action: {
                            withAnimation(.spring()) {
                                offset = .zero
                                dragCurrent = .zero
                                zoomScale = 1.0
                            }
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                        }
                        .help("Reset Graph View")

                        Button(action: {
                            withAnimation { zoomScale = max(0.5, zoomScale - 0.1) }
                        }) {
                            Image(systemName: "minus.magnifyingglass")
                        }
                        .help("Zoom Out")

                        Button(action: {
                            withAnimation { zoomScale = min(2.0, zoomScale + 0.1) }
                        }) {
                            Image(systemName: "plus.magnifyingglass")
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

                // Bottom Legend & Hint
                HStack {
                    Text(loc.language == .turkish ? "İpucu: Notlarınızda [[Not Başlığı]] yazarak notları birbirine bağlayabilirsiniz. Açmak için çift tıklayın." : "Tip: Link notes using [[Note Title]]. Double-click any node to open.")
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
    }
}
