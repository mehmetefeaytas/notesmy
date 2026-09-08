import Foundation
import EventKit
import AppKit

public final class CalendarSyncService: @unchecked Sendable {
    public static let shared = CalendarSyncService()
    private let eventStore = EKEventStore()

    private init() {}

    public func exportNoteAsICS(note: NoteItem) -> URL? {
        let title = note.displayTitle
        let description = note.body
        let date = note.reminderDate ?? Date().addingTimeInterval(3600)
        let endDate = date.addingTimeInterval(3600)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        let createdStr = dateFormatter.string(from: note.createdAt)
        let startStr = dateFormatter.string(from: date)
        let endStr = dateFormatter.string(from: endDate)

        let icsContent = """
        BEGIN:VCALENDAR
        VERSION:2.0
        PRODID:-//NotesMy//macOS//EN
        CALSCALE:GREGORIAN
        METHOD:PUBLISH
        BEGIN:VEVENT
        UID:\(note.id.uuidString)@notesmy.app
        DTSTAMP:\(createdStr)
        DTSTART:\(startStr)
        DTEND:\(endStr)
        SUMMARY:\(title)
        DESCRIPTION:\(description.replacingOccurrences(of: "\n", with: "\\n"))
        STATUS:CONFIRMED
        END:VEVENT
        END:VCALENDAR
        """

        let tempDir = FileManager.default.temporaryDirectory
        let icsURL = tempDir.appendingPathComponent("NotesMy_\(note.id.uuidString.prefix(6)).ics")
        do {
            try icsContent.write(to: icsURL, atomically: true, encoding: .utf8)
            return icsURL
        } catch {
            return nil
        }
    }

    public func openInCalendarApp(note: NoteItem) {
        if let ics = exportNoteAsICS(note: note) {
            NSWorkspace.shared.open(ics)
        }
    }
}
