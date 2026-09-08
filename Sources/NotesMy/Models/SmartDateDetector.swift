import Foundation
import AppKit

public struct SmartDateInfo: Identifiable, Hashable, Sendable {
    public let id: String
    public let originalText: String
    public let date: Date
    public let formattedDescription: String

    public init(originalText: String, date: Date) {
        self.id = "\(originalText)_\(date.timeIntervalSince1970)"
        self.originalText = originalText
        self.date = date

        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        self.formattedDescription = formatter.string(from: date)
    }
}

public final class SmartDateDetector: Sendable {
    public static let shared = SmartDateDetector()

    private let detector: NSDataDetector? = {
        try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
    }()

    public func detectDates(in text: String) -> [SmartDateInfo] {
        guard let detector = detector, !text.isEmpty else { return [] }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        let matches = detector.matches(in: text, options: [], range: range)

        var results: [SmartDateInfo] = []
        for match in matches {
            if let date = match.date,
               let matchRange = Range(match.range, in: text) {
                let matchString = String(text[matchRange])
                results.append(SmartDateInfo(originalText: matchString, date: date))
            }
        }
        return results
    }

    @MainActor
    public func createCalendarEvent(title: String, date: Date) {
        let dummy = NoteItem(
            title: title,
            body: "Scheduled event from NotesMy on \(date.formatted(date: .abbreviated, time: .shortened))",
            color: .amber,
            reminderDate: date
        )
        CalendarSyncService.shared.openInCalendarApp(note: dummy)
    }
}
