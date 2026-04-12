import Foundation

enum DateParser {
    private static let weekdayTokens: [String: Int] = [
        "sun": 1, "sunday": 1,
        "mon": 2, "monday": 2,
        "tue": 3, "tues": 3, "tuesday": 3,
        "wed": 4, "wednesday": 4,
        "thu": 5, "thur": 5, "thurs": 5, "thursday": 5,
        "fri": 6, "friday": 6,
        "sat": 7, "saturday": 7
    ]

    static func targetDate(from text: String, now: Date = Date(), calendar: Calendar = .current) -> Date? {
        let normalized = text.lowercased()
        let startOfToday = calendar.startOfDay(for: now)

        if containsToken("today", in: normalized) {
            return startOfToday
        }

        if containsToken("tomorrow", in: normalized) {
            return calendar.date(byAdding: .day, value: 1, to: startOfToday)
        }

        let words = normalized.components(separatedBy: CharacterSet.alphanumerics.inverted)
        guard let targetWeekday = words.compactMap({ weekdayTokens[$0] }).first else {
            return nil
        }

        let currentWeekday = calendar.component(.weekday, from: startOfToday)
        let daysAhead = (targetWeekday - currentWeekday + 7) % 7
        return calendar.date(byAdding: .day, value: daysAhead, to: startOfToday)
    }

    private static func containsToken(_ token: String, in text: String) -> Bool {
        text.range(of: "\\b\(token)\\b", options: .regularExpression) != nil
    }
}
