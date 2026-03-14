import Foundation

enum PreviewData {

    /// Generate synthetic health data for previews and demo mode
    static func generateSyntheticData(days: Int = 90) -> (
        menstrualFlow: [HealthDataPoint],
        intermenstrualBleeding: [HealthDataPoint],
        sleep: [HealthDataPoint],
        heartRate: [HealthDataPoint],
        hrv: [HealthDataPoint],
        basalTemp: [HealthDataPoint],
        hotFlashes: [HealthDataPoint],
        steps: [HealthDataPoint],
        bodyMass: [HealthDataPoint]
    ) {
        let endDate = Date()
        var menstrualFlow: [HealthDataPoint] = []
        var intermenstrualBleeding: [HealthDataPoint] = []
        var sleep: [HealthDataPoint] = []
        var heartRate: [HealthDataPoint] = []
        var hrv: [HealthDataPoint] = []
        var basalTemp: [HealthDataPoint] = []
        var hotFlashes: [HealthDataPoint] = []
        var steps: [HealthDataPoint] = []
        var bodyMass: [HealthDataPoint] = []

        // Simulate irregular cycles (perimenopause pattern)
        let cycleLengths = [28, 32, 26, 35, 24, 38]  // Variable cycle lengths
        var cycleDay = 0
        var cycleIndex = 0
        var currentCycleLength = cycleLengths[0]
        var dayInCycle = 0

        for dayOffset in (0..<days).reversed() {
            let date = endDate.daysAgo(dayOffset)
            dayInCycle += 1

            // Menstrual flow (first 4-6 days of each cycle)
            let flowDuration = Int.random(in: 4...6)
            if dayInCycle <= flowDuration {
                let flowIntensity: Double
                switch dayInCycle {
                case 1: flowIntensity = 1.0  // light start
                case 2, 3: flowIntensity = 3.0  // heavy
                case 4: flowIntensity = 2.0  // moderate
                default: flowIntensity = 1.0  // light end
                }
                menstrualFlow.append(HealthDataPoint(category: .menstrualFlow, date: date, value: flowIntensity))
            }

            // Cycle reset
            if dayInCycle >= currentCycleLength {
                dayInCycle = 0
                cycleIndex = (cycleIndex + 1) % cycleLengths.count
                currentCycleLength = cycleLengths[cycleIndex]
            }

            // Intermenstrual bleeding (occasional)
            if dayOffset == 45 || dayOffset == 67 {
                intermenstrualBleeding.append(HealthDataPoint(category: .intermenstrualBleeding, date: date, value: 1.0))
            }

            // Sleep — reduced before/during menstruation
            let baseSleep = 7.2
            let sleepVariation = Double.random(in: -0.8...0.8)
            let preMenstrualSleepDrop = (dayInCycle > currentCycleLength - 5) ? -1.2 : 0.0
            let duringFlowDrop = (dayInCycle <= flowDuration) ? -0.6 : 0.0
            let sleepHours = max(4.0, baseSleep + sleepVariation + preMenstrualSleepDrop + duringFlowDrop)
            sleep.append(HealthDataPoint(category: .sleepAnalysis, date: date, value: sleepHours))

            // Heart rate — elevated before menstruation
            let baseHR = 72.0
            let hrVariation = Double.random(in: -5...5)
            let preMenstrualHRBump = (dayInCycle > currentCycleLength - 7) ? 8.0 : 0.0
            heartRate.append(HealthDataPoint(category: .heartRate, date: date, value: baseHR + hrVariation + preMenstrualHRBump))

            // HRV — drops before menstruation (inverse of HR)
            let baseHRV = 45.0
            let hrvVariation = Double.random(in: -8...8)
            let preMenstrualHRVDrop = (dayInCycle > currentCycleLength - 7) ? -12.0 : 0.0
            hrv.append(HealthDataPoint(category: .hrv, date: date, value: max(15, baseHRV + hrvVariation + preMenstrualHRVDrop)))

            // Basal body temp — biphasic pattern
            let preOvulationTemp = 97.4
            let postOvulationTemp = 97.9
            let tempVariation = Double.random(in: -0.2...0.2)
            let isPostOvulation = dayInCycle > (currentCycleLength / 2)
            let bbt = (isPostOvulation ? postOvulationTemp : preOvulationTemp) + tempVariation
            basalTemp.append(HealthDataPoint(category: .basalBodyTemperature, date: date, value: bbt))

            // Hot flashes — more frequent in luteal phase
            let hotFlashChance = isPostOvulation ? 0.25 : 0.08
            if Double.random(in: 0...1) < hotFlashChance {
                hotFlashes.append(HealthDataPoint(category: .hotFlashes, date: date, value: 1.0))
            }

            // Steps — reduced during menstruation and premenstrual
            let baseSteps = 8500.0
            let stepVariation = Double.random(in: -2000...2000)
            let menstrualStepDrop = (dayInCycle <= flowDuration || dayInCycle > currentCycleLength - 3) ? -2000.0 : 0.0
            steps.append(HealthDataPoint(category: .stepCount, date: date, value: max(1000, baseSteps + stepVariation + menstrualStepDrop)))

            // Body mass — slight fluctuation
            let baseWeight = 145.0
            let weightVariation = Double.random(in: -1.5...1.5)
            let preMenstrualBloat = (dayInCycle > currentCycleLength - 5) ? 2.5 : 0.0
            bodyMass.append(HealthDataPoint(category: .bodyMass, date: date, value: baseWeight + weightVariation + preMenstrualBloat))

            cycleDay += 1
        }

        return (menstrualFlow, intermenstrualBleeding, sleep, heartRate, hrv, basalTemp, hotFlashes, steps, bodyMass)
    }

