import SwiftUI
import SwiftData

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @ObservedObject var healthKitManager = HealthKitManager.shared
    @Query(sort: \SymptomEntry.timestamp, order: .reverse) private var symptomEntries: [SymptomEntry]

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 16) {
                        // Date range selector
                        DateRangeSelectorView(
                            startDate: $viewModel.startDate,
                            endDate: $viewModel.endDate
                        ) {
                            Task { await viewModel.loadData() }
                        }
                        .padding(.horizontal)

                        if viewModel.hasAnyData {
                            // Quick metrics
                            quickMetricsCard

                            // Timeline charts
                            timelineSection

                            // AI Insight cards
                            if !viewModel.insightCards.isEmpty {
                                insightsSection
                            }

                            // Recent symptoms
                            if !symptomEntries.isEmpty {
                                recentSymptomsSection
                            }
                        } else {
                            emptyStateView
                        }
                    }
                    .padding(.bottom, 20)
                }
                .background(ColorPalette.background)

                if viewModel.isLoading {
                    LoadingOverlay(message: "Loading health data...")
                }
            }
            .navigationTitle("PeriPero")
            .task {
                await viewModel.loadData()
            }
            .refreshable {
                await viewModel.loadData()
            }
        }
    }

    private var quickMetricsCard: some View {
        VStack(spacing: 8) {
            if !healthKitManager.sleepData.isEmpty {
                let avgSleep = healthKitManager.sleepData.map(\.value).reduce(0, +) / Double(healthKitManager.sleepData.count)
                MetricRow(title: "Avg Sleep", value: String(format: "%.1f", avgSleep), unit: "hrs", color: ColorPalette.sleep)
            }
            if !healthKitManager.heartRateData.isEmpty {
                let avgHR = healthKitManager.heartRateData.map(\.value).reduce(0, +) / Double(healthKitManager.heartRateData.count)
                MetricRow(title: "Avg Heart Rate", value: String(format: "%.0f", avgHR), unit: "bpm", color: ColorPalette.heartRate)
            }
            if !healthKitManager.hrvData.isEmpty {
                let avgHRV = healthKitManager.hrvData.map(\.value).reduce(0, +) / Double(healthKitManager.hrvData.count)
                MetricRow(title: "Avg HRV", value: String(format: "%.0f", avgHRV), unit: "ms", color: ColorPalette.hrv)
            }
            if !healthKitManager.stepCountData.isEmpty {
                let avgSteps = healthKitManager.stepCountData.map(\.value).reduce(0, +) / Double(healthKitManager.stepCountData.count)
                MetricRow(title: "Avg Steps", value: String(format: "%.0f", avgSteps), color: ColorPalette.steps)
            }
            if !viewModel.cycleLengths.isEmpty {
                let avgCycle = Double(viewModel.cycleLengths.reduce(0, +)) / Double(viewModel.cycleLengths.count)
                MetricRow(title: "Avg Cycle", value: String(format: "%.0f", avgCycle), unit: "days", color: ColorPalette.menstrualFlow)
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: ColorPalette.cardShadow, radius: 4, y: 2)
        .padding(.horizontal)
    }

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Timeline")
                .font(.headline)
                .padding(.horizontal)

            let streams: [(label: String, data: [HealthDataPoint], color: Color)] = [
                ("Menstrual Flow", healthKitManager.menstrualFlowData, ColorPalette.menstrualFlow),
                ("Sleep", healthKitManager.sleepData, ColorPalette.sleep),
                ("Heart Rate", healthKitManager.heartRateData, ColorPalette.heartRate),
                ("HRV", healthKitManager.hrvData, ColorPalette.hrv),
                ("Body Temp", healthKitManager.basalTempData, ColorPalette.temperature),
                ("Hot Flashes", healthKitManager.hotFlashData, ColorPalette.hotFlashes),
                ("Steps", healthKitManager.stepCountData, ColorPalette.steps),
                ("Weight", healthKitManager.bodyMassData, ColorPalette.weight),
            ].filter { !$0.data.isEmpty }

            TimelineChartView(
                dataStreams: streams,
                startDate: viewModel.startDate,
                endDate: viewModel.endDate
            )
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: ColorPalette.cardShadow, radius: 4, y: 2)
            .padding(.horizontal)
        }
    }

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Insights")
                .font(.headline)
                .padding(.horizontal)

            ForEach(viewModel.insightCards) { card in
                InsightCardView(card: card)
                    .padding(.horizontal)
            }
        }
    }

    private var recentSymptomsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Symptoms")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 6) {
                ForEach(symptomEntries.prefix(5)) { entry in
                    HStack {
                        Image(systemName: entry.symptomType.icon)
                            .foregroundColor(entry.symptomType.color)
                            .frame(width: 24)
                        Text(entry.symptomType.rawValue)
                            .font(.subheadline)
                        Spacer()
                        Text("\(Int(entry.severity * 10))/10")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(ColorPalette.severityColor(for: entry.severity))
                        Text(entry.timestamp.shortFormatted)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 2)
                }
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: ColorPalette.cardShadow, radius: 4, y: 2)
            .padding(.horizontal)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.text.clipboard")
                .font(.system(size: 60))
                .foregroundColor(ColorPalette.primary.opacity(0.4))

            Text("No Health Data Available")
                .font(.title3.weight(.semibold))

            Text("PeriPero needs access to your Apple Health data to detect patterns. Make sure you've granted permission in Settings > Privacy & Security > Health > PeriPero.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Text("You can also start logging symptoms manually using the Log tab below.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.top, 60)
    }
}
