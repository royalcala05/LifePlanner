import Foundation

struct TrainingStore: Codable, Equatable {
    var version: Int = 1
    var isSeeded: Bool = false
    var seedKeywordWeights: [String: [String: Double]] = [:]
    var learnedTokenCounts: [String: [String: Int]] = [:]
    var categoryExampleCounts: [String: Int] = [:]
}
