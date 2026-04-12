import SwiftUI

struct PlannerRootView: View {
    @ObservedObject var viewModel: PlannerViewModel

    var body: some View {
        VStack(spacing: 24) {
            SmartInputBarView(viewModel: viewModel)

            HStack(alignment: .top, spacing: 24) {
                WeeklyCalendarGridView(viewModel: viewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                MiscellaneousSidebarView(viewModel: viewModel)
                    .frame(width: 320)
                    .frame(maxHeight: .infinity)
            }
        }
        .padding(28)
        .frame(width: 1280, height: 780)
        .background {
            ZStack {
                Rectangle()
                    .fill(.windowBackground)

                LinearGradient(
                    colors: [
                        Color.orange.opacity(0.16),
                        Color.blue.opacity(0.10),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .ignoresSafeArea()
        }
        .sheet(item: $viewModel.editingReminder) { reminder in
            ReminderEditorView(
                reminder: reminder,
                onSave: { updatedReminder in
                    if updatedReminder.isCompleted {
                        viewModel.completeAndRemove(updatedReminder)
                    } else {
                        viewModel.updateReminder(updatedReminder)
                    }
                    viewModel.editingReminder = nil
                },
                onCancel: {
                    viewModel.editingReminder = nil
                }
            )
        }
    }
}
