import Foundation

enum HealthDataCategory: String, Codable, CaseIterable, Identifiable {
    case menstrualFlow = "Menstrual Flow"
    case intermenstrualBleeding = "Intermenstrual Bleeding"
    case sleepAnalysis = "Sleep"
    case heartRate = "Heart Rate"
    case hrv = "HRV (SDNN)"
    case basalBodyTemperature = "Basal Body Temp"
    case hotFlashes = "Hot Flashes"
    case stepCount = "Steps"
    case bodyMass = "Body Mass"

    var id: String { rawValue }

    var unit: String {
        switch self {
        case .menstrualFlow: return ""
        case .intermenstrualBleeding: return ""
        case .sleepAnalysis: return "hrs"
        case .heartRate: return "bpm"
        case .hrv: return "ms"
        case .basalBodyTemperature: return "°F"
        case .hotFlashes: return ""
        case .stepCount: return "steps"
        case .bodyMass: return "lbs"
        }
    }
}

struct HealthDataPoint: Identifiable, Codable {
    let id: UUID
    let category: HealthDataCategory
    let date: Date
    let value: Double
    let metadata: [String: String]?

    init(category: HealthDataCategory, date: Date, value: Double, metadata: [String: String]? = nil) {
        self.id = UUID()
        self.category = category
        self.date = date
        self.value = value
        self.metadata = metadata
    }
}

extension HealthDataPoint {
    /// Aggregate an array of data points by day, using the specified strategy
    static func aggregateByDay(_ points: [HealthDataPoint], strategy: AggregationStrategy) -> [HealthDataPoint] {
        let grouped = Dictionary(grouping: points) { Calendar.current.startOfDay(for: $0.date) }
        return grouped.compactMap { date, dayPoints in
            guard let first = dayPoints.first else { return nil }
            let aggregatedValue: Double
            switch strategy {
            case .sum:
                aggregatedValue = dayPoints.reduce(0) { $0 + $1.value }
            case .average:
                aggregatedValue = dayPoints.reduce(0) { $0 + $1.value } / Double(dayPoints.count)
            case .count:
                aggregatedValue = Double(dayPoints.count)
            case .max:
                aggregatedValue = dayPoints.map(\.value).max() ?? 0
            }
            return HealthDataPoint(category: first.category, date: date, value: aggregatedValue)
        }.sorted { $0.date < $1.date }
    }

    enum AggregationStrategy {
        case sum, average, count, max
    }
}
