import Foundation

enum ConfidenceLevel: String, Codable {
    case low
    case medium
    case high

    var label: String {
        rawValue.capitalized
    }
}

struct ClassificationResult: Equatable {
    struct RankedCategoryScore: Equatable {
        let category: ReminderCategory
        let score: Double
    }

    let category: ReminderCategory?
    let confidence: ConfidenceLevel
    let rawConfidence: Double
    let rankedScores: [RankedCategoryScore]
    let matchedKeywords: [String]

    static let empty = ClassificationResult(
        category: nil,
        confidence: .low,
        rawConfidence: 0,
        rankedScores: [],
        matchedKeywords: []
    )

    var summaryText: String {
        guard let category else {
            return "No strong category yet"
        }
        return "\(category.displayName) • \(confidence.label)"
    }
}
