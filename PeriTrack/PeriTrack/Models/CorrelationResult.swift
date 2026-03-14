import Foundation

struct CorrelationResult: Identifiable {
    let id = UUID()
    let series1Label: String
    let series2Label: String
    let coefficient: Double    // Pearson r, -1.0 to 1.0
    let lagDays: Int           // 0 = same day, positive = series2 leads
    let dataPointCount: Int
    let pValue: Double?

    var strength: CorrelationStrength {
        let abs = abs(coefficient)
        if abs >= 0.7 { return .strong }
        if abs >= 0.4 { return .moderate }
        if abs >= 0.2 { return .weak }
        return .negligible
    }

    var direction: CorrelationDirection {
        if coefficient > 0 { return .positive }
        if coefficient < 0 { return .negative }
        return .none
    }

    var isSignificant: Bool {
        strength != .negligible && dataPointCount >= Constants.minimumCorrelationDataPoints
    }

    var summaryText: String {
        let directionWord = direction == .positive ? "increases" : "decreases"
        let lagText = lagDays == 0 ? "on the same day" : "\(lagDays) day\(lagDays == 1 ? "" : "s") before"
        return "\(series1Label) tends to \(directionWord == "increases" ? "rise" : "fall") when \(series2Label) \(directionWord) \(lagText). (\(strength.rawValue) correlation, r=\(String(format: "%.2f", coefficient)), n=\(dataPointCount))"
    }
}

enum CorrelationStrength: String {
    case strong = "Strong"
    case moderate = "Moderate"
    case weak = "Weak"
    case negligible = "Negligible"
}

enum CorrelationDirection {
    case positive, negative, none
}
