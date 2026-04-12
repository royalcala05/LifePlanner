import Foundation
import UserNotifications

final class NotificationScheduler: NSObject, UNUserNotificationCenterDelegate {
    private enum Constants {
        static let calendarCheckIdentifier = "lifeplanner.calendar-check.every-four-hours"
        static let fourHours: TimeInterval = 4 * 60 * 60
    }

    private let notificationCenter: UNUserNotificationCenter

    init(notificationCenter: UNUserNotificationCenter = .current()) {
        self.notificationCenter = notificationCenter
        super.init()
        notificationCenter.delegate = self
    }

    func startCalendarCheckNotifications() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { isGranted, error in
            if let error {
                NSLog("Failed to request notification permission: \(error.localizedDescription)")
                return
            }

            guard isGranted else {
                NSLog("LifePlanner notification permission was not granted.")
                return
            }

            Self.scheduleCalendarCheckNotification()
        }
    }

    private static func scheduleCalendarCheckNotification() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [Constants.calendarCheckIdentifier])

        let content = UNMutableNotificationContent()
        content.title = "Check LifePlanner"
        content.body = "Review your calendar and backlog so nothing slips."
        content.sound = .default
        content.threadIdentifier = "lifeplanner.calendar-check"

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: Constants.fourHours,
            repeats: true
        )
        let request = UNNotificationRequest(
            identifier: Constants.calendarCheckIdentifier,
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error {
                NSLog("Failed to schedule calendar check notification: \(error.localizedDescription)")
            }
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound])
    }
}
