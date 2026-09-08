import Foundation
import UserNotifications
import AppKit

public final class ReminderService: NSObject, UNUserNotificationCenterDelegate, @unchecked Sendable {
    public static let shared = ReminderService()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    public func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }

    public func scheduleReminder(noteId: UUID, title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "📌 NotesMy: \(title.isEmpty ? "Reminder" : title)"
        content.body = String(body.prefix(120))
        content.sound = .default
        content.userInfo = ["noteId": noteId.uuidString]

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: "reminder_\(noteId.uuidString)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule reminder: \(error)")
            }
        }
    }

    public func cancelReminder(for noteId: UUID) {
        let identifier = "reminder_\(noteId.uuidString)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if let idString = response.notification.request.content.userInfo["noteId"] as? String,
           let noteId = UUID(uuidString: idString) {
            Task { @MainActor in
                NoteWindowManager.shared.openNote(id: noteId)
            }
        }
        completionHandler()
    }
}
