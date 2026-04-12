import SwiftUI

struct ReminderEditorView: View {
    @State private var text: String
    @State private var category: ReminderCategory
    @State private var customTagName: String
    @State private var hasDate: Bool
    @State private var targetDate: Date
    @State private var isCompleted: Bool

    let reminder: ReminderItem
    let onSave: (ReminderItem) -> Void
    let onCancel: () -> Void

    init(
        reminder: ReminderItem,
        onSave: @escaping (ReminderItem) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.reminder = reminder
        self.onSave = onSave
        self.onCancel = onCancel
        _text = State(initialValue: reminder.text)
        _category = State(initialValue: reminder.finalCategory)
        _customTagName = State(initialValue: reminder.customTagName ?? "")
        _hasDate = State(initialValue: reminder.targetDate != nil)
        _targetDate = State(initialValue: reminder.targetDate ?? Date())
        _isCompleted = State(initialValue: reminder.isCompleted)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Edit Reminder")
                .font(.system(size: 24, weight: .bold, design: .rounded))

            TextField("Reminder", text: $text, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3, reservesSpace: true)

            Picker("Category", selection: $category) {
                ForEach(ReminderCategory.allCases) { category in
                    Label(category.displayName, systemImage: category.symbolName)
                        .tag(category)
                }
            }

            TextField("Custom tag override", text: $customTagName)
                .textFieldStyle(.roundedBorder)

            Toggle("Scheduled", isOn: $hasDate)

            if hasDate {
                DatePicker("Date", selection: $targetDate, displayedComponents: .date)
            }

            Toggle("Completed", isOn: $isCompleted)

            HStack {
                Button("Cancel") {
                    onCancel()
                }

                Spacer()

                Button("Save Changes") {
                    var updatedReminder = reminder
                    updatedReminder.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    updatedReminder.finalCategory = category
                    let trimmedCustomTag = customTagName.trimmingCharacters(in: .whitespacesAndNewlines)
                    updatedReminder.customTagName = trimmedCustomTag.isEmpty ? nil : trimmedCustomTag
                    updatedReminder.targetDate = hasDate ? targetDate : nil
                    updatedReminder.isCompleted = isCompleted
                    onSave(updatedReminder)
                }
                .buttonStyle(.borderedProminent)
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(22)
        .frame(width: 420)
        .background(.regularMaterial)
    }
}
