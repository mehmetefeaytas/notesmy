import Foundation
import NaturalLanguage

public enum AIStyle: String, CaseIterable, Identifiable, Sendable {
    case concise = "Concise & Punchy"
    case professional = "Professional"
    case bulletPoints = "Bullet Points"
    case actionItems = "Action Items (Checklist)"

    public var id: String { rawValue }
}

public final class SmartAIService: Sendable {
    public static let shared = SmartAIService()

    private init() {}

    // MARK: - 1. Smart Title Generator
    public func generateSmartTitle(for body: String) -> String {
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "New Note" }

        let lines = trimmed.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        guard let first = lines.first else { return "New Note" }

        // Clean markdown symbols
        let clean = first.replacingOccurrences(of: "#", with: "")
            .replacingOccurrences(of: "- [ ]", with: "")
            .replacingOccurrences(of: "- [x]", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "*", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if clean.count > 35 {
            return String(clean.prefix(35)) + "..."
        }
        return clean.isEmpty ? "New Note" : clean
    }

    // MARK: - 2. Summarize Note
    public func summarize(text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }

        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = trimmed

        var sentences: [String] = []
        tokenizer.enumerateTokens(in: trimmed.startIndex..<trimmed.endIndex) { range, _ in
            let sentence = String(trimmed[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !sentence.isEmpty && sentence.count > 5 {
                sentences.append(sentence)
            }
            return true
        }

        if sentences.count <= 2 {
            return "📌 **Summary:** " + trimmed
        }

        let top = [sentences.first!, sentences[sentences.count / 2]]
        return "📌 **AI Summary:**\n" + top.map { "• \($0)" }.joined(separator: "\n")
    }

    // MARK: - 3. Extract Tasks & Action Items into Checklists
    public func extractActionItems(from text: String) -> [String] {
        let actionKeywords = [
            "need to", "must", "todo", "to do", "action:", "task:", "remember to",
            "follow up", "call", "email", "review", "deliver", "ship", "fix",
            "buy", "schedule", "meet", "submit", "prepare", "finish", "update"
        ]

        var tasks: [String] = []
        let lines = text.components(separatedBy: .newlines)

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }

            // Already a checklist item
            if trimmed.hasPrefix("- [ ]") || trimmed.hasPrefix("- [x]") {
                continue
            }

            let lower = trimmed.lowercased()
            let isAction = actionKeywords.contains { lower.contains($0) } || trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ")

            if isAction {
                var cleanTask = trimmed
                if cleanTask.hasPrefix("- ") || cleanTask.hasPrefix("* ") {
                    cleanTask = String(cleanTask.dropFirst(2))
                }
                tasks.append(cleanTask)
            }
        }

        return tasks
    }

    // MARK: - 4. Smart Category & Tag Prediction
    public func predictCategory(for text: String) -> String {
        let lower = text.lowercased()

        let codeKeywords = ["swift", "func ", "let ", "var ", "docker", "git", "api", "curl", "npm", "json", "python", "bash", "class ", "http", "const"]
        let workKeywords = ["meeting", "sprint", "client", "quarter", "q3", "q4", "deadline", "project", "sync", "team", "review", "kpi", "milestone"]
        let ideaKeywords = ["idea", "concept", "what if", "brainstorm", "explore", "vision", "startup", "draft", "future", "prototype"]
        let personalKeywords = ["buy", "groceries", "flight", "doctor", "workout", "gym", "recipe", "book", "family", "home"]

        var codeCount = 0
        var workCount = 0
        var ideaCount = 0
        var personalCount = 0

        for kw in codeKeywords where lower.contains(kw) { codeCount += 1 }
        for kw in workKeywords where lower.contains(kw) { workCount += 1 }
        for kw in ideaKeywords where lower.contains(kw) { ideaCount += 1 }
        for kw in personalKeywords where lower.contains(kw) { personalCount += 1 }

        let scores = [
            ("Code", codeCount),
            ("Work", workCount),
            ("Ideas", ideaCount),
            ("Personal", personalCount)
        ]

        if let best = scores.max(by: { $0.1 < $1.1 }), best.1 > 0 {
            return best.0
        }
        return "General"
    }

    // MARK: - 5. Rewrite & Format Transform
    public func rewrite(text: String, style: AIStyle) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }

        switch style {
        case .concise:
            let sentences = trimmed.components(separatedBy: ". ")
            let shortened = sentences.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .prefix(2)
                .joined(separator: ". ")
            return shortened + (shortened.hasSuffix(".") ? "" : ".")

        case .professional:
            var refined = trimmed
            refined = refined.replacingOccurrences(of: "gonna", with: "going to")
            refined = refined.replacingOccurrences(of: "wanna", with: "would like to")
            refined = refined.replacingOccurrences(of: "asap", with: "at your earliest convenience")
            return refined

        case .bulletPoints:
            let lines = trimmed.components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            return lines.map { "• \($0)" }.joined(separator: "\n")

        case .actionItems:
            let tasks = extractActionItems(from: text)
            if tasks.isEmpty {
                let lines = trimmed.components(separatedBy: .newlines)
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
                return lines.map { "- [ ] \($0)" }.joined(separator: "\n")
            }
            return tasks.map { "- [ ] \($0)" }.joined(separator: "\n")
        }
    }
}
