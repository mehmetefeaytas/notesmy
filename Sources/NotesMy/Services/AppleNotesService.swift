import Foundation
import AppKit

public final class AppleNotesService: Sendable {
    public static let shared = AppleNotesService()

    private init() {}

    // MARK: - Export to Apple Notes
    @discardableResult
    public func sendToAppleNotes(title: String, body: String) -> Bool {
        let cleanTitle = title.replacingOccurrences(of: "\"", with: "\\\"")
        let htmlBody = body
            .replacingOccurrences(of: "\n", with: "<br>")
            .replacingOccurrences(of: "\"", with: "\\\"")

        let script = """
        tell application "Notes"
            tell default account
                if not (exists folder "NotesMy") then
                    make new folder with properties {name:"NotesMy"}
                end if
                make new note at folder "NotesMy" with properties {name:"\(cleanTitle)", body:"<h1>\(cleanTitle)</h1><br>\(htmlBody)"}
            end tell
        end tell
        """

        if let appleScript = NSAppleScript(source: script) {
            var errorInfo: NSDictionary?
            appleScript.executeAndReturnError(&errorInfo)
            return errorInfo == nil
        }
        return false
    }

    // MARK: - Export to macOS Reminders
    @discardableResult
    public func sendToReminders(title: String, notes: String, dueDate: Date? = nil) -> Bool {
        let cleanTitle = title.replacingOccurrences(of: "\"", with: "\\\"")
        let cleanNotes = notes.replacingOccurrences(of: "\"", with: "\\\"")

        var dateScript = ""
        if let due = dueDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateStr = formatter.string(from: due)
            dateScript = "due date:date \"\(dateStr)\","
        }

        let script = """
        tell application "Reminders"
            tell list "Reminders"
                make new reminder with properties {name:"\(cleanTitle)", body:"\(cleanNotes)", \(dateScript) completed:false}
            end tell
        end tell
        """

        if let appleScript = NSAppleScript(source: script) {
            var errorInfo: NSDictionary?
            appleScript.executeAndReturnError(&errorInfo)
            return errorInfo == nil
        }
        return false
    }

    // MARK: - Import Recent Notes from Apple Notes
    public func fetchRecentAppleNotes(limit: Int = 5) -> [(title: String, body: String)] {
        let script = """
        tell application "Notes"
            set noteList to {}
            set recentNotes to notes of default account
            set maxCount to \(limit)
            if (count of recentNotes) < maxCount then
                set maxCount to count of recentNotes
            end if
            repeat with i from 1 to maxCount
                set end of noteList to (name of item i of recentNotes & "|||" & plaintext of item i of recentNotes)
            end repeat
            return noteList
        end tell
        """

        var results: [(title: String, body: String)] = []
        if let appleScript = NSAppleScript(source: script) {
            var errorInfo: NSDictionary?
            let output = appleScript.executeAndReturnError(&errorInfo)
            if errorInfo == nil {
                let count = output.numberOfItems
                for i in 1...count {
                    if let item = output.atIndex(i)?.stringValue {
                        let parts = item.components(separatedBy: "|||")
                        if parts.count >= 2 {
                            results.append((title: parts[0], body: parts[1]))
                        }
                    }
                }
            }
        }
        return results
    }
}
