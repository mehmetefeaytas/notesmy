import Foundation

public struct NoteAttachment: Identifiable, Codable, Equatable, Hashable, Sendable {
    public var id: UUID
    public var fileName: String
    public var relativePath: String
    public var mimeType: String
    public var dateAdded: Date

    public init(id: UUID = UUID(), fileName: String, relativePath: String, mimeType: String, dateAdded: Date = Date()) {
        self.id = id
        self.fileName = fileName
        self.relativePath = relativePath
        self.mimeType = mimeType
        self.dateAdded = dateAdded
    }
}

public struct ChecklistItem: Identifiable, Equatable, Sendable {
    public var id: UUID = UUID()
    public var text: String
    public var isChecked: Bool
    public var lineIndex: Int
}

public struct NoteItem: Identifiable, Codable, Equatable, Hashable, Sendable {
    public var id: UUID
    public var title: String
    public var body: String
    public var color: NoteColor
    public var createdAt: Date
    public var updatedAt: Date
    public var isPinned: Bool
    public var isArchived: Bool
    public var pinnedX: Double?
    public var pinnedY: Double?
    public var tags: [String]
    public var attachments: [NoteAttachment]

    public init(
        id: UUID = UUID(),
        title: String = "",
        body: String = "",
        color: NoteColor = .amber,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isPinned: Bool = false,
        isArchived: Bool = false,
        pinnedX: Double? = nil,
        pinnedY: Double? = nil,
        tags: [String] = [],
        attachments: [NoteAttachment] = []
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.color = color
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isPinned = isPinned
        self.isArchived = isArchived
        self.pinnedX = pinnedX
        self.pinnedY = pinnedY
        self.tags = tags
        self.attachments = attachments
    }

    public var displayTitle: String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { return trimmed }
        let firstLine = body.components(separatedBy: .newlines).first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !firstLine.isEmpty {
            return String(firstLine.prefix(40))
        }
        return "Untitled Note"
    }

    public var previewSnippet: String {
        let lines = body.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        if lines.isEmpty { return "Empty note..." }
        return lines.prefix(3).joined(separator: " · ")
    }

    public var checklistItems: [ChecklistItem] {
        var items: [ChecklistItem] = []
        let lines = body.components(separatedBy: .newlines)
        for (idx, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("- [x] ") || trimmed.hasPrefix("- [X] ") {
                let text = String(trimmed.dropFirst(6))
                items.append(ChecklistItem(text: text, isChecked: true, lineIndex: idx))
            } else if trimmed.hasPrefix("- [ ] ") {
                let text = String(trimmed.dropFirst(6))
                items.append(ChecklistItem(text: text, isChecked: false, lineIndex: idx))
            }
        }
        return items
    }

    public var checklistProgress: (completed: Int, total: Int)? {
        let items = checklistItems
        guard !items.isEmpty else { return nil }
        let completed = items.filter { $0.isChecked }.count
        return (completed, items.count)
    }
}
