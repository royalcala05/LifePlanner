import SwiftUI

struct CategoryBadgeView: View {
    let category: ReminderCategory?
    let confidenceLabel: String

    private var backgroundStyle: AnyShapeStyle {
        AnyShapeStyle(category?.accentColor ?? .gray)
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: category?.symbolName ?? "questionmark.circle")
                .imageScale(.small)

            Text(category?.displayName ?? "No strong category yet")
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
