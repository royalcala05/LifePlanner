import SwiftUI

struct MiscellaneousSidebarView: View {
    @ObservedObject var viewModel: PlannerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Miscellaneous")
                    .font(.system(size: 26, weight: .bold, design: .rounded))

                Text("Unscheduled backlog")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            ScrollView {
                VStack(spacing: 14) {
                    if viewModel.miscellaneousReminders.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "tray")
                                .font(.system(size: 28))
                                .foregroundStyle(.tertiary)

                            Text("No unscheduled reminders")
                                .font(.callout)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 80)
                    } else {
                        ForEach(viewModel.miscellaneousReminders) { reminder in
                            ReminderCardView(
                                reminder: reminder,
                                onEdit: { reminder in
                                    viewModel.beginEditing(reminder)
                                },
                                onComplete: { reminder in
                                    viewModel.completeAndRemove(reminder)
                                }
                            )
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(22)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        }
    }
}
