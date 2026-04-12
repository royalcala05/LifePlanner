import Foundation

@MainActor
final class PlannerViewModel: ObservableObject {
    struct DayBucket: Identifiable {
        let date: Date
        let reminders: [ReminderItem]

        var id: Date { date }
    }

    @Published var draftText: String = "" {
        didSet { refreshPrediction() }
    }
    @Published private(set) var prediction: ClassificationResult = .empty
    @Published private(set) var reminders: [ReminderItem] = []
    @Published private(set) var customTags: [String] = []
    @Published private(set) var latestSaveMessage: String?
    @Published var editingReminder: ReminderItem?
    @Published var selectedCategoryOverride: ReminderCategory?
    @Published var selectedCustomTagName: String?

    private let classifier: ReminderClassifier
    private let storage: AppStorage
    private let calendar: Calendar

    init(
        classifier: ReminderClassifier,
        storage: AppStorage,
        calendar: Calendar = .current
    ) {
        self.classifier = classifier
        self.storage = storage
        self.calendar = calendar
        reloadReminders()
        reloadCustomTags()
        refreshPrediction()
    }

    var selectedCategory: ReminderCategory? {
        selectedCategoryOverride ?? prediction.category
    }

    var selectedTagDisplayName: String? {
        selectedCustomTagName ?? selectedCategory?.displayName
    }

    var isUsingManualTag: Bool {
        selectedCategoryOverride != nil || selectedCustomTagName != nil
    }

    var canSubmit: Bool {
        draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && (selectedCategory != nil || selectedCustomTagName != nil)
    }

    var weekDays: [Date] {
        let today = calendar.startOfDay(for: Date())
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else {
            return [today]
        }

        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: weekInterval.start)
        }
    }

    var weekBuckets: [DayBucket] {
        weekDays.map { day in
            DayBucket(
                date: day,
                reminders: scheduledReminders.filter { reminder in
                    guard let targetDate = reminder.targetDate else {
                        return false
                    }
                    return calendar.isDate(targetDate, inSameDayAs: day)
                }
            )
        }
    }

    var miscellaneousReminders: [ReminderItem] {
        reminders
            .filter { $0.targetDate == nil }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private var scheduledReminders: [ReminderItem] {
        reminders
            .filter { $0.targetDate != nil }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func refreshPrediction() {
        prediction = classifier.predict(text: draftText)
        latestSaveMessage = nil
    }

    func selectCategory(_ category: ReminderCategory) {
        selectedCategoryOverride = category
        selectedCustomTagName = nil
    }

    func selectCustomTag(_ tag: String) {
        selectedCustomTagName = tag
        selectedCategoryOverride = nil
    }

    func clearManualTagSelection() {
        selectedCategoryOverride = nil
        selectedCustomTagName = nil
    }

    func addCustomTag(named name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            return
        }

        if customTags.contains(trimmed) == false {
            customTags.append(trimmed)
            customTags.sort { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
            do {
                try storage.saveCustomTags(customTags)
            } catch {
                latestSaveMessage = "Failed to save tag"
                NSLog("Failed to save custom tag: \(error.localizedDescription)")
                return
            }
        }

        selectCustomTag(trimmed)
    }

    func removeCustomTag(_ tag: String) {
        guard customTags.contains(tag) else {
            return
        }

        let updatedTags = customTags.filter { $0 != tag }
        let updatedReminders = reminders.map { reminder in
            var updatedReminder = reminder
            if updatedReminder.customTagName == tag {
                updatedReminder.customTagName = nil
            }
            return updatedReminder
        }

        do {
            try storage.saveCustomTags(updatedTags)
            try storage.saveReminders(updatedReminders)
            customTags = updatedTags
            reminders = updatedReminders
            if selectedCustomTagName == tag {
                selectedCustomTagName = nil
            }
            latestSaveMessage = "Removed tag"
        } catch {
            latestSaveMessage = "Failed to remove tag"
            NSLog("Failed to remove custom tag: \(error.localizedDescription)")
        }
    }

    func submitDraft() {
        let trimmed = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            return
        }

        let finalCategory = selectedCategory ?? .social
        guard selectedCustomTagName != nil || selectedCategory != nil else {
            return
        }

        let targetDate = DateParser.targetDate(from: trimmed, calendar: calendar)
        let reminder = ReminderItem(
            text: trimmed,
            predictedCategory: prediction.category,
            finalCategory: finalCategory,
            customTagName: selectedCustomTagName,
            targetDate: targetDate
        )

        do {
            try storage.appendReminder(reminder)
            classifier.learn(from: reminder)
            try storage.saveTrainingStore(classifier.currentTrainingStore)
            reminders.insert(reminder, at: 0)
            draftText = ""
            clearManualTagSelection()
            latestSaveMessage = targetDate == nil ? "Saved to Miscellaneous" : "Scheduled"
        } catch {
            latestSaveMessage = "Failed to save"
            NSLog("Failed to save planner reminder: \(error.localizedDescription)")
        }
    }

    func beginEditing(_ reminder: ReminderItem) {
        editingReminder = reminder
    }

    func updateReminder(_ reminder: ReminderItem) {
        persistUpdatedReminder(reminder, statusMessage: "Updated")
    }

    func completeAndRemove(_ reminder: ReminderItem) {
        do {
            try storage.deleteReminder(id: reminder.id)
            reminders.removeAll { $0.id == reminder.id }
            latestSaveMessage = "Completed"
        } catch {
            latestSaveMessage = "Failed to remove"
            NSLog("Failed to remove reminder: \(error.localizedDescription)")
        }
    }

    private func persistUpdatedReminder(_ reminder: ReminderItem, statusMessage: String) {
        do {
            try storage.updateReminder(reminder)
            if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
                reminders[index] = reminder
            }
            latestSaveMessage = statusMessage
        } catch {
            latestSaveMessage = "Failed to update"
            NSLog("Failed to update reminder: \(error.localizedDescription)")
        }
    }

    func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    func reloadReminders() {
        do {
            reminders = try storage.loadReminders()
        } catch {
            reminders = []
            NSLog("Failed to load reminders: \(error.localizedDescription)")
        }
    }

    func reloadCustomTags() {
        do {
            customTags = try storage.loadCustomTags()
        } catch {
            customTags = []
            NSLog("Failed to load custom tags: \(error.localizedDescription)")
        }
    }
}
