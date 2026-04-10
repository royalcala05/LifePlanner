import Foundation

struct ReminderItem: Codable, Equatable, Identifiable {
    let id: UUID
    let text: String
    let predictedCategory: ReminderCategory?
    let finalCategory: ReminderCategory
    let createdAt: Date

    init(
        id: UUID = UUID(),
        text: String,
        predictedCategory: ReminderCategory?,
        finalCategory: ReminderCategory,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.text = text
        self.predictedCategory = predictedCategory
        self.finalCategory = finalCategory
        self.createdAt = createdAt
    }
}
