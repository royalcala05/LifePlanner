import Foundation

@MainActor
final class AppCoordinator {
    let storage: AppStorage
    let classifier: ReminderClassifier
    let reminderDraftViewModel: ReminderDraftViewModel
    let plannerViewModel: PlannerViewModel

    private let menuBarController: MenuBarController
    private let notificationScheduler: NotificationScheduler
    private let dailyEmailSummaryScheduler: DailyEmailSummaryScheduler

    init(
        storage: AppStorage? = nil,
        classifier: ReminderClassifier? = nil
    ) {
        let resolvedStorage = storage ?? JSONFileStore()
        self.storage = resolvedStorage

        let initialTrainingStore: TrainingStore
        do {
            initialTrainingStore = try resolvedStorage.loadTrainingStore()
        } catch {
            initialTrainingStore = TrainingStore()
        }

        let resolvedClassifier = classifier ?? ReminderClassifier(trainingStore: initialTrainingStore)
        resolvedClassifier.seedIfNeeded()

        do {
            try resolvedStorage.saveTrainingStore(resolvedClassifier.currentTrainingStore)
        } catch {
            NSLog("Failed to persist seeded training data: \(error.localizedDescription)")
        }

        self.classifier = resolvedClassifier
        self.reminderDraftViewModel = ReminderDraftViewModel(
            classifier: resolvedClassifier,
            storage: resolvedStorage
        )
        self.plannerViewModel = PlannerViewModel(
            classifier: resolvedClassifier,
            storage: resolvedStorage
        )
        self.menuBarController = MenuBarController(viewModel: plannerViewModel)
        self.notificationScheduler = NotificationScheduler()
        self.notificationScheduler.startCalendarCheckNotifications()
        self.dailyEmailSummaryScheduler = DailyEmailSummaryScheduler(
            storage: resolvedStorage,
            recipientEmail: "roycs21100@gmail.com"
        )
        self.dailyEmailSummaryScheduler.start()
    }

    var debugStatusDescription: String {
        menuBarController.debugStatusDescription
    }
}
