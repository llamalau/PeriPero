import SwiftUI

struct MetricRow: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    let trend: String? // "up", "down", "stable", or nil

    init(title: String, value: String, unit: String = "", color: Color = ColorPalette.primary, trend: String? = nil) {
        self.title = title
        self.value = value
        self.unit = unit
        self.color = color
        self.trend = trend
    }

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)

            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            HStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                if let trend = trend {
                    Image(systemName: trendIcon(trend))
                        .font(.caption)
                        .foregroundColor(trendColor(trend))
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func trendIcon(_ trend: String) -> String {
        switch trend {
        case "up": return "arrow.up.right"
        case "down": return "arrow.down.right"
        default: return "arrow.right"
        }
    }

    private func trendColor(_ trend: String) -> Color {
        switch trend {
        case "up": return .red
        case "down": return .green
        default: return .gray
        }
    }
}
