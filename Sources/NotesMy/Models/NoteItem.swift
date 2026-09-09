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
    public var windowX: Double?
    public var windowY: Double?
    public var tags: [String]
    public var attachments: [NoteAttachment]

    // Advanced features
    public var category: String
    public var isFolded: Bool
    public var opacity: Double
    public var isCodeMode: Bool
    public var isFavorite: Bool
    public var reminderDate: Date?
    public var versions: [NoteVersion]
    public var comments: [NoteComment]

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
        windowX: Double? = nil,
        windowY: Double? = nil,
        tags: [String] = [],
        attachments: [NoteAttachment] = [],
        category: String = "General",
        isFolded: Bool = false,
        opacity: Double = 1.0,
        isCodeMode: Bool = false,
        isFavorite: Bool = false,
        reminderDate: Date? = nil,
        versions: [NoteVersion] = [],
        comments: [NoteComment] = []
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
        self.windowX = windowX
        self.windowY = windowY
        self.tags = tags
        self.attachments = attachments
        self.category = category
        self.isFolded = isFolded
        self.opacity = opacity
        self.isCodeMode = isCodeMode
        self.isFavorite = isFavorite
        self.reminderDate = reminderDate
        self.versions = versions
        self.comments = comments
    }

    // Explicit Codable conformance for backwards compatibility
    enum CodingKeys: String, CodingKey {
        case id, title, body, color, createdAt, updatedAt, isPinned, isArchived
        case pinnedX, pinnedY, windowX, windowY, tags, attachments, category
        case isFolded, opacity, isCodeMode, isFavorite, reminderDate, versions, comments
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.body = try container.decodeIfPresent(String.self, forKey: .body) ?? ""
        self.color = try container.decodeIfPresent(NoteColor.self, forKey: .color) ?? .amber
        self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
        self.isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        self.isArchived = try container.decodeIfPresent(Bool.self, forKey: .isArchived) ?? false
        self.pinnedX = try container.decodeIfPresent(Double.self, forKey: .pinnedX)
        self.pinnedY = try container.decodeIfPresent(Double.self, forKey: .pinnedY)
        self.windowX = try container.decodeIfPresent(Double.self, forKey: .windowX)
        self.windowY = try container.decodeIfPresent(Double.self, forKey: .windowY)
        self.tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        self.attachments = try container.decodeIfPresent([NoteAttachment].self, forKey: .attachments) ?? []
        self.category = try container.decodeIfPresent(String.self, forKey: .category) ?? "General"
        self.isFolded = try container.decodeIfPresent(Bool.self, forKey: .isFolded) ?? false
        self.opacity = try container.decodeIfPresent(Double.self, forKey: .opacity) ?? 1.0
        self.isCodeMode = try container.decodeIfPresent(Bool.self, forKey: .isCodeMode) ?? false
        self.isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        self.reminderDate = try container.decodeIfPresent(Date.self, forKey: .reminderDate)
        self.versions = try container.decodeIfPresent([NoteVersion].self, forKey: .versions) ?? []
        self.comments = try container.decodeIfPresent([NoteComment].self, forKey: .comments) ?? []
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
            .compactMap { line -> String? in
                var clean = line.trimmingCharacters(in: .whitespaces)
                if clean.isEmpty { return nil }

                // Ignore table separator lines like | --- | :---: |
                if TableMarkdownHelper.isTableSeparator(line: clean) {
                    return nil
                }

                // Clean table rows: | Col 1 | Col 2 | -> Col 1 · Col 2
                if clean.contains("|") {
                    let cells = TableMarkdownHelper.splitRow(clean)
                    if !cells.isEmpty {
                        clean = cells.joined(separator: " · ")
                    }
                }

                // Strip Callout headers
                if clean.hasPrefix("> [!") && clean.contains("]") {
                    if let end = clean.range(of: "]") {
                        clean = String(clean[end.upperBound...]).trimmingCharacters(in: .whitespaces)
                        if clean.isEmpty { return nil }
                    }
                } else if clean.hasPrefix("> ") {
                    clean = String(clean.dropFirst(2)).trimmingCharacters(in: .whitespaces)
                }

                // Strip HTML toggle tags
                clean = clean.replacingOccurrences(of: "<details>", with: "")
                clean = clean.replacingOccurrences(of: "</details>", with: "")
                clean = clean.replacingOccurrences(of: "<summary>", with: "")
                clean = clean.replacingOccurrences(of: "</summary>", with: "")

                if clean.hasPrefix("#") {
                    clean = clean.trimmingCharacters(in: CharacterSet(charactersIn: "# "))
                }
                clean = clean.replacingOccurrences(of: "**", with: "")
                clean = clean.replacingOccurrences(of: "~~", with: "")
                clean = clean.replacingOccurrences(of: "==", with: "")
                clean = clean.replacingOccurrences(of: "`", with: "")
                if clean.hasPrefix("- [ ] ") || clean.hasPrefix("- [x] ") || clean.hasPrefix("- [X] ") {
                    clean = String(clean.dropFirst(6))
                } else if clean.hasPrefix("- ") || clean.hasPrefix("* ") {
                    clean = String(clean.dropFirst(2))
                }
                clean = clean.trimmingCharacters(in: .whitespaces)
                return clean.isEmpty ? nil : clean
            }
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

    public var outgoingWikiLinks: [String] {
        let pattern = "\\[\\[(.*?)\\]\\]"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let nsString = body as NSString
        let matches = regex.matches(in: body, range: NSRange(location: 0, length: nsString.length))
        return matches.compactMap { match in
            guard match.numberOfRanges > 1 else { return nil }
            return nsString.substring(with: match.range(at: 1)).trimmingCharacters(in: .whitespaces)
        }.filter { !$0.isEmpty }
    }
}
