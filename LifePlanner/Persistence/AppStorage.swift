import Foundation

protocol AppStorage {
    func loadReminders() throws -> [ReminderItem]
    func appendReminder(_ reminder: ReminderItem) throws
    func loadTrainingStore() throws -> TrainingStore
    func saveTrainingStore(_ store: TrainingStore) throws
}
