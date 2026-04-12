import SwiftUI

struct ReminderCardView: View {
    let reminder: ReminderItem
    let onEdit: (ReminderItem) -> Void
    let onComplete: (ReminderItem) -> Void

    private var tagName: String {
        reminder.customTagName ?? reminder.finalCategory.displayName
    }

    private var tagSymbolName: String {
        reminder.customTagName == nil ? reminder.finalCategory.symbolName : "tag.fill"
    }

    private var tagColor: Color {
        reminder.customTagName == nil ? reminder.finalCategory.accentColor : .indigo
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: tagSymbolName)
                        .imageScale(.small)

                    Text(tagName)
                        .font(.caption)
                        .fontWeight(.bold)
                        .lineLimit(1)
                }
                .foregroundStyle(tagColor)

                Spacer(minLength: 8)

                Button {
                    onComplete(reminder)
                } label: {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 17, weight: .semibold))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .help("Complete and remove")
            }

            Text(reminder.text)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .fontWeight(.semibold)
                .lineLimit(6)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Click to edit")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tagColor.opacity(0.14), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(tagColor.opacity(0.25), lineWidth: 1)
        }
        .shadow(color: tagColor.opacity(0.08), radius: 8, x: 0, y: 4)
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .onTapGesture {
            onEdit(reminder)
        }
        .contextMenu {
            Button("Complete and Remove") {
                onComplete(reminder)
            }

            Button("Edit") {
                onEdit(reminder)
            }
        }
    }
}
