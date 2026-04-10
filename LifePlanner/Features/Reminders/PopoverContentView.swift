import SwiftUI

struct PopoverContentView: View {
    @ObservedObject var viewModel: ReminderDraftViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("LifePlanner")
                .font(.system(size: 18, weight: .semibold))

            Text("Capture a reminder and let the app categorize it as you type.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField("Dinner with girlfriend at 7", text: $viewModel.draftText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3, reservesSpace: true)

            VStack(alignment: .leading, spacing: 8) {
                Text("Smart Categorized")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                CategoryBadgeView(
                    category: viewModel.selectedCategory,
                    confidenceLabel: viewModel.confidenceLabel
                )

                if viewModel.prediction.matchedKeywords.isEmpty == false {
                    Text("Signals: \(viewModel.prediction.matchedKeywords.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Picker("Override", selection: $viewModel.categoryOverride) {
                Text("Use prediction").tag(ReminderCategory?.none)
                ForEach(ReminderCategory.allCases) { category in
                    Text(category.displayName).tag(Optional(category))
                }
            }
            .pickerStyle(.menu)

            HStack {
                if let latestSaveMessage = viewModel.latestSaveMessage {
                    Text(latestSaveMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button("Save Reminder") {
                    viewModel.saveReminder()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(viewModel.canSave == false)
            }
        }
        .padding(16)
        .frame(width: 360)
    }
}
