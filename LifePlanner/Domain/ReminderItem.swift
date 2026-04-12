import Foundation

struct ReminderItem: Codable, Equatable, Identifiable {
    let id: UUID
    var text: String
    var predictedCategory: ReminderCategory?
    var finalCategory: ReminderCategory
    var customTagName: String?
    let createdAt: Date
    var targetDate: Date?
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        text: String,
        predictedCategory: ReminderCategory?,
        finalCategory: ReminderCategory,
        customTagName: String? = nil,
        createdAt: Date = Date(),
        targetDate: Date? = nil,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.text = text
        self.predictedCategory = predictedCategory
        self.finalCategory = finalCategory
        self.customTagName = customTagName
        self.createdAt = createdAt
        self.targetDate = targetDate
        self.isCompleted = isCompleted
    }

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case predictedCategory
        case finalCategory
        case customTagName
        case createdAt
        case targetDate
        case isCompleted
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        predictedCategory = try container.decodeIfPresent(ReminderCategory.self, forKey: .predictedCategory)
        finalCategory = try container.decode(ReminderCategory.self, forKey: .finalCategory)
        customTagName = try container.decodeIfPresent(String.self, forKey: .customTagName)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        targetDate = try container.decodeIfPresent(Date.self, forKey: .targetDate)
        isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
    }
}
