import SwiftUI

public struct SecondBrainChatView: View {
    @ObservedObject var store = NoteStore.shared
    @ObservedObject var loc = LocalizationService.shared

    @State private var messages: [SecondBrainMessage] = []
    @State private var inputPrompt: String = ""
    @State private var isThinking: Bool = false

    public init() {}

    private var isTurkish: Bool {
        loc.language == .turkish
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.purple)
                        .font(.system(size: 16))
                    VStack(alignment: .leading, spacing: 1) {
                        Text(isTurkish ? "AI İkinci Beyin (Second Brain)" : "AI Second Brain Assistant")
                            .font(.system(size: 13, weight: .bold))
                        Text(isTurkish ? "Tüm notlarınız üzerinde akıllı soru-cevap ve analiz" : "Ask questions, synthesize insights, and plan your day")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()

                Button(isTurkish ? "Temizle" : "Clear") {
                    messages.removeAll()
                }
                .font(.system(size: 11))
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            // Quick Actions Bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    quickButton(
                        icon: "calendar.badge.clock",
                        title: isTurkish ? "🌅 Akıllı Günlük Plan" : "🌅 Smart Daily Plan",
                        action: generateDailyPlan
                    )
                    quickButton(
                        icon: "checklist",
                        title: isTurkish ? "✅ Bekleyen Tüm Görevler" : "✅ All Pending Tasks",
                        action: { submitQuery("List all pending checklist action items across my notes") }
                    )
                    quickButton(
                        icon: "lightbulb",
                        title: isTurkish ? "💡 Fikirlerimi Özetle" : "💡 Summarize My Ideas",
                        action: { submitQuery("What are the main ideas and brainstorms in my notes?") }
                    )
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .background(Color.black.opacity(0.02))

            Divider()

            // Chat Messages Thread
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 14) {
                        if messages.isEmpty {
                            emptyPlaceholder
                        } else {
                            ForEach(messages) { msg in
                                messageRow(msg)
                            }
                        }

                        if isThinking {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.7)
                                Text(isTurkish ? "İkinci beyin notları tarıyor..." : "Second brain scanning notes...")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal, 14)
                        }
                    }
                    .padding(14)
                }
                .onChange(of: messages.count) { _ in
                    if let last = messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            Divider()

            // Input Bar
            HStack(spacing: 8) {
                TextField(
                    isTurkish ? "Notlarınız hakkında bir soru sorun..." : "Ask anything about your notes...",
                    text: $inputPrompt
                )
                .textFieldStyle(.plain)
                .padding(8)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(8)
                .onSubmit {
                    submitCurrentInput()
                }

                Button(action: submitCurrentInput) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(inputPrompt.trimmingCharacters(in: .whitespaces).isEmpty ? .secondary : .purple)
                }
                .buttonStyle(.plain)
                .disabled(inputPrompt.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(12)
            .background(Color(nsColor: .windowBackgroundColor))
        }
    }

    private var emptyPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(.purple.opacity(0.6))
            Text(isTurkish ? "Notlarınızla Konuşun" : "Chat with Your Second Brain")
                .font(.system(size: 14, weight: .bold))
            Text(isTurkish ? "Tüm notlarınız, toplantı kayıtlarınız ve yapılacaklar listeniz tek bir akıllı yapay zeka hafızasında birleşti." : "Your personal knowledge base powered 100% locally by on-device Apple Intelligence.")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.vertical, 40)
    }

    private func quickButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                Text(title)
                    .font(.system(size: 11, weight: .medium))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.purple.opacity(0.12))
            .foregroundColor(.purple)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }

    private func messageRow(_ msg: SecondBrainMessage) -> some View {
        HStack(alignment: .top, spacing: 10) {
            if msg.role == .user {
                Spacer()
                Text(msg.text)
                    .font(.system(size: 12))
                    .padding(10)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .frame(maxWidth: 360, alignment: .trailing)
            } else {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.purple)
                    .font(.system(size: 14))
                    .padding(.top, 4)

                VStack(alignment: .leading, spacing: 8) {
                    Text(msg.text)
                        .font(.system(size: 12))
                        .padding(10)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(10)

                    // Reference Cards
                    if !msg.referencedNoteIds.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(isTurkish ? "Referans Notlar:" : "Referenced Notes:")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.secondary)

                            HStack(spacing: 6) {
                                ForEach(msg.referencedNoteIds, id: \.self) { id in
                                    if let note = store.notes.first(where: { $0.id == id }) {
                                        Button(action: {
                                            NoteWindowManager.shared.openNote(id: id)
                                        }) {
                                            HStack(spacing: 4) {
                                                Circle().fill(note.color.dotColor).frame(width: 6, height: 6)
                                                Text(note.displayTitle)
                                                    .font(.system(size: 10, weight: .medium))
                                                    .lineLimit(1)
                                            }
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 3)
                                            .background(Color.black.opacity(0.06))
                                            .cornerRadius(4)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
        }
        .id(msg.id)
    }

    private func submitCurrentInput() {
        let text = inputPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputPrompt = ""
        submitQuery(text)
    }

    private func submitQuery(_ text: String) {
        messages.append(SecondBrainMessage(role: .user, text: text))
        isThinking = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let result = SecondBrainService.shared.querySecondBrain(prompt: text, isTurkish: isTurkish)
            messages.append(SecondBrainMessage(
                role: .assistant,
                text: result.response,
                referencedNoteIds: result.references.map { $0.id }
            ))
            isThinking = false
        }
    }

    private func generateDailyPlan() {
        messages.append(SecondBrainMessage(
            role: .user,
            text: isTurkish ? "Bugünün akıllı odak planını çıkar" : "Generate today's smart daily focus plan"
        ))
        isThinking = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let plan = SecondBrainService.shared.generateDailyPlan(isTurkish: isTurkish)
            messages.append(SecondBrainMessage(
                role: .assistant,
                text: plan
            ))
            isThinking = false
        }
    }
}
