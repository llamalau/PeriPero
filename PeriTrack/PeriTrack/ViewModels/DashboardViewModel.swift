import Foundation
import SwiftData

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var startDate: Date = Date().daysAgo(Constants.defaultDateRangeDays)
    @Published var endDate: Date = Date()
    @Published var isLoading = false
    @Published var correlations: [CorrelationResult] = []
    @Published var insightCards: [ClaudeInsightService.InsightCard] = []
    @Published var cycleLengths: [Int] = []
    @Published var errorMessage: String?

    private let healthKitManager = HealthKitManager.shared

    var allHealthData: [(label: String, data: [HealthDataPoint])] {
        [
            ("Menstrual Flow", healthKitManager.menstrualFlowData),
            ("Sleep Duration", healthKitManager.sleepData),
            ("Heart Rate", healthKitManager.heartRateData),
            ("HRV", healthKitManager.hrvData),
            ("Basal Body Temp", healthKitManager.basalTempData),
            ("Steps", healthKitManager.stepCountData),
            ("Body Mass", healthKitManager.bodyMassData),
        ].filter { !$0.data.isEmpty }
    }

    var hasAnyData: Bool {
        !healthKitManager.menstrualFlowData.isEmpty ||
        !healthKitManager.sleepData.isEmpty ||
        !healthKitManager.heartRateData.isEmpty ||
        !healthKitManager.hrvData.isEmpty ||
        !healthKitManager.basalTempData.isEmpty ||
        !healthKitManager.stepCountData.isEmpty ||
        !healthKitManager.bodyMassData.isEmpty
    }

    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            try await healthKitManager.requestAuthorization()
        } catch {
            errorMessage = "Could not request HealthKit authorization."
        }

        await healthKitManager.fetchAllData(from: startDate, to: endDate)

        // Detect cycles
        let cycles = healthKitManager.detectCycles(from: healthKitManager.menstrualFlowData)
        cycleLengths = cycles.map(\.length)

        // Run correlations
        let streams = allHealthData
        correlations = CorrelationEngine.computeAllCorrelations(streams: streams)

        // Generate insights
        await generateInsights()

        isLoading = false
    }

    func updateDateRange(start: Date, end: Date) {
        startDate = start
        endDate = end
        Task { await loadData() }
    }

    private func generateInsights() async {
        // Try Claude API first, fall back to templates
        do {
            let symptomSummary: [(type: String, avgSeverity: Double, count: Int)] = [] // populated from SwiftData in view
            let response = try await ClaudeInsightService.shared.generateInsights(
                correlations: correlations,
                cycleLengths: cycleLengths,
                symptomSummary: symptomSummary,
                dateRange: "\(startDate.mediumFormatted) – \(endDate.mediumFormatted)"
            )
            insightCards = response.dashboardCards
        } catch {
            // Fallback to template-based insights
            let fallback = ClaudeInsightService.templateInsights(
                correlations: correlations,
                cycleLengths: cycleLengths
            )
            insightCards = fallback.dashboardCards
        }
    }

    func generateInsightsWithSymptoms(_ symptomSummary: [(type: String, avgSeverity: Double, count: Int)]) async {
        do {
            let response = try await ClaudeInsightService.shared.generateInsights(
                correlations: correlations,
                cycleLengths: cycleLengths,
                symptomSummary: symptomSummary,
                dateRange: "\(startDate.mediumFormatted) – \(endDate.mediumFormatted)"
            )
            insightCards = response.dashboardCards
        } catch {
            let fallback = ClaudeInsightService.templateInsights(
                correlations: correlations,
                cycleLengths: cycleLengths
            )
            insightCards = fallback.dashboardCards
        }
    }
}
