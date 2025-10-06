import Foundation
import UserNotifications

/// Coordinates notification permissions and scheduling.
@MainActor
final class NotificationManager {
    static let shared = NotificationManager()

    private let timerIdentifier = "com.penguintosh.PenguinTomato.timer"
    private var didLogUnavailable = false

    private init() {}

    private var notificationCenter: UNUserNotificationCenter? {
        guard Bundle.main.bundleURL.pathExtension == "app" else {
            logUnavailable()
            return nil
        }
        return UNUserNotificationCenter.current()
    }

    func requestAuthorization() {
        guard let center = notificationCenter else { return }
        center.requestAuthorization(options: [.alert, .sound]) { _, error in
            if let error {
                NSLog("PenguinTomato notifications authorization error: \(error.localizedDescription)")
            }
        }
    }

    func scheduleTimerNotification(after seconds: Int, message: String) {
        guard seconds > 0, let center = notificationCenter else { return }
        let content = UNMutableNotificationContent()
        content.title = "PenguinTomato"
        content.body = message
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
        let request = UNNotificationRequest(identifier: timerIdentifier, content: content, trigger: trigger)
        center.add(request) { error in
            if let error {
                NSLog("PenguinTomato notifications schedule error: \(error.localizedDescription)")
            }
        }
    }

    func cancelPending() {
        guard let center = notificationCenter else { return }
        center.removePendingNotificationRequests(withIdentifiers: [timerIdentifier])
    }

    func deliverCompletionNotification(message: String) {
        guard let center = notificationCenter else { return }
        let content = UNMutableNotificationContent()
        content.title = "PenguinTomato"
        content.body = message
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        center.add(request) { error in
            if let error {
                NSLog("PenguinTomato notifications delivery error: \(error.localizedDescription)")
            }
        }
    }

    private func logUnavailable() {
        guard !didLogUnavailable else { return }
        didLogUnavailable = true
        NSLog("PenguinTomato notifications unavailable: not running from an app bundle")
    }
}
