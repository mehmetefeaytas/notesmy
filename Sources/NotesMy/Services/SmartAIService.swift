import Foundation
import NaturalLanguage

public enum AIStyle: String, CaseIterable, Identifiable, Sendable {
    case concise = "Concise & Punchy"
    case professional = "Professional"
    case bulletPoints = "Bullet Points"
    case actionItems = "Action Items (Checklist)"
    case organized = "Organized & Formatted"

    public var id: String { rawValue }
}

public final class SmartAIService: Sendable {
    public static let shared = SmartAIService()

    private init() {}

    // MARK: - 1. Format & Clean Up Messy Note (Dağınık Notu Düzenle)
    public func cleanAndFormatMessyNote(text: String, isTurkish: Bool) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }

        let lines = trimmed.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        guard let first = lines.first else { return trimmed }

        let tasks = extractActionItems(from: text)
        let bulletCandidates = lines.dropFirst().filter { line in
            !tasks.contains(where: { line.contains($0) })
        }

        var formatted = ""
        let titleLabel = isTurkish ? "📋 Düzenlenmiş Not" : "📋 Structured Note"
        let pointsLabel = isTurkish ? "📌 Ana Noktalar" : "📌 Key Takeaways"
        let actionsLabel = isTurkish ? "✅ Eylem Maddeleri" : "✅ Action Items"

        formatted += "## \(titleLabel): \(generateSmartTitle(for: first))\n\n"

        if !bulletCandidates.isEmpty {
            formatted += "### \(pointsLabel):\n"
            for point in bulletCandidates.prefix(6) {
                var clean = point
                if clean.hasPrefix("- ") || clean.hasPrefix("* ") {
                    clean = String(clean.dropFirst(2))
                }
                formatted += "• \(clean)\n"
            }
            formatted += "\n"
        }

        if !tasks.isEmpty {
            formatted += "### \(actionsLabel):\n"
            for task in tasks {
                formatted += "- [ ] \(task)\n"
            }
            formatted += "\n"
        } else {
            formatted += "### \(actionsLabel):\n"
            formatted += "- [ ] \(isTurkish ? "Notu gözden geçir ve tamamla" : "Review and complete task")\n\n"
        }

        return formatted.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - 2. Smart Executive Summary (Akıllı Özet)
    public func summarize(text: String) -> String {
        smartSummary(text: text, isTurkish: false)
    }

    public func smartSummary(text: String, isTurkish: Bool) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }

        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = trimmed

        var sentences: [String] = []
        tokenizer.enumerateTokens(in: trimmed.startIndex..<trimmed.endIndex) { range, _ in
            let sentence = String(trimmed[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !sentence.isEmpty && sentence.count > 6 {
                sentences.append(sentence)
            }
            return true
        }

        let header = isTurkish ? "💡 **Yapay Zeka Özeti:**" : "💡 **Executive AI Summary:**"

        if sentences.count <= 2 {
            return "\(header)\n• \(trimmed)"
        }

        let topCount = min(3, sentences.count)
        let selected = sentences.prefix(topCount)
        return "\(header)\n" + selected.map { "• \($0)" }.joined(separator: "\n")
    }

    // MARK: - 3. Smart Title Generator
    public func generateSmartTitle(for body: String) -> String {
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "New Note" }

        let lines = trimmed.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        guard let first = lines.first else { return "New Note" }

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

    // MARK: - 4. Extract Action Items
    public func extractActionItems(from text: String) -> [String] {
        let actionKeywords = [
            "need to", "must", "todo", "to do", "action:", "task:", "remember to",
            "follow up", "call", "email", "review", "deliver", "ship", "fix",
            "buy", "schedule", "meet", "submit", "prepare", "finish", "update",
            "yapılacak", "gözden geçir", "ara", "gönder", "hazırla", "tamamla"
        ]

        var tasks: [String] = []
        let lines = text.components(separatedBy: .newlines)

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }

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

    // MARK: - 5. Smart Category & Tag Prediction
    public func predictCategory(for text: String) -> String {
        let lower = text.lowercased()

        let codeKeywords = ["swift", "func ", "let ", "var ", "docker", "git", "api", "curl", "npm", "json", "python", "bash", "class ", "http", "const"]
        let workKeywords = ["meeting", "toplantı", "sprint", "client", "quarter", "q3", "q4", "deadline", "project", "proje", "sync", "team", "review", "kpi"]
        let ideaKeywords = ["idea", "fikir", "concept", "what if", "brainstorm", "explore", "vision", "startup", "draft", "taslak", "future"]
        let personalKeywords = ["buy", "al", "groceries", "market", "flight", "doctor", "doktor", "workout", "gym", "spor", "recipe", "yemek", "kitap"]

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

    // MARK: - 6. Rewrite & Format Transform
    public func rewrite(text: String, style: AIStyle, isTurkish: Bool = false) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }

        switch style {
        case .organized:
            return cleanAndFormatMessyNote(text: text, isTurkish: isTurkish)

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
            refined = refined.replacingOccurrences(of: "bi ", with: "bir ")
            refined = refined.replacingOccurrences(of: "yapcam", with: "yapacağım")
            refined = refined.replacingOccurrences(of: "gelcem", with: "geleceğim")
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
