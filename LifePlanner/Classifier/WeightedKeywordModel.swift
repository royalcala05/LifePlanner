import Foundation

struct SeedTrainingData: Codable {
    let keywordWeights: [String: [String: Double]]
}

final class WeightedKeywordModel {
    private(set) var trainingStore: TrainingStore

    init(trainingStore: TrainingStore) {
        self.trainingStore = trainingStore
    }

    func seedIfNeeded() {
        guard trainingStore.isSeeded == false else {
            return
        }

        trainingStore.seedKeywordWeights = Self.loadSeedKeywordWeights()
        trainingStore.isSeeded = true
    }

    func predict(text: String) -> ClassificationResult {
        let tokens = Tokenizer.tokens(from: text)
        guard tokens.isEmpty == false else {
            return ClassificationResult.empty
        }

        var scores = Dictionary(uniqueKeysWithValues: ReminderCategory.allCases.map { ($0, 0.0) })
        var matchedKeywordsByCategory: [ReminderCategory: [String]] = [:]

        for token in tokens {
            for category in ReminderCategory.allCases {
                let categoryKey = category.rawValue
                if let seededWeight = trainingStore.seedKeywordWeights[categoryKey]?[token] {
                    scores[category, default: 0] += seededWeight
                    matchedKeywordsByCategory[category, default: []].append(token)
                }

                let learnedCount = Double(trainingStore.learnedTokenCounts[categoryKey]?[token] ?? 0)
                let categoryExamples = Double(trainingStore.categoryExampleCounts[categoryKey] ?? 0)
                if learnedCount > 0 {
                    let learnedBoost = 0.75 * log1p(learnedCount) + 0.15 * log1p(categoryExamples)
                    scores[category, default: 0] += learnedBoost
                }
            }
        }

        let ranked = scores
            .map { category, score in
                ClassificationResult.RankedCategoryScore(category: category, score: score)
            }
            .sorted {
                if $0.score == $1.score {
                    return $0.category.displayName < $1.category.displayName
                }
                return $0.score > $1.score
            }

        guard let best = ranked.first, best.score > 0 else {
            return ClassificationResult(
                category: nil,
                confidence: .low,
                rawConfidence: 0,
                rankedScores: ranked,
                matchedKeywords: []
            )
        }

        let runnerUpScore = ranked.dropFirst().first?.score ?? 0
        let spread = max(best.score - runnerUpScore, 0)
        let total = ranked.reduce(0) { $0 + max($1.score, 0) }
        let normalizedConfidence = total > 0 ? min(max(best.score / total, 0), 1) : 0
        let spreadAdjustedConfidence = min(max(normalizedConfidence + (spread / max(best.score, 1)) * 0.15, 0), 1)

        return ClassificationResult(
            category: best.category,
            confidence: ConfidenceLevel(rawValue: spreadAdjustedConfidence),
            rawConfidence: spreadAdjustedConfidence,
            rankedScores: ranked,
            matchedKeywords: matchedKeywordsByCategory[best.category] ?? []
        )
    }

    func learn(from reminder: ReminderItem) {
        let categoryKey = reminder.finalCategory.rawValue
        let tokens = Tokenizer.tokens(from: reminder.text)
        guard tokens.isEmpty == false else {
            return
        }

        trainingStore.categoryExampleCounts[categoryKey, default: 0] += 1

        for token in tokens {
            trainingStore.learnedTokenCounts[categoryKey, default: [:]][token, default: 0] += 1
        }
    }

    private static func loadSeedKeywordWeights() -> [String: [String: Double]] {
        if
            let url = Bundle.main.url(forResource: "SeedTrainingData", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode(SeedTrainingData.self, from: data)
        {
            return decoded.keywordWeights
        }

        return [
            "girlfriend": ["date": 3.5, "dinner": 2.5, "girlfriend": 5.0, "movie": 1.5],
            "classes": ["assignment": 3.0, "class": 3.0, "exam": 5.0, "lecture": 3.5, "meeting": 2.5],
            "social": ["party": 4.0, "hangout": 3.5, "friends": 3.5],
            "shpe": ["shpe": 5.0, "society": 1.5, "conference": 2.5],
            "lul": ["lul": 5.0, "org": 2.0, "leadership": 2.5],
            "groceries": ["costco": 4.0, "groceries": 5.0, "milk": 2.5, "store": 2.0],
            "gym": ["bench": 5.0, "cardio": 3.0, "gym": 5.0, "lifting": 5.0, "workout": 4.0]
        ]
    }
}

private extension ConfidenceLevel {
    init(rawValue: Double) {
        switch rawValue {
        case 0.7...:
            self = .high
        case 0.4..<0.7:
            self = .medium
        default:
            self = .low
        }
    }
}
