import SwiftUI

struct CategoryBadgeView: View {
    let category: ReminderCategory?
    var customTagName: String?
    let confidenceLabel: String

    private var backgroundStyle: AnyShapeStyle {
        AnyShapeStyle(customTagName == nil ? (category?.accentColor ?? .gray) : .indigo)
    }

    private var title: String {
        customTagName ?? category?.displayName ?? "No strong category yet"
    }

    private var symbolName: String {
        customTagName == nil ? (category?.symbolName ?? "questionmark.circle") : "tag.fill"
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: symbolName)
                .imageScale(.small)

            Text(title)
                .fontWeight(.semibold)

            Text(confidenceLabel)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(.white.opacity(0.18), in: Capsule())
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(backgroundStyle)
        )
    }
}
