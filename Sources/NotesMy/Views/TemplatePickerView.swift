import SwiftUI

public struct TemplatePickerView: View {
    @ObservedObject var store = NoteStore.shared
    @ObservedObject var loc = LocalizationService.shared
    public var noteId: UUID?
    public var onSelect: (NoteTemplate) -> Void

    public init(noteId: UUID? = nil, onSelect: @escaping (NoteTemplate) -> Void) {
        self.noteId = noteId
        self.onSelect = onSelect
    }

    private var isTurkish: Bool {
        loc.language == .turkish
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "square.dashed.inset.filled")
                    .foregroundColor(.accentColor)
                Text(isTurkish ? "Not Şablonu Seçin" : "Choose a Note Template")
                    .font(.system(size: 13, weight: .bold))
                Spacer()
            }

            Text(isTurkish ? "Hazır şablonlarla notlarınızı hızlıca yapılandırın:" : "Kickstart your notes with pre-structured formats:")
                .font(.system(size: 11))
                .foregroundColor(.secondary)

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(NoteTemplate.builtInTemplates) { template in
                        Button(action: {
                            onSelect(template)
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: template.icon)
                                    .font(.system(size: 16))
                                    .foregroundColor(.accentColor)
                                    .frame(width: 24)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(isTurkish ? template.titleTr : template.title)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.primary)

                                    Text(template.category)
                                        .font(.system(size: 9))
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }
                            .padding(10)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 0.5)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(16)
        .frame(width: 320, height: 340)
    }
}
