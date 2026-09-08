import Foundation

public struct NoteVersion: Identifiable, Codable, Equatable, Hashable, Sendable {
    public var id: UUID
    public var timestamp: Date
    public var title: String
    public var body: String
    public var summary: String

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        title: String,
        body: String,
        summary: String = ""
    ) {
        self.id = id
        self.timestamp = timestamp
        self.title = title
        self.body = body
        self.summary = summary
    }

    public var displayDate: String {
        timestamp.formatted(date: .abbreviated, time: .standard)
    }

    public var previewSnippet: String {
        let lines = body.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        return lines.prefix(2).joined(separator: " · ")
    }
}

public struct NoteComment: Identifiable, Codable, Equatable, Hashable, Sendable {
    public var id: UUID
    public var author: String
    public var text: String
    public var timestamp: Date

    public init(
        id: UUID = UUID(),
        author: String = "Me",
        text: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.author = author
        self.text = text
        self.timestamp = timestamp
    }

    public var displayTime: String {
        timestamp.formatted(date: .abbreviated, time: .shortened)
    }
}
