import XCTest
@testable import LifePlanner

final class LifePlannerTests: XCTestCase {
    func testGymPredictionFromSeedKeywords() {
        let classifier = ReminderClassifier()

        classifier.seedIfNeeded()
        let result = classifier.predict(text: "bench press tonight")

        XCTAssertEqual(result.category, .gym)
        XCTAssertEqual(result.confidence, .high)
    }

    func testClassesPredictionFromSeedKeywords() {
        let classifier = ReminderClassifier()

        classifier.seedIfNeeded()
        let result = classifier.predict(text: "calc exam tomorrow")

        XCTAssertEqual(result.category, .classes)
    }

    func testGirlfriendPredictionFromSeedKeywords() {
        let classifier = ReminderClassifier()

        classifier.seedIfNeeded()
        let result = classifier.predict(text: "dinner with girlfriend at 7")

        XCTAssertEqual(result.category, .girlfriend)
    }

    func testEmptyInputReturnsNeutralState() {
        let classifier = ReminderClassifier()

        classifier.seedIfNeeded()
        let result = classifier.predict(text: "   ")

        XCTAssertNil(result.category)
        XCTAssertEqual(result.confidence, .low)
    }

    func testLearningRaisesCategoryScore() {
        let classifier = ReminderClassifier()
        classifier.seedIfNeeded()

        let before = classifier.predict(text: "mobility session")

        classifier.learn(from: ReminderItem(text: "mobility session", predictedCategory: nil, finalCategory: .gym))
        classifier.learn(from: ReminderItem(text: "mobility session", predictedCategory: nil, finalCategory: .gym))

        let after = classifier.predict(text: "mobility session")

        XCTAssertTrue((after.rankedScores.first?.score ?? 0) > (before.rankedScores.first?.score ?? 0))
        XCTAssertEqual(after.category, .gym)
    }

    func testPersistenceRoundTrip() throws {
        let tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        let store = JSONFileStore(paths: StoragePaths(baseDirectory: tempDirectory))

        let reminder = ReminderItem(text: "Pick up eggs", predictedCategory: .groceries, finalCategory: .groceries)
        let trainingStore = TrainingStore(
            version: 1,
            isSeeded: true,
            seedKeywordWeights: ["gym": ["bench": 5]],
            learnedTokenCounts: ["gym": ["mobility": 2]],
            categoryExampleCounts: ["gym": 2]
        )

        try store.appendReminder(reminder)
        try store.saveTrainingStore(trainingStore)

        XCTAssertEqual(try store.loadReminders(), [reminder])
        XCTAssertEqual(try store.loadTrainingStore(), trainingStore)
    }
}
