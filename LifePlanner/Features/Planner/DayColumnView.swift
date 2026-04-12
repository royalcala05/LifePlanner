import SwiftUI

struct DayColumnView: View {
    let date: Date
    let reminders: [ReminderItem]
    let isToday: Bool
    let onEdit: (ReminderItem) -> Void
    let onComplete: (ReminderItem) -> Void

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()

    var body: some View {
        VStack(spacing: 14) {
            VStack(spacing: 4) {
                Text(Self.dayFormatter.string(from: date).uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(isToday ? .white : .secondary)

                Text(Self.dateFormatter.string(from: date))
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(isToday ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isToday ? Color.orange.gradient : Color.white.opacity(0.08).gradient, in: RoundedRectangle(cornerRadius: 20, style: .continuous))

            ScrollView {
                VStack(spacing: 12) {
                    if reminders.isEmpty {
                        Text("No plans")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 24)
                    } else {
                        ForEach(reminders) { reminder in
                            ReminderCardView(
                                reminder: reminder,
                                onEdit: onEdit,
                                onComplete: onComplete
                            )
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(10)
        .frame(minWidth: 120, maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(isToday ? Color.orange.opacity(0.65) : Color.white.opacity(0.12), lineWidth: 1)
        }
    }
}
