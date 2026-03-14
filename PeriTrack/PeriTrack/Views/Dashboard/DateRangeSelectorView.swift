import SwiftUI

struct DateRangeSelectorView: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    var onRangeChanged: () -> Void

    @State private var selectedPreset: DatePreset = .threeMonths

    enum DatePreset: String, CaseIterable {
        case oneMonth = "1M"
        case threeMonths = "3M"
        case sixMonths = "6M"
        case oneYear = "1Y"

        var days: Int {
            switch self {
            case .oneMonth: return 30
            case .threeMonths: return 90
            case .sixMonths: return 180
            case .oneYear: return 365
            }
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 0) {
                ForEach(DatePreset.allCases, id: \.self) { preset in
                    Button(action: {
                        selectedPreset = preset
                        endDate = Date()
                        startDate = Date().daysAgo(preset.days)
                        onRangeChanged()
                    }) {
                        Text(preset.rawValue)
                            .font(.system(size: 14, weight: selectedPreset == preset ? .bold : .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(selectedPreset == preset ? ColorPalette.primary : Color.clear)
                            .foregroundColor(selectedPreset == preset ? .white : .secondary)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(ColorPalette.primary.opacity(0.3), lineWidth: 1))

            HStack {
                Text(startDate.shortFormatted)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("to")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(endDate.shortFormatted)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
