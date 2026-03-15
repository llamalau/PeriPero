import SwiftUI
import Charts

struct SymptomDetailView: View {
    let title: String
    let data: [HealthDataPoint]
    let color: Color
    let unit: String

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                summaryCard
                fullChart
                dataTable
            }
            .padding()
        }
        .background(ColorPalette.background)
        .navigationTitle(title)
    }

    private var summaryCard: some View {
        let values = data.map(\.value)
        let avg = values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
        let min = values.min() ?? 0
        let max = values.max() ?? 0

        return VStack(spacing: 12) {
            HStack {
                statBox(label: "Average", value: String(format: "%.1f", avg), unit: unit)
                Spacer()
                statBox(label: "Min", value: String(format: "%.1f", min), unit: unit)
                Spacer()
                statBox(label: "Max", value: String(format: "%.1f", max), unit: unit)
                Spacer()
                statBox(label: "Points", value: "\(data.count)", unit: "")
            }
        }
        .padding()
        .background(ColorPalette.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))

    }

    private func statBox(label: String, value: String, unit: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(AppFonts.caption())
                .foregroundColor(ColorPalette.textSecondary)
            HStack(spacing: 2) {
                Text(value)
                    .font(AppFonts.bodyBold(size: 18))
                if !unit.isEmpty {
                    Text(unit)
                        .font(AppFonts.caption())
                        .foregroundColor(ColorPalette.textSecondary)
                }
            }
        }
    }

    private var fullChart: some View {
        Chart(data) { point in
            LineMark(
                x: .value("Date", point.date),
                y: .value(title, point.value)
            )
            .foregroundStyle(color)
            .lineStyle(StrokeStyle(lineWidth: 2))

            AreaMark(
                x: .value("Date", point.date),
                y: .value(title, point.value)
            )
            .foregroundStyle(color.opacity(0.1))
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
        .frame(height: 200)
        .padding()
        .background(ColorPalette.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))

    }

    private var dataTable: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily Values")
                .font(AppFonts.title3)

            ForEach(data.suffix(30).reversed()) { point in
                HStack {
                    Text(point.date.mediumFormatted)
                        .font(AppFonts.subheadline)
                        .foregroundColor(ColorPalette.textSecondary)
                    Spacer()
                    Text("\(String(format: "%.1f", point.value)) \(unit)")
                        .font(AppFonts.bodyBold(size: 14))
                }
                .padding(.vertical, 2)
                Divider()
            }
        }
        .padding()
        .background(ColorPalette.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))

    }
}
