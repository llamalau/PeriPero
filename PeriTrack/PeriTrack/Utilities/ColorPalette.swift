import SwiftUI

enum ColorPalette {
    // Primary brand colors
    static let primary = Color(red: 0.800, green: 0.349, blue: 0.557)
    static let primaryLight = Color(red: 0.878, green: 0.475, blue: 0.667)
    static let primaryDark = Color(red: 0.620, green: 0.220, blue: 0.420)

    // Background
    static let background = Color(red: 0.98, green: 0.96, blue: 0.97)
    static let cardBackground = Color.white
    static let cardShadow = Color.black.opacity(0.06)

    // Data visualization colors — distinguishable & accessible
    static let menstrualFlow = Color(red: 0.85, green: 0.25, blue: 0.35)
    static let sleep = Color(red: 0.30, green: 0.40, blue: 0.75)
    static let heartRate = Color(red: 0.90, green: 0.35, blue: 0.30)
    static let hrv = Color(red: 0.30, green: 0.70, blue: 0.50)
    static let temperature = Color(red: 0.95, green: 0.60, blue: 0.20)
    static let hotFlashes = Color(red: 1.00, green: 0.40, blue: 0.15)
    static let steps = Color(red: 0.25, green: 0.65, blue: 0.80)
    static let weight = Color(red: 0.55, green: 0.45, blue: 0.70)
    static let intermenstrualBleeding = Color(red: 0.75, green: 0.20, blue: 0.45)

    // Symptom severity gradient
    static let severityLow = Color(red: 0.60, green: 0.80, blue: 0.40)
    static let severityMedium = Color(red: 0.95, green: 0.75, blue: 0.25)
    static let severityHigh = Color(red: 0.90, green: 0.30, blue: 0.25)

    // Manual symptom badge colors
    static let brainFog = Color(red: 0.55, green: 0.55, blue: 0.75)
    static let moodSwings = Color(red: 0.70, green: 0.45, blue: 0.65)
    static let anxiety = Color(red: 0.80, green: 0.50, blue: 0.40)
    static let jointPain = Color(red: 0.50, green: 0.60, blue: 0.55)
    static let fatigue = Color(red: 0.45, green: 0.50, blue: 0.70)
    static let headache = Color(red: 0.70, green: 0.40, blue: 0.40)
    static let bloating = Color(red: 0.60, green: 0.65, blue: 0.45)
    static let irritability = Color(red: 0.85, green: 0.45, blue: 0.35)

    static func severityColor(for severity: Double) -> Color {
        if severity < 0.4 {
            return severityLow
        } else if severity < 0.7 {
            return severityMedium
        } else {
            return severityHigh
        }
    }
}
