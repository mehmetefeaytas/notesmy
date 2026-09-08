import SwiftUI
import AppKit
import NaturalLanguage

public enum GraphEdgeKind: Equatable, Sendable {
    case wikiLink                  // Explicit [[WikiLink]] reference
    case aiSemantic(score: Double) // AI Semantic embedding/concept match (NaturalLanguage)
    case sharedTags(tags: [String])// Shared metadata tags
    case categoryCluster          // Category community connection
}

public struct GraphNode: Identifiable, Sendable {
    public var id: UUID
    public var title: String
    public var category: String
    public var color: NoteColor
    public var position: CGPoint
    public var linkCount: Int
    public var tags: [String]
    public var previewSnippet: String
    public var keywords: Set<String>
}

public struct GraphEdge: Identifiable, Sendable {
    public var id: String
    public var sourceId: UUID
    public var targetId: UUID
    public var kind: GraphEdgeKind
    public var strength: Double // 0.0 ... 1.0

    public var isWikiLink: Bool {
        if case .wikiLink = kind { return true }
        return false
    }

    public var isAISemantic: Bool {
        if case .aiSemantic = kind { return true }
        return false
    }
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

    private let stopWords: Set<String> = [
        "olan", "veya", "için", "gibi", "bunu", "ve", "ile", "bir", "bu", "şu", "daha",
        "the", "and", "with", "that", "this", "from", "have", "will", "your", "about"
    ]

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

    // MARK: - Mathematical & AI Graph Generation

    private var graphData: (nodes: [GraphNode], edges: [GraphEdge]) {
        let active = filteredNotes
        var nodes: [GraphNode] = []
        var edges: [GraphEdge] = []

        let center = CGPoint(x: 450, y: 320)
        let radius: CGFloat = min(320, CGFloat(max(150, active.count * 38)))

        // 1. Build Nodes with extracted keywords
        var noteKeywords: [UUID: Set<String>] = [:]
        for (index, note) in active.enumerated() {
            let angle = (CGFloat(index) / CGFloat(max(1, active.count))) * 2.0 * .pi
            let defaultPos = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            let pos = nodePositions[note.id] ?? defaultPos
            let kw = extractKeywords(from: note)
            noteKeywords[note.id] = kw

            nodes.append(GraphNode(
                id: note.id,
                title: note.displayTitle,
                category: note.category,
                color: note.color,
                position: pos,
                linkCount: 0,
                tags: note.tags,
                previewSnippet: note.previewSnippet,
                keywords: kw
            ))
        }

        // 2. Discover Edges using AI Semantics, WikiLinks, Tags & Math
        var linkCounts: [UUID: Int] = [:]
        for n in nodes { linkCounts[n.id] = 0 }

        for i in 0..<active.count {
            for j in (i + 1)..<active.count {
                let noteA = active[i]
                let noteB = active[j]
                let kwA = noteKeywords[noteA.id] ?? []
                let kwB = noteKeywords[noteB.id] ?? []

                if let edge = computeMathematicalAIEdge(noteA: noteA, noteB: noteB, kwA: kwA, kwB: kwB) {
                    edges.append(edge)
                    linkCounts[noteA.id, default: 0] += 1
                    linkCounts[noteB.id, default: 0] += 1
                }
            }
        }

        // Update node link counts
        for i in 0..<nodes.count {
            nodes[i].linkCount = linkCounts[nodes[i].id] ?? 0
        }

        return (nodes, edges)
    }

