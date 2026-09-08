import Foundation
@preconcurrency import NaturalLanguage

public struct SearchFilters: Equatable {
    public var query: String = ""
    public var category: String = "All"
    public var color: NoteColor? = nil
    public var isFavoriteOnly: Bool = false
    public var isPinnedOnly: Bool = false
    public var hasChecklistOnly: Bool = false
    public var isSemanticSearchEnabled: Bool = true

    public init() {}
}

public final class SearchEngine: @unchecked Sendable {
    public static let shared = SearchEngine()

    private let englishEmbedding: NLEmbedding? = {
        NLEmbedding.wordEmbedding(for: .english)
    }()

    private init() {}

    public func search(notes: [NoteItem], with filters: SearchFilters) -> [NoteItem] {
        var results = notes

        // 1. Filter by category
        if filters.category != "All" {
            results = results.filter { $0.category == filters.category }
        }

        // 2. Filter by color
        if let color = filters.color {
            results = results.filter { $0.color == color }
        }

        // 3. Filter by favorites
        if filters.isFavoriteOnly {
            results = results.filter { $0.isFavorite }
        }

        // 4. Filter by pinned
        if filters.isPinnedOnly {
            results = results.filter { $0.isPinned }
        }

        // 5. Filter by checklist
        if filters.hasChecklistOnly {
            results = results.filter { !$0.checklistItems.isEmpty }
        }

        // 6. Text query search (Lexical + Semantic)
        let query = filters.query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return results }

        let queryTokens = query.components(separatedBy: .whitespaces).filter { !$0.isEmpty }

        return results.filter { note in
            let fullText = "\(note.title) \(note.body) \(note.category) \(note.tags.joined(separator: " "))".lowercased()

            // Exact lexical match
            if queryTokens.allSatisfy({ fullText.contains($0) }) {
                return true
            }

            // Semantic embedding match if enabled
            if filters.isSemanticSearchEnabled, let embedding = self.englishEmbedding {
                let noteWords = fullText.components(separatedBy: CharacterSet.alphanumerics.inverted)
                    .filter { $0.count > 3 }
                    .prefix(30)

                for qToken in queryTokens {
                    for nWord in noteWords {
                        let distance = embedding.distance(between: qToken, and: nWord)
                        if distance < 1.05 { // close semantic concept
                            return true
                        }
                    }
                }
            }

            return false
        }
    }
}
