import Foundation

struct CorrelationEngine {

    /// Compute Pearson correlation between two time series aligned by date.
    /// Also checks lagged correlations (shifting series2 by 1-7 days).
    /// Returns the best (highest |r|) correlation found.
    static func computeBestCorrelation(
        series1: [HealthDataPoint],
        series2: [HealthDataPoint],
        label1: String,
        label2: String,
        maxLag: Int = 7
    ) -> CorrelationResult? {
        var bestResult: CorrelationResult?
        var bestAbsR: Double = 0

        for lag in 0...maxLag {
            if let result = computeCorrelation(
                series1: series1,
                series2: series2,
                label1: label1,
                label2: label2,
                lagDays: lag
            ) {
                if abs(result.coefficient) > bestAbsR {
                    bestAbsR = abs(result.coefficient)
                    bestResult = result
                }
            }
        }

        return bestResult
    }

    /// Pearson correlation with optional lag.
    /// lagDays > 0 means series2 is shifted back by that many days (series2 leads).
    static func computeCorrelation(
        series1: [HealthDataPoint],
        series2: [HealthDataPoint],
        label1: String,
        label2: String,
        lagDays: Int = 0
    ) -> CorrelationResult? {
        // Build date-indexed dictionaries
        let dict1 = Dictionary(grouping: series1) { Calendar.current.startOfDay(for: $0.date) }
            .mapValues { $0.map(\.value).reduce(0, +) / Double($0.count) }

        let dict2 = Dictionary(grouping: series2) { Calendar.current.startOfDay(for: $0.date) }
            .mapValues { $0.map(\.value).reduce(0, +) / Double($0.count) }

        // Align by date, applying lag
        var paired: [(Double, Double)] = []
        for (date, val1) in dict1 {
            let lookupDate = Calendar.current.date(byAdding: .day, value: -lagDays, to: date) ?? date
            if let val2 = dict2[Calendar.current.startOfDay(for: lookupDate)] {
                paired.append((val1, val2))
            }
        }

        guard paired.count >= Constants.minimumCorrelationDataPoints else { return nil }

        let n = Double(paired.count)
        let xs = paired.map(\.0)
        let ys = paired.map(\.1)

        let meanX = xs.reduce(0, +) / n
        let meanY = ys.reduce(0, +) / n

        var sumXY: Double = 0
        var sumX2: Double = 0
        var sumY2: Double = 0

        for (x, y) in paired {
            let dx = x - meanX
            let dy = y - meanY
            sumXY += dx * dy
            sumX2 += dx * dx
            sumY2 += dy * dy
        }

        guard sumX2 > 0, sumY2 > 0 else { return nil }

        let r = sumXY / (sumX2.squareRoot() * sumY2.squareRoot())

        // Approximate p-value using t-distribution approximation
        let t = r * ((n - 2) / (1 - r * r)).squareRoot()
        let pValue = approximatePValue(t: t, df: Int(n) - 2)

        return CorrelationResult(
            series1Label: label1,
            series2Label: label2,
            coefficient: r,
            lagDays: lagDays,
            dataPointCount: paired.count,
            pValue: pValue
        )
    }

    /// Compute all pairwise correlations between multiple data streams
    static func computeAllCorrelations(
        streams: [(label: String, data: [HealthDataPoint])]
    ) -> [CorrelationResult] {
        var results: [CorrelationResult] = []

        for i in 0..<streams.count {
            for j in (i + 1)..<streams.count {
                guard !streams[i].data.isEmpty, !streams[j].data.isEmpty else { continue }

                if let result = computeBestCorrelation(
                    series1: streams[i].data,
                    series2: streams[j].data,
                    label1: streams[i].label,
                    label2: streams[j].label
                ), result.isSignificant {
                    results.append(result)
                }
            }
        }

        return results.sorted { abs($0.coefficient) > abs($1.coefficient) }
    }

    // MARK: - P-value approximation

    /// Simple p-value approximation using the t-statistic.
    /// Uses a rough normal approximation for large df.
    private static func approximatePValue(t: Double, df: Int) -> Double {
        // For df > 30, t-distribution ≈ normal
        let absT = abs(t)
        // Simple complementary error function approximation
        let z = absT
        let p = erfc(z / 2.0.squareRoot()) // two-tailed
        return min(1.0, max(0.0, p))
    }
}
