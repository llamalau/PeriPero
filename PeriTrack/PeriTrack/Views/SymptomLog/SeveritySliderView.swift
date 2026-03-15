import SwiftUI

struct SeveritySliderView: View {
    @Binding var severity: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Severity")
                    .font(AppFonts.bodyBold(size: 14))
                Spacer()
                Text(severityLabel)
                    .font(AppFonts.bodyBold(size: 14))
                    .foregroundColor(ColorPalette.severityColor(for: severity))
            }

            Slider(value: $severity, in: 0...1, step: 0.1) {
                Text("Severity")
            }
            .tint(ColorPalette.severityColor(for: severity))

            HStack {
                Text("Mild")
                    .font(AppFonts.caption(size: 11))
                    .foregroundColor(ColorPalette.textSecondary)
                Spacer()
                Text("Severe")
                    .font(AppFonts.caption(size: 11))
                    .foregroundColor(ColorPalette.textSecondary)
            }
        }
    }

    private var severityLabel: String {
        let value = Int(severity * 10)
        switch value {
        case 0...2: return "\(value)/10 — Mild"
        case 3...5: return "\(value)/10 — Moderate"
        case 6...8: return "\(value)/10 — Significant"
        case 9...10: return "\(value)/10 — Severe"
        default: return "\(value)/10"
        }
    }
}
