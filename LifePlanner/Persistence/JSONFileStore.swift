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
        try saveReminders(reminders)
    }

    func saveReminders(_ reminders: [ReminderItem]) throws {
        try ensureBaseDirectory()
        let data = try encoder.encode(reminders)
        try data.write(to: paths.remindersURL, options: .atomic)
    }

    func updateReminder(_ reminder: ReminderItem) throws {
        var reminders = try loadReminders()
        guard let index = reminders.firstIndex(where: { $0.id == reminder.id }) else {
            return
        }

        reminders[index] = reminder
        try saveReminders(reminders)
    }

    func deleteReminder(id: UUID) throws {
        let reminders = try loadReminders().filter { $0.id != id }
        try saveReminders(reminders)
    }

    func loadCustomTags() throws -> [String] {
        try ensureBaseDirectory()
        guard FileManager.default.fileExists(atPath: paths.customTagsURL.path) else {
            return []
        }
        let data = try Data(contentsOf: paths.customTagsURL)
        return try decoder.decode([String].self, from: data)
    }

    func saveCustomTags(_ tags: [String]) throws {
        try ensureBaseDirectory()
        let uniqueTags = tags.reduce(into: [String]()) { result, tag in
            let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.isEmpty == false, result.contains(trimmed) == false else {
                return
            }
            result.append(trimmed)
        }
        let data = try encoder.encode(uniqueTags)
        try data.write(to: paths.customTagsURL, options: .atomic)
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
