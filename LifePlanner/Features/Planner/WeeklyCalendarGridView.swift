import SwiftUI

struct WeeklyCalendarGridView: View {
    @ObservedObject var viewModel: PlannerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("This Week")
                        .font(.system(size: 32, weight: .bold, design: .rounded))

                    Text("Scheduled reminders")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            HStack(alignment: .top, spacing: 12) {
                ForEach(viewModel.weekBuckets) { bucket in
                    DayColumnView(
                        date: bucket.date,
                        reminders: bucket.reminders,
                        isToday: viewModel.isToday(bucket.date),
                        onEdit: { reminder in
                            viewModel.beginEditing(reminder)
                        },
                        onComplete: { reminder in
                            viewModel.completeAndRemove(reminder)
                        }
                    )
                }
            }
            .frame(maxHeight: .infinity)
        }
        .padding(22)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        }
    }
}
