import Foundation

@MainActor
final class DailyEmailSummaryScheduler: NSObject {
    private let storage: AppStorage
    private let recipientEmail: String
    private let calendar: Calendar
    private var timer: Timer?

    init(
        storage: AppStorage,
        recipientEmail: String,
        calendar: Calendar = .current
    ) {
        self.storage = storage
        self.recipientEmail = recipientEmail
        self.calendar = calendar
        super.init()
    }

    func start() {
        scheduleNextRun()
    }

    private func scheduleNextRun() {
        timer?.invalidate()

        let now = Date()
        guard let nextRunDate = nextRunDate(after: now) else {
            NSLog("Failed to schedule LifePlanner daily email summary.")
            return
        }

        timer = Timer(
            fireAt: nextRunDate,
            interval: 0,
            target: self,
            selector: #selector(sendSummaryAndReschedule),
            userInfo: nil,
            repeats: false
        )

        RunLoop.main.add(timer!, forMode: .common)
    }

    private func nextRunDate(after date: Date) -> Date? {
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = 23
        components.minute = 55
        components.second = 0

        guard let tonight = calendar.date(from: components) else {
            return nil
        }

        if tonight > date {
            return tonight
        }

        return calendar.date(byAdding: .day, value: 1, to: tonight)
    }

    @objc
    private func sendSummaryAndReschedule() {
        sendSummaryEmail()
        scheduleNextRun()
    }

    private func sendSummaryEmail() {
        do {
            let reminders = try storage.loadReminders().filter { $0.isCompleted == false }
            let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date())
            let tomorrowReminders = reminders
                .filter { reminder in
                    guard let targetDate = reminder.targetDate else {
                        return false
                    }
                    return calendar.isDate(targetDate, inSameDayAs: tomorrow)
                }
                .sorted { $0.createdAt < $1.createdAt }

            let miscellaneousReminders = reminders
                .filter { $0.targetDate == nil }
                .sorted { $0.createdAt < $1.createdAt }

            let subject = "LifePlanner summary for tomorrow"
            let body = emailBody(
                tomorrow: tomorrow,
                tomorrowReminders: tomorrowReminders,
                miscellaneousReminders: miscellaneousReminders
            )

            try sendEmail(subject: subject, body: body)
        } catch {
            NSLog("Failed to send LifePlanner daily email summary: \(error.localizedDescription)")
        }
    }

    private func emailBody(
        tomorrow: Date,
        tomorrowReminders: [ReminderItem],
        miscellaneousReminders: [ReminderItem]
    ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none

        var lines: [String] = [
            "LifePlanner Summary",
            "Tomorrow: \(dateFormatter.string(from: tomorrow))",
            "",
            "Tomorrow's Reminders"
        ]

        if tomorrowReminders.isEmpty {
            lines.append("- None scheduled")
        } else {
            lines.append(contentsOf: tomorrowReminders.map(summaryLine(for:)))
        }

        lines.append("")
        lines.append("Miscellaneous")

        if miscellaneousReminders.isEmpty {
            lines.append("- None")
        } else {
            lines.append(contentsOf: miscellaneousReminders.map(summaryLine(for:)))
        }

        lines.append("")
        lines.append("Sent automatically by LifePlanner.")
        return lines.joined(separator: "\n")
    }

    private func summaryLine(for reminder: ReminderItem) -> String {
        let tag = reminder.customTagName ?? reminder.finalCategory.displayName
        return "- [\(tag)] \(reminder.text)"
    }

    private func sendEmail(subject: String, body: String) throws {
        let script = """
        tell application "Mail"
            set newMessage to make new outgoing message with properties {subject:"\(subject.appleScriptEscaped)", content:"\(body.appleScriptEscaped)", visible:false}
            tell newMessage
                make new to recipient at end of to recipients with properties {address:"\(recipientEmail.appleScriptEscaped)"}
                send
            end tell
        end tell
        """

        var errorInfo: NSDictionary?
        guard let appleScript = NSAppleScript(source: script) else {
            throw EmailSummaryError.scriptCreationFailed
        }

        appleScript.executeAndReturnError(&errorInfo)

        if let errorInfo {
            throw EmailSummaryError.appleScriptFailed(errorInfo.description)
        }
    }
}

private enum EmailSummaryError: LocalizedError {
    case scriptCreationFailed
    case appleScriptFailed(String)

    var errorDescription: String? {
        switch self {
        case .scriptCreationFailed:
            return "Could not create the Mail AppleScript."
        case .appleScriptFailed(let details):
            return "Mail AppleScript failed: \(details)"
        }
    }
}

private extension String {
    var appleScriptEscaped: String {
        replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\r", with: "")
    }
}