    /// Generate synthetic symptom entries for preview
    static func generateSyntheticSymptoms(days: Int = 90) -> [SymptomEntry] {
        var entries: [SymptomEntry] = []
        let endDate = Date()

        // Brain fog — clusters around premenstrual days
        for dayOffset in stride(from: 0, to: days, by: Int.random(in: 3...7)) {
            let date = endDate.daysAgo(dayOffset)
            entries.append(SymptomEntry(type: .brainFog, severity: Double.random(in: 0.3...0.9), timestamp: date))
        }

        // Fatigue — frequent
        for dayOffset in stride(from: 1, to: days, by: Int.random(in: 2...5)) {
            let date = endDate.daysAgo(dayOffset)
            entries.append(SymptomEntry(type: .fatigue, severity: Double.random(in: 0.4...0.8), timestamp: date))
        }

        // Night sweats — periodic
        for dayOffset in stride(from: 3, to: days, by: Int.random(in: 5...10)) {
            let date = endDate.daysAgo(dayOffset)
            entries.append(SymptomEntry(type: .nightSweats, severity: Double.random(in: 0.5...1.0), timestamp: date))
        }

        // Mood swings — occasional
        for dayOffset in stride(from: 5, to: days, by: Int.random(in: 7...14)) {
            let date = endDate.daysAgo(dayOffset)
            entries.append(SymptomEntry(type: .moodSwings, severity: Double.random(in: 0.3...0.7), timestamp: date))
        }

        // Joint pain — occasional
        for dayOffset in stride(from: 10, to: days, by: Int.random(in: 10...20)) {
            let date = endDate.daysAgo(dayOffset)
            entries.append(SymptomEntry(type: .jointPain, severity: Double.random(in: 0.4...0.8), timestamp: date))
        }

        // Headache — occasional
        for dayOffset in stride(from: 7, to: days, by: Int.random(in: 8...15)) {
            let date = endDate.daysAgo(dayOffset)
            entries.append(SymptomEntry(type: .headache, severity: Double.random(in: 0.3...0.9), timestamp: date))
        }

        return entries
    }
}
