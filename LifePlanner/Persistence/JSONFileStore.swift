import Foundation

final class JSONFileStore: AppStorage {
    private let paths: StoragePaths
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(paths: StoragePaths = .default) {
        self.paths = paths
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func loadReminders() throws -> [ReminderItem] {
        try ensureBaseDirectory()
        guard FileManager.default.fileExists(atPath: paths.remindersURL.path) else {
            return []
        }
        let data = try Data(contentsOf: paths.remindersURL)
        return try decoder.decode([ReminderItem].self, from: data)
    }

    func appendReminder(_ reminder: ReminderItem) throws {
        var reminders = try loadReminders()
        reminders.insert(reminder, at: 0)
        try ensureBaseDirectory()
        let data = try encoder.encode(reminders)
        try data.write(to: paths.remindersURL, options: .atomic)
    }

    func loadTrainingStore() throws -> TrainingStore {
        try ensureBaseDirectory()
        guard FileManager.default.fileExists(atPath: paths.trainingDataURL.path) else {
            return TrainingStore()
        }
        let data = try Data(contentsOf: paths.trainingDataURL)
        return try decoder.decode(TrainingStore.self, from: data)
    }

    func saveTrainingStore(_ store: TrainingStore) throws {
        try ensureBaseDirectory()
        let data = try encoder.encode(store)
        try data.write(to: paths.trainingDataURL, options: .atomic)
    }

    private func ensureBaseDirectory() throws {
        try FileManager.default.createDirectory(at: paths.baseDirectory, withIntermediateDirectories: true)
    }
}
