import Foundation

final class ReminderClassifier {
    private let model: WeightedKeywordModel

    init(trainingStore: TrainingStore = TrainingStore()) {
        self.model = WeightedKeywordModel(trainingStore: trainingStore)
    }

    var currentTrainingStore: TrainingStore {
        model.trainingStore
    }

    func predict(text: String) -> ClassificationResult {
        model.predict(text: text)
    }

    func learn(from reminder: ReminderItem) {
        model.learn(from: reminder)
    }

    func seedIfNeeded() {
        model.seedIfNeeded()
    }
}
