import Foundation

@MainActor
final class ReminderDraftViewModel: ObservableObject {
    @Published var draftText: String = "" {
        didSet { refreshPrediction() }
    }
    @Published var categoryOverride: ReminderCategory?
    @Published private(set) var prediction: ClassificationResult = .empty
    @Published private(set) var latestSaveMessage: String?

    private let classifier: ReminderClassifier
    private let storage: AppStorage

    init(classifier: ReminderClassifier, storage: AppStorage) {
        self.classifier = classifier
        self.storage = storage
        refreshPrediction()
    }

    var selectedCategory: ReminderCategory? {
        categoryOverride ?? prediction.category
    }

    var canSave: Bool {
        draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && selectedCategory != nil
    }

    var confidenceLabel: String {
        selectedCategory == nil ? "Needs more signal" : prediction.confidence.label
    }

    func refreshPrediction() {
        prediction = classifier.predict(text: draftText)
        latestSaveMessage = nil
    }

    func saveReminder() {
        let trimmed = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false, let finalCategory = selectedCategory else {
            return
        }

        let reminder = ReminderItem(
            text: trimmed,
            predictedCategory: prediction.category,
            finalCategory: finalCategory
        )

        do {
            try storage.appendReminder(reminder)
            classifier.learn(from: reminder)
            try storage.saveTrainingStore(classifier.currentTrainingStore)
            draftText = ""
            categoryOverride = nil
            latestSaveMessage = "Saved to \(finalCategory.displayName)"
        } catch {
            latestSaveMessage = "Failed to save reminder"
            NSLog("Failed to save reminder: \(error.localizedDescription)")
        }
    }
}
