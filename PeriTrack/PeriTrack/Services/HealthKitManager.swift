import Foundation
import HealthKit

@MainActor
final class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()

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

    private let readTypes: Set<HKObjectType> = {
        var types = Set<HKObjectType>()
        if let menstrualFlow = HKObjectType.categoryType(forIdentifier: .menstrualFlow) { types.insert(menstrualFlow) }
        if let intermenstrualBleeding = HKObjectType.categoryType(forIdentifier: .intermenstrualBleeding) { types.insert(intermenstrualBleeding) }
        if let sleepAnalysis = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) { types.insert(sleepAnalysis) }
        if let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate) { types.insert(heartRate) }
        if let hrv = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) { types.insert(hrv) }
        if let basalTemp = HKObjectType.quantityType(forIdentifier: .basalBodyTemperature) { types.insert(basalTemp) }
        if let hotFlashes = HKObjectType.categoryType(forIdentifier: .hotFlashes) { types.insert(hotFlashes) }  // iOS 17+ may use different identifier
        if let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount) { types.insert(stepCount) }
        if let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass) { types.insert(bodyMass) }
        return types
    }()

    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    // MARK: - Authorization

    func requestAuthorization() async throws {
        guard isHealthDataAvailable else { return }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }

        // HK read auth is opaque — we can't check if granted. Just mark that we asked.
        isAuthorized = true
    }

    // MARK: - Fetch All Data

    func fetchAllData(from startDate: Date, to endDate: Date) async {
        async let flow = fetchMenstrualFlow(from: startDate, to: endDate)
        async let bleeding = fetchIntermenstrualBleeding(from: startDate, to: endDate)
        async let sleep = fetchSleep(from: startDate, to: endDate)
        async let hr = fetchHeartRate(from: startDate, to: endDate)
        async let hrv = fetchHRV(from: startDate, to: endDate)
        async let temp = fetchBasalTemp(from: startDate, to: endDate)
        async let flashes = fetchHotFlashes(from: startDate, to: endDate)
        async let steps = fetchStepCount(from: startDate, to: endDate)
        async let mass = fetchBodyMass(from: startDate, to: endDate)

        let (flowResult, bleedingResult, sleepResult, hrResult, hrvResult, tempResult, flashResult, stepResult, massResult) = await (flow, bleeding, sleep, hr, hrv, temp, flashes, steps, mass)

        menstrualFlowData = flowResult
        intermenstrualBleedingData = bleedingResult
        sleepData = sleepResult
        heartRateData = hrResult
        hrvData = hrvResult
        basalTempData = tempResult
        hotFlashData = flashResult
        stepCountData = stepResult
        bodyMassData = massResult
    }

    // MARK: - Category Sample Queries

    private func fetchMenstrualFlow(from start: Date, to end: Date) async -> [HealthDataPoint] {
        guard let sampleType = HKObjectType.categoryType(forIdentifier: .menstrualFlow) else { return [] }
        let samples = await queryCategorySamples(sampleType: sampleType, from: start, to: end)
        return samples.map { sample in
            let flowValue = Double(sample.value) // HKCategoryValueMenstrualFlow
            return HealthDataPoint(
                category: .menstrualFlow,
                date: sample.startDate,
                value: flowValue,
                metadata: sample.metadata?.compactMapValues { "\($0)" }
            )
        }
    }

    private func fetchIntermenstrualBleeding(from start: Date, to end: Date) async -> [HealthDataPoint] {
        guard let sampleType = HKObjectType.categoryType(forIdentifier: .intermenstrualBleeding) else { return [] }
        let samples = await queryCategorySamples(sampleType: sampleType, from: start, to: end)
        return samples.map { sample in
            HealthDataPoint(category: .intermenstrualBleeding, date: sample.startDate, value: 1.0)
        }
    }

    private func fetchSleep(from start: Date, to end: Date) async -> [HealthDataPoint] {
        guard let sampleType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return [] }
        let samples = await queryCategorySamples(sampleType: sampleType, from: start, to: end)

        // Filter to actual sleep (not inBed)
        let sleepSamples = samples.filter { sample in
            let value = HKCategoryValueSleepAnalysis(rawValue: sample.value)
            switch value {
            case .asleepCore, .asleepDeep, .asleepREM, .asleepUnspecified:
                return true
            default:
                return false
            }
        }

        // Group by sleep night (6pm-6pm window) and sum durations
        let grouped = Dictionary(grouping: sleepSamples) { $0.startDate.sleepNightDate }
        return grouped.map { nightDate, nightSamples in
            let totalHours = nightSamples.reduce(0.0) { sum, sample in
                sum + sample.endDate.timeIntervalSince(sample.startDate) / 3600.0
            }
            return HealthDataPoint(category: .sleepAnalysis, date: nightDate, value: totalHours)
        }.sorted { $0.date < $1.date }
    }

    private func fetchHotFlashes(from start: Date, to end: Date) async -> [HealthDataPoint] {
        // Hot flashes: try the category type that exists
        // On some iOS versions this may not be available
        guard let sampleType = HKObjectType.categoryType(forIdentifier: .hotFlashes) else { return [] }
        let samples = await queryCategorySamples(sampleType: sampleType, from: start, to: end)
        return samples.map { sample in
            HealthDataPoint(category: .hotFlashes, date: sample.startDate, value: 1.0)
        }
    }

    private func queryCategorySamples(sampleType: HKCategoryType, from start: Date, to end: Date) async -> [HKCategorySample] {
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, results, _ in
                let samples = results as? [HKCategorySample] ?? []
                continuation.resume(returning: samples)
            }
            healthStore.execute(query)
        }
    }

    // MARK: - Statistics Collection Queries (Quantity Types)

    private func fetchHeartRate(from start: Date, to end: Date) async -> [HealthDataPoint] {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return [] }
        return await queryStatisticsCollection(
            quantityType: quantityType,
            unit: HKUnit.count().unitDivided(by: .minute()),
            category: .heartRate,
            option: .discreteAverage,
            from: start, to: end
        )
    }

    private func fetchHRV(from start: Date, to end: Date) async -> [HealthDataPoint] {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else { return [] }
        return await queryStatisticsCollection(
            quantityType: quantityType,
            unit: HKUnit.secondUnit(with: .milli),
            category: .hrv,
            option: .discreteAverage,
            from: start, to: end
        )
    }

    private func fetchBasalTemp(from start: Date, to end: Date) async -> [HealthDataPoint] {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .basalBodyTemperature) else { return [] }
        return await queryStatisticsCollection(
            quantityType: quantityType,
            unit: HKUnit.degreeFahrenheit(),
            category: .basalBodyTemperature,
            option: .discreteAverage,
            from: start, to: end
        )
    }

    private func fetchStepCount(from start: Date, to end: Date) async -> [HealthDataPoint] {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .stepCount) else { return [] }
        return await queryStatisticsCollection(
            quantityType: quantityType,
            unit: HKUnit.count(),
            category: .stepCount,
            option: .cumulativeSum,
            from: start, to: end
        )
    }

    private func fetchBodyMass(from start: Date, to end: Date) async -> [HealthDataPoint] {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .bodyMass) else { return [] }
        return await queryStatisticsCollection(
            quantityType: quantityType,
            unit: HKUnit.pound(),
            category: .bodyMass,
            option: .discreteAverage,
            from: start, to: end
        )
    }

    private func queryStatisticsCollection(
        quantityType: HKQuantityType,
        unit: HKUnit,
        category: HealthDataCategory,
        option: HKStatisticsOptions,
        from start: Date,
        to end: Date
    ) async -> [HealthDataPoint] {
        let interval = DateComponents(day: 1)
        let anchorDate = Calendar.current.startOfDay(for: start)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsCollectionQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: option,
                anchorDate: anchorDate,
                intervalComponents: interval
            )

            query.initialResultsHandler = { _, results, _ in
                guard let statsCollection = results else {
                    continuation.resume(returning: [])
                    return
                }

                var dataPoints: [HealthDataPoint] = []
                statsCollection.enumerateStatistics(from: start, to: end) { statistics, _ in
                    let value: Double?
                    if option == .cumulativeSum {
                        value = statistics.sumQuantity()?.doubleValue(for: unit)
                    } else {
                        value = statistics.averageQuantity()?.doubleValue(for: unit)
                    }

                    if let value = value {
                        dataPoints.append(HealthDataPoint(
                            category: category,
                            date: statistics.startDate,
                            value: value
                        ))
                    }
                }
                continuation.resume(returning: dataPoints)
            }

            healthStore.execute(query)
        }
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

        // Last cycle (open-ended — length to today)
        let lastLength = currentCycleStart.daysBetween(Date())
        if lastLength > 0 {
            cycles.append((start: currentCycleStart, length: lastLength))
        }

        return cycles
    }
}
