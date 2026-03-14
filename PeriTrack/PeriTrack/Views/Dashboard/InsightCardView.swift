import SwiftUI

struct InsightCardView: View {
    let card: ClaudeInsightService.InsightCard

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconForCategory(card.category))
                    .foregroundColor(ColorPalette.primary)
                    .font(.system(size: 16, weight: .semibold))
                Text(card.title)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(card.category)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(ColorPalette.primary.opacity(0.1))
                    .foregroundColor(ColorPalette.primary)
                    .clipShape(Capsule())
            }

            Text(card.body)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(4)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: ColorPalette.cardShadow, radius: 4, y: 2)
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