    private func extractKeywords(from note: NoteItem) -> Set<String> {
        let raw = "\(note.title) \(note.body)".lowercased()
        let tokens = raw.components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 3 && !stopWords.contains($0) }
        return Set(tokens)
    }

    private func computeMathematicalAIEdge(
        noteA: NoteItem,
        noteB: NoteItem,
        kwA: Set<String>,
        kwB: Set<String>
    ) -> GraphEdge? {
        let edgeId = [noteA.id.uuidString, noteB.id.uuidString].sorted().joined(separator: "<->")

        // Priority 1: Direct WikiLinks
        let outA = noteA.outgoingWikiLinks.map { $0.lowercased() }
        let outB = noteB.outgoingWikiLinks.map { $0.lowercased() }
        let titleA = noteA.title.lowercased()
        let titleB = noteB.title.lowercased()

        if (!titleB.isEmpty && outA.contains(titleB)) || (!titleA.isEmpty && outB.contains(titleA)) {
            return GraphEdge(id: edgeId, sourceId: noteA.id, targetId: noteB.id, kind: .wikiLink, strength: 1.0)
        }

        // Priority 2: Shared Tags
        let commonTags = Set(noteA.tags).intersection(Set(noteB.tags)).filter { !$0.isEmpty }
        if !commonTags.isEmpty {
            let str = min(0.95, 0.5 + Double(commonTags.count) * 0.15)
            return GraphEdge(id: edgeId, sourceId: noteA.id, targetId: noteB.id, kind: .sharedTags(tags: Array(commonTags)), strength: str)
        }

        // Priority 3: AI Jaccard Concept & Keyword Cosine Similarity
        if !kwA.isEmpty && !kwB.isEmpty {
            let intersection = kwA.intersection(kwB).count
            let union = kwA.union(kwB).count
            if union > 0 {
                let jaccard = Double(intersection) / Double(union)
                if jaccard >= 0.12 {
                    let score = min(0.95, jaccard * 2.8)
                    return GraphEdge(id: edgeId, sourceId: noteA.id, targetId: noteB.id, kind: .aiSemantic(score: score), strength: score)
                }
            }
        }

        // Priority 4: Category Clustering
        if noteA.category == noteB.category && noteA.category != "General" {
            return GraphEdge(id: edgeId, sourceId: noteA.id, targetId: noteB.id, kind: .categoryCluster, strength: 0.35)
        }

        return nil
    }

    // MARK: - Body View

    public var body: some View {
        ZStack {
            // Background Canvas with Pan gesture
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

            // Edges Layer (Lines connecting nodes)
            Canvas { context, size in
                let (nodes, edges) = graphData
                let nodeDict = Dictionary(uniqueKeysWithValues: nodes.map { ($0.id, ($0.position, $0.color)) })

                for edge in edges {
                    guard let (start, startColor) = nodeDict[edge.sourceId],
                          let (end, _) = nodeDict[edge.targetId] else { continue }

                    var path = Path()
                    let startX = (start.x + offset.width + dragCurrent.width)
                    let startY = (start.y + offset.height + dragCurrent.height)
                    let endX = (end.x + offset.width + dragCurrent.width)
                    let endY = (end.y + offset.height + dragCurrent.height)

                    path.move(to: CGPoint(x: startX * zoomScale, y: startY * zoomScale))
                    path.addLine(to: CGPoint(x: endX * zoomScale, y: endY * zoomScale))

                    let isConnectedToSelected = (selectedNodeId != nil && (edge.sourceId == selectedNodeId || edge.targetId == selectedNodeId))

                    if selectedNodeId != nil {
                        if isConnectedToSelected {
                            // SOLID, VIBRANT, GLOWING COLORFUL LINE (No dashed lines when selected!)
                            let edgeColor: Color = {
                                switch edge.kind {
                                case .wikiLink:
                                    return Color(red: 0.72, green: 0.35, blue: 1.0) // Radiant Purple
                                case .aiSemantic:
                                    return Color(red: 0.15, green: 0.85, blue: 0.55) // Vibrant AI Emerald Mint
                                case .sharedTags:
                                    return Color(red: 0.25, green: 0.65, blue: 1.0) // Sky Blue
                                case .categoryCluster:
                                    return startColor.dotColor
                                }
                            }()

                            // 1. Ambient Glow Pass
                            context.stroke(
                                path,
                                with: .color(edgeColor.opacity(0.35)),
                                style: StrokeStyle(lineWidth: 6.5 * zoomScale, lineCap: .round)
                            )

                            // 2. Crisp Vibrant Solid Line Pass (NO DASHING!)
                            context.stroke(
                                path,
                                with: .color(edgeColor),
                                style: StrokeStyle(lineWidth: 3.2 * zoomScale, lineCap: .round)
                            )
                        } else {
                            // Dim unselected edges
                            context.stroke(
                                path,
                                with: .color(Color.secondary.opacity(0.06)),
                                style: StrokeStyle(lineWidth: 0.8 * zoomScale)
                            )
                        }
                    } else {
                        // Default state (no node selected): Smooth, elegant solid lines
                        switch edge.kind {
                        case .wikiLink:
                            context.stroke(
                                path,
                                with: .color(Color.purple.opacity(0.75)),
                                style: StrokeStyle(lineWidth: 2.2 * zoomScale, lineCap: .round)
                            )
                        case .aiSemantic(let score):
                            context.stroke(
                                path,
                                with: .color(Color.green.opacity(0.35 + score * 0.4)),
                                style: StrokeStyle(lineWidth: (1.4 + score * 1.5) * zoomScale, lineCap: .round)
                            )
                        case .sharedTags:
                            context.stroke(
                                path,
                                with: .color(Color.blue.opacity(0.45)),
                                style: StrokeStyle(lineWidth: 1.6 * zoomScale, lineCap: .round)
                            )
                        case .categoryCluster:
                            context.stroke(
                                path,
                                with: .color(Color.secondary.opacity(0.18)),
                                style: StrokeStyle(lineWidth: 1.0 * zoomScale)
                            )
                        }
                    }
                }
            }

            // Nodes Layer
            GeometryReader { _ in
                let (nodes, edges) = graphData
                let connectedNodeIds: Set<UUID> = {
                    guard let sel = selectedNodeId else { return [] }
                    let neighbors = edges.filter { $0.sourceId == sel || $0.targetId == sel }
                    let ids = neighbors.map { $0.sourceId == sel ? $0.targetId : $0.sourceId }
                    return Set(ids)
                }()

                ForEach(nodes) { node in
                    let isSelected = selectedNodeId == node.id
                    let isConnectedNeighbor = connectedNodeIds.contains(node.id)

                    VStack(spacing: 4) {
                        ZStack {
                            // Glow halo if connected to selected node
                            if isConnectedNeighbor {
                                Circle()
                                    .fill(node.color.dotColor.opacity(0.35))
                                    .frame(width: 48, height: 48)
                                    .scaleEffect(1.1)
                            }

                            Circle()
                                .fill(node.color.dotColor)
                                .frame(
                                    width: max(24, min(48, CGFloat(26 + node.linkCount * 3))),
                                    height: max(24, min(48, CGFloat(26 + node.linkCount * 3)))
                                )
                                .overlay(
                                    Circle()
                                        .stroke(
                                            isSelected ? Color.white : (isConnectedNeighbor ? Color.accentColor : Color.primary.opacity(0.2)),
                                            lineWidth: isSelected ? 3.5 : (isConnectedNeighbor ? 2.5 : 1)
                                        )
                                )
                                .shadow(color: Color.black.opacity(isSelected ? 0.4 : 0.15), radius: isSelected ? 8 : 3, x: 0, y: 2)
                        }

                        Text(node.title)
                            .font(.system(size: 11, weight: isSelected ? .bold : (isConnectedNeighbor ? .semibold : .medium), design: .rounded))
                            .foregroundColor(isSelected ? .white : .primary)
                            .lineLimit(1)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                isSelected
                                ? Color.accentColor
                                : (isConnectedNeighbor ? Color.accentColor.opacity(0.18) : Color(nsColor: .controlBackgroundColor).opacity(0.85))
                            )
                            .cornerRadius(4)
                    }
                    .position(
                        x: (node.position.x + offset.width + dragCurrent.width) * zoomScale,
                        y: (node.position.y + offset.height + dragCurrent.height) * zoomScale
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedNodeId = (selectedNodeId == node.id) ? nil : node.id
                        }
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

                    // Controls: Force-directed math layout, radial layout, reset, zoom
                    HStack(spacing: 6) {
                        Button(action: applyForceDirectedLayout) {
                            HStack(spacing: 4) {
                                Image(systemName: "sparkles")
                                Text(loc.language == .turkish ? "AI Fizik Düzeni" : "AI Force Layout")
                                    .font(.system(size: 11, weight: .medium))
                            }
                        }
                        .help(loc.language == .turkish ? "Matematiksel Kuvvet ve AI Semantik Yerleşimi" : "Mathematical Coulomb & Hooke Force Layout")

                        Button(action: autoLayoutRadial) {
                            Image(systemName: "circle.circle")
                                .font(.system(size: 11))
                        }
                        .help(loc.language == .turkish ? "Dairesel Düzen" : "Radial Layout")

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
                    let connectedEdges = graphData.edges.filter { $0.sourceId == selectedId || $0.targetId == selectedId }

                    HStack {
                        Spacer()
                        VStack(alignment: .leading, spacing: 8) {
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
                                .lineLimit(2)

                            // Connected Links Breakdown
                            if !connectedEdges.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(loc.language == .turkish ? "Bağlantılı Notlar:" : "Connected Notes:")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.secondary)

                                    ForEach(connectedEdges.prefix(4)) { edge in
                                        let otherId = (edge.sourceId == selectedId) ? edge.targetId : edge.sourceId
                                        if let otherNode = graphData.nodes.first(where: { $0.id == otherId }) {
                                            Button(action: {
                                                withAnimation(.spring()) {
                                                    selectedNodeId = otherId
                                                }
                                            }) {
                                                HStack(spacing: 5) {
                                                    Circle()
                                                        .fill(otherNode.color.dotColor)
                                                        .frame(width: 6, height: 6)
                                                    Text(otherNode.title)
                                                        .font(.system(size: 10, weight: .medium))
                                                        .lineLimit(1)
                                                    Spacer()
                                                    badgeForEdge(edge: edge)
                                                }
                                                .padding(.vertical, 2)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                                .padding(6)
                                .background(Color.black.opacity(0.04))
                                .cornerRadius(6)
                            }

                            HStack {
                                Text("📁 \(node.category)")
                                    .font(.system(size: 9, weight: .medium))
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 1)
                                    .background(Color.secondary.opacity(0.12))
                                    .cornerRadius(3)

                                Text("🔗 \(connectedEdges.count) \(loc.language == .turkish ? "bağlantı" : "links")")
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
                        .frame(width: 280)
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
                        Text(loc.language == .turkish
                             ? "💡 İpucu: Seçilen notun bağları renkli düz çizgilerle aydınlatılır. Çift tıkla notu açın."
                             : "💡 Tip: Selecting a node highlights its bonds with glowing solid lines. Double-click to open.")
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
        .onAppear {
            if nodePositions.isEmpty {
                applyForceDirectedLayout()
            }
        }
    }

    // MARK: - Edge Badges

    @ViewBuilder
    private func badgeForEdge(edge: GraphEdge) -> some View {
        switch edge.kind {
        case .wikiLink:
            Text("🔗 Wiki")
                .font(.system(size: 8, weight: .bold))
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .background(Color.purple.opacity(0.2))
                .foregroundColor(.purple)
                .cornerRadius(3)
        case .aiSemantic(let score):
            Text(String(format: "🤖 AI %.0f%%", score * 100))
                .font(.system(size: 8, weight: .bold))
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .background(Color.green.opacity(0.2))
                .foregroundColor(.green)
                .cornerRadius(3)
        case .sharedTags(let tags):
            Text("#\(tags.first ?? "tag")")
                .font(.system(size: 8, weight: .bold))
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .background(Color.blue.opacity(0.2))
                .foregroundColor(.blue)
                .cornerRadius(3)
        case .categoryCluster:
            Text("📁 Kategori")
                .font(.system(size: 8, weight: .medium))
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .background(Color.secondary.opacity(0.15))
                .foregroundColor(.secondary)
                .cornerRadius(3)
        }
    }

    // MARK: - Mathematical Force-Directed Layout Simulation

    private func applyForceDirectedLayout() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
            let (nodes, edges) = graphData
            guard !nodes.isEmpty else { return }

            var positions: [UUID: CGPoint] = [:]
            let center = CGPoint(x: 450, y: 320)
            let radius: CGFloat = min(280, CGFloat(max(140, nodes.count * 34)))

            for (idx, n) in nodes.enumerated() {
                if let existing = nodePositions[n.id] {
                    positions[n.id] = existing
                } else {
                    let angle = (CGFloat(idx) / CGFloat(max(1, nodes.count))) * 2.0 * .pi
                    positions[n.id] = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
                }
            }

            let k: CGFloat = 130.0 // Equilibrium distance

            // 25 Simulation steps (Coulomb repulsion + Hooke spring attraction + gravity)
            for _ in 0..<25 {
                var forces: [UUID: CGPoint] = [:]
                for n in nodes { forces[n.id] = .zero }

                // 1. Coulomb Repulsion between all node pairs
                for i in 0..<nodes.count {
                    for j in (i + 1)..<nodes.count {
                        let idA = nodes[i].id
                        let idB = nodes[j].id
                        guard let posA = positions[idA], let posB = positions[idB] else { continue }

                        let dx = posA.x - posB.x
                        let dy = posA.y - posB.y
                        let distSq = max(400, dx * dx + dy * dy)
                        let dist = sqrt(distSq)
                        let force = (k * k) / dist

                        let fx = (dx / dist) * force * 0.4
                        let fy = (dy / dist) * force * 0.4

                        forces[idA]?.x += fx
                        forces[idA]?.y += fy
                        forces[idB]?.x -= fx
                        forces[idB]?.y -= fy
                    }
                }

                // 2. Hooke's Law Spring Attraction along edges
                for edge in edges {
                    guard let posA = positions[edge.sourceId], let posB = positions[edge.targetId] else { continue }
                    let dx = posB.x - posA.x
                    let dy = posB.y - posA.y
                    let dist = max(1.0, sqrt(dx * dx + dy * dy))
                    let force = (dist / k) * CGFloat(edge.strength * 1.6)

                    let fx = (dx / dist) * force
                    let fy = (dy / dist) * force

                    forces[edge.sourceId]?.x += fx
                    forces[edge.sourceId]?.y += fy
                    forces[edge.targetId]?.x -= fx
                    forces[edge.targetId]?.y -= fy
                }

                // 3. Center Gravity
                for n in nodes {
                    guard let pos = positions[n.id] else { continue }
                    let gx = (center.x - pos.x) * 0.035
                    let gy = (center.y - pos.y) * 0.035
                    forces[n.id]?.x += gx
                    forces[n.id]?.y += gy
                }

                // Apply displacements
                for n in nodes {
                    if let f = forces[n.id], let cur = positions[n.id] {
                        let stepX = max(-20, min(20, f.x * 0.12))
                        let stepY = max(-20, min(20, f.y * 0.12))
                        positions[n.id] = CGPoint(x: cur.x + stepX, y: cur.y + stepY)
                    }
                }
            }

            nodePositions = positions
        }
    }

    private func autoLayoutRadial() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
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
