import Foundation

@MainActor
final class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()

    @Published var isAuthorized = false
    @Published var menstrualFlowData: [HealthDataPoint] = []
    @Published var intermenstrualBleedingData: [HealthDataPoint] = []
    @Published var sleepData: [HealthDataPoint] = []
    @Published var heartRateData: [HealthDataPoint] = []
    @Published var hrvData: [HealthDataPoint] = []
    @Published var basalTempData: [HealthDataPoint] = []
    @Published var hotFlashData: [HealthDataPoint] = []
    @Published var stepCountData: [HealthDataPoint] = []
    @Published var bodyMassData: [HealthDataPoint] = []

    var isHealthDataAvailable: Bool { true }

    // MARK: - Authorization (no-op in demo mode)

    func requestAuthorization() async throws {
        isAuthorized = true
    }

    // MARK: - Load Demo Data

    func fetchAllData(from startDate: Date, to endDate: Date) async {
        let days = max(1, Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 90)
        let synth = PreviewData.generateSyntheticData(days: days)

        menstrualFlowData = synth.menstrualFlow
        intermenstrualBleedingData = synth.intermenstrualBleeding
        sleepData = synth.sleep
        heartRateData = synth.heartRate
        hrvData = synth.hrv
        basalTempData = synth.basalTemp
        hotFlashData = synth.hotFlashes
        stepCountData = synth.steps
        bodyMassData = synth.bodyMass
    }

    // MARK: - Cycle Detection

    func detectCycles(from flowData: [HealthDataPoint]) -> [(start: Date, length: Int)] {
        guard !flowData.isEmpty else { return [] }

        let sorted = flowData.sorted { $0.date < $1.date }
        var cycles: [(start: Date, length: Int)] = []
        var currentCycleStart = sorted[0].date

        for i in 1..<sorted.count {
            let gap = sorted[i - 1].date.daysBetween(sorted[i].date)
            if gap >= Constants.cycleGapDaysThreshold {
                let length = currentCycleStart.daysBetween(sorted[i].date)
                cycles.append((start: currentCycleStart, length: length))
                currentCycleStart = sorted[i].date
            }
        }

        let lastLength = currentCycleStart.daysBetween(Date())
        if lastLength > 0 {
            cycles.append((start: currentCycleStart, length: lastLength))
        }

        return cycles
    }
}
