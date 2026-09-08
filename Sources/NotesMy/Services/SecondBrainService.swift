import Foundation
@preconcurrency import NaturalLanguage

public struct SecondBrainMessage: Identifiable, Equatable, Sendable {
    public var id: UUID
    public var role: MessageRole
    public var text: String
    public var referencedNoteIds: [UUID]
    public var timestamp: Date

    public enum MessageRole: String, Sendable {
        case user
        case assistant
    }

    public init(
        id: UUID = UUID(),
        role: MessageRole,
        text: String,
        referencedNoteIds: [UUID] = [],
        timestamp: Date = Date()
    ) {
        self.id = id
        self.role = role
        self.text = text
        self.referencedNoteIds = referencedNoteIds
        self.timestamp = timestamp
    }
}

public final class SecondBrainService: @unchecked Sendable {
    public static let shared = SecondBrainService()

    private let embedding: NLEmbedding? = {
        NLEmbedding.wordEmbedding(for: .english)
    }()

    private init() {}

    // MARK: - 1. Chat with your Notes (AI Second Brain)
    @MainActor
    public func querySecondBrain(prompt: String, isTurkish: Bool = false) -> (response: String, references: [NoteItem]) {
        let store = NoteStore.shared
        let allNotes = store.activeNotes
        guard !allNotes.isEmpty else {
            return (
                isTurkish ? "Henüz kayıtlı notunuz bulunmuyor. Birkaç not ekledikten sonra bana sorular sorabilirsiniz!" :
                "You don't have any active notes yet. Add some notes to start asking your Second Brain!",
                []
            )
        }

        let cleanPrompt = prompt.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let promptTokens = cleanPrompt.components(separatedBy: CharacterSet.alphanumerics.inverted).filter { $0.count > 2 }

        // Score notes based on prompt match
        var scored: [(note: NoteItem, score: Double)] = []

        for note in allNotes {
            var score: Double = 0.0
            let noteContent = "\(note.title) \(note.body) \(note.category) \(note.tags.joined(separator: " "))".lowercased()

            for token in promptTokens {
                if noteContent.contains(token) {
                    score += 3.0
                }
                if note.title.lowercased().contains(token) {
                    score += 5.0
                }
            }

            // Semantic distance boost
            if let emb = embedding {
                let sampleWords = noteContent.components(separatedBy: CharacterSet.alphanumerics.inverted).filter { $0.count > 3 }.prefix(20)
                for pTok in promptTokens {
                    for nWord in sampleWords {
                        let dist = emb.distance(between: pTok, and: nWord)
                        if dist < 0.95 {
                            score += (1.0 - dist) * 2.0
                        }
                    }
                }
            }

            if score > 0 {
                scored.append((note, score))
            }
        }

        scored.sort(by: { $0.score > $1.score })
        let topReferences = scored.prefix(4).map { $0.note }

        if topReferences.isEmpty {
            let fallbackNotes = Array(allNotes.prefix(2))
            let msg = isTurkish
                ? "Notlarınız arasında doğrudan bu konuyla eşleşen bir kayıt bulamadım, ancak genel notlarınızı tarayabilirsiniz."
                : "I couldn't find notes directly matching this query in your Second Brain. Try rephrasing or adding related keywords."
            return (msg, fallbackNotes)
        }

        // Synthesize response based on top notes
        var answer = ""
        if isTurkish {
            answer += "🧠 **İkinci Beyin Yanıtı:**\n\n"
            answer += "Sorunuza ilişkin notlarınız incelendi:\n\n"
            for note in topReferences {
                answer += "• **\(note.displayTitle)** (\(note.category)):\n"
                answer += "  > \(note.previewSnippet)\n"
                if let prog = note.checklistProgress {
                    answer += "  *(Görev durumu: \(prog.completed)/\(prog.total) tamamlandı)*\n"
                }
            }
            answer += "\n💡 *Öneri:* İlgili nota gitmek için referans kartlarına tıklayabilirsiniz."
        } else {
            answer += "🧠 **Second Brain Synthesis:**\n\n"
            answer += "Here is what I found across your knowledge base:\n\n"
            for note in topReferences {
                answer += "• **\(note.displayTitle)** (\(note.category)):\n"
                answer += "  > \(note.previewSnippet)\n"
                if let prog = note.checklistProgress {
                    answer += "  *(Tasks: \(prog.completed)/\(prog.total) completed)*\n"
                }
            }
            answer += "\n💡 *Tip:* Click any reference below to view the full note in context."
        }

        return (answer, topReferences)
    }

    // MARK: - 2. Smart Daily Planner (Akıllı Günlük Plan)
    @MainActor
    public func generateDailyPlan(isTurkish: Bool = false) -> String {
        let store = NoteStore.shared
        let notes = store.activeNotes

        var allPendingTasks: [(task: String, noteTitle: String)] = []
        var upcomingReminders: [(title: String, date: Date)] = []

        for note in notes {
            for item in note.checklistItems where !item.isChecked {
                allPendingTasks.append((item.text, note.displayTitle))
            }
            if let rem = note.reminderDate {
                upcomingReminders.append((note.displayTitle, rem))
            }
        }

        var plan = ""
        let dateHeader = Date().formatted(date: .complete, time: .omitted)

        if isTurkish {
            plan += "## 🌅 Akıllı Günlük Odak Planı — \(dateHeader)\n\n"
            plan += "> *Tüm notlarınız taranarak bekleyen görevler ve öncelikler harmanlandı.*\n\n"

            if !upcomingReminders.isEmpty {
                plan += "### 🔔 Bugünün Hatırlatıcıları:\n"
                for rem in upcomingReminders.prefix(4) {
                    plan += "- ⏰ **\(rem.date.formatted(date: .omitted, time: .shortened))**: \(rem.title)\n"
                }
                plan += "\n"
            }

            plan += "### 🎯 Öncelikli Yapılacaklar Listesi:\n"
            if allPendingTasks.isEmpty {
                plan += "- [ ] Tüm görevleriniz tamamlanmış! Yeni hedefler belirleyin.\n"
            } else {
                for t in allPendingTasks.prefix(8) {
                    plan += "- [ ] \(t.task) *(Kaynak: \(t.noteTitle))*\n"
                }
            }

            plan += "\n### 💡 Günün Verimlilik İpucu:\n"
            plan += "Derin odak gerektiren en kritik ilk 2 görevi öğleden önce tamamlayın."
        } else {
            plan += "## 🌅 Smart Daily Focus Plan — \(dateHeader)\n\n"
            plan += "> *Synthesized from pending action items and schedules across all your active notes.*\n\n"

            if !upcomingReminders.isEmpty {
                plan += "### 🔔 Scheduled Reminders & Deadlines:\n"
                for rem in upcomingReminders.prefix(4) {
                    plan += "- ⏰ **\(rem.date.formatted(date: .omitted, time: .shortened))**: \(rem.title)\n"
                }
                plan += "\n"
            }

            plan += "### 🎯 Priority Action Items:\n"
            if allPendingTasks.isEmpty {
                plan += "- [ ] All caught up! No pending checklists found in your notes.\n"
            } else {
                for t in allPendingTasks.prefix(8) {
                    plan += "- [ ] \(t.task) *(from: \(t.noteTitle))*\n"
                }
            }

            plan += "\n### 💡 Daily Productivity Tip:\n"
            plan += "Block out 90 minutes for deep work on priority items before checking messages."
        }

        return plan
    }
}
