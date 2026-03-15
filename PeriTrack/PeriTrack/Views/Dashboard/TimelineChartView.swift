import SwiftUI
import Charts

struct TimelineChartView: View {
    let dataStreams: [(label: String, data: [HealthDataPoint], color: Color)]
    let startDate: Date
    let endDate: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(dataStreams, id: \.label) { stream in
                if !stream.data.isEmpty {
                    singleTrackChart(label: stream.label, data: stream.data, color: stream.color)
                }
            }
        }
    }

    @ViewBuilder
    private func singleTrackChart(label: String, data: [HealthDataPoint], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                Text(label)
                    .font(.caption.weight(.medium))
                    .foregroundColor(ColorPalette.textSecondary)
                Spacer()
                if let last = data.last {
                    Text("\(String(format: "%.1f", last.value)) \(last.category.unit)")
                        .font(.caption2)
                        .foregroundColor(ColorPalette.textSecondary)
                }
            }

            Chart(data) { point in
                if point.category == .menstrualFlow || point.category == .intermenstrualBleeding || point.category == .hotFlashes {
                    // Event-based: show as marks
                    PointMark(
                        x: .value("Date", point.date),
                        y: .value("Value", point.value)
                    )
                    .foregroundStyle(color)
                    .symbolSize(point.category == .hotFlashes ? 30 : 50)
                } else {
                    // Continuous: show as line + area
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Value", point.value)
                    )
                    .foregroundStyle(color)
                    .lineStyle(StrokeStyle(lineWidth: 1.5))

                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Value", point.value)
                    )
                    .foregroundStyle(color.opacity(0.1))
                }
            }
            .chartXScale(domain: startDate...endDate)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 14)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .frame(height: 80)
        }
        .padding(.vertical, 4)
    }
}
