import SwiftUI
import WidgetKit

public struct NoteWidgetEntry: TimelineEntry {
    public let date: Date
    public let noteTitle: String
    public let noteSnippet: String
    public let noteColorHex: String
    public let checklistProgress: String?

    public init(
        date: Date = Date(),
        noteTitle: String = "Meeting Notes",
        noteSnippet: String = "Sprint review tomorrow at 10:00 AM",
        noteColorHex: String = "#FFFBEB",
        checklistProgress: String? = "2/3 tasks"
    ) {
        self.date = date
        self.noteTitle = noteTitle
        self.noteSnippet = noteSnippet
        self.noteColorHex = noteColorHex
        self.checklistProgress = checklistProgress
    }
}

public struct NoteWidgetEntryView: View {
    public var entry: NoteWidgetEntry

    public init(entry: NoteWidgetEntry) {
        self.entry = entry
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "note.text")
                    .font(.system(size: 11))
                    .foregroundColor(.orange)

                Text(entry.noteTitle)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .lineLimit(1)

                Spacer()

                if let prog = entry.checklistProgress {
                    Text(prog)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }

            Text(entry.noteSnippet)
                .font(.system(size: 11))
                .foregroundColor(.primary.opacity(0.8))
                .lineLimit(4)

            Spacer(minLength: 0)

            HStack {
                Text(entry.date.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                Spacer()
                Text("NotesMy")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.7))
            }
        }
        .padding(12)
        .background(Color.yellow.opacity(0.15))
    }
}
