import Foundation

protocol AppStorage {
    func loadReminders() throws -> [ReminderItem]
    func saveReminders(_ reminders: [ReminderItem]) throws
    func appendReminder(_ reminder: ReminderItem) throws
    func updateReminder(_ reminder: ReminderItem) throws
    func deleteReminder(id: UUID) throws
    func loadCustomTags() throws -> [String]
    func saveCustomTags(_ tags: [String]) throws
    func loadTrainingStore() throws -> TrainingStore
    func saveTrainingStore(_ store: TrainingStore) throws
}
