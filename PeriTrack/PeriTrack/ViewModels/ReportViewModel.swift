import Foundation
import SwiftData

@MainActor
final class ReportViewModel: ObservableObject {
    @Published var isGenerating = false
    @Published var pdfData: Data?
    @Published var patientName: String = ""
    @Published var errorMessage: String?

    func generateReport(
        correlations: [CorrelationResult],
        cycleLengths: [Int],
        symptomEntries: [SymptomEntry],
        intermenstrualBleedingCount: Int,
        dateRange: String
    ) async {
        isGenerating = true
        errorMessage = nil

        // Build symptom summary
        let grouped = Dictionary(grouping: symptomEntries) { $0.type }
        let symptomFrequencies = grouped.map { type, entries -> (type: String, count: Int, avgSeverity: Double) in
            let avg = entries.map(\.severity).reduce(0, +) / Double(entries.count)
            return (type: type, count: entries.count, avgSeverity: avg)
        }.sorted { $0.count > $1.count }

        let symptomSummaryForClaude = symptomFrequencies.map {
            (type: $0.type, avgSeverity: $0.avgSeverity, count: $0.count)
        }

        // Get narrative from Claude (or fallback)
        var narrative = ""
        var insights: [String] = []

        do {
            let response = try await ClaudeInsightService.shared.generateInsights(
                correlations: correlations,
                cycleLengths: cycleLengths,
                symptomSummary: symptomSummaryForClaude,
                dateRange: dateRange
            )
            narrative = response.reportNarrative
            insights = response.dashboardCards.map(\.body)
        } catch {
            let fallback = ClaudeInsightService.templateInsights(
                correlations: correlations,
                cycleLengths: cycleLengths
            )
            narrative = fallback.reportNarrative
            insights = fallback.dashboardCards.map(\.body)
        }

        // Build cycle summary
        var cycleSummary: ReportGenerator.CycleSummary?
        if !cycleLengths.isEmpty {
            let avg = Double(cycleLengths.reduce(0, +)) / Double(cycleLengths.count)
            let variability = cycleLengths.map { abs(Double($0) - avg) }.reduce(0, +) / Double(cycleLengths.count)

            let trend: String
            if cycleLengths.count >= 3 {
                let firstHalf = Array(cycleLengths.prefix(cycleLengths.count / 2))
                let secondHalf = Array(cycleLengths.suffix(cycleLengths.count / 2))
                let firstAvg = Double(firstHalf.reduce(0, +)) / Double(firstHalf.count)
                let secondAvg = Double(secondHalf.reduce(0, +)) / Double(secondHalf.count)
                if secondAvg - firstAvg > 3 { trend = "Lengthening" }
                else if firstAvg - secondAvg > 3 { trend = "Shortening" }
                else { trend = "Stable" }
            } else {
                trend = "Insufficient data for trend"
            }

            cycleSummary = ReportGenerator.CycleSummary(
                averageLength: avg,
                variability: variability,
                cycleCount: cycleLengths.count,
                trend: trend
            )
        }

        let reportData = ReportGenerator.ReportData(
            patientName: patientName.isEmpty ? nil : patientName,
            dateRange: dateRange,
            cycleSummary: cycleSummary,
            insights: insights,
            narrative: narrative,
            symptomFrequencies: symptomFrequencies,
            intermenstrualBleedingCount: intermenstrualBleedingCount
        )

        pdfData = ReportGenerator.generatePDF(from: reportData)
        isGenerating = false
    }
}
