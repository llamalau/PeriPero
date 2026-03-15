import SwiftUI

struct InsightCardView: View {
    let card: ClaudeInsightService.InsightCard

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconForCategory(card.category))
                    .foregroundColor(ColorPalette.coral)
                    .font(.system(size: 16, weight: .semibold))
                Text(card.title)
                    .font(AppFonts.bodyBold(size: 15))
                Spacer()
                Text(card.category)
                    .font(AppFonts.caption(size: 11))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(ColorPalette.highlight.opacity(0.3))
                    .foregroundColor(ColorPalette.textPrimary)
                    .clipShape(Capsule())
            }

            Text(card.body)
                .font(AppFonts.subheadline)
                .foregroundColor(ColorPalette.textSecondary)
                .lineLimit(4)
        }
        .padding()
        .background(ColorPalette.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))

    }

    private func iconForCategory(_ category: String) -> String {
        switch category.lowercased() {
        case "cycles", "cycle": return "calendar.circle"
        case "correlation": return "link"
        case "sleep": return "moon.zzz"
        case "heart", "cardiovascular": return "heart.circle"
        case "symptoms": return "list.bullet.clipboard"
        default: return "lightbulb"
        }
    }
}
