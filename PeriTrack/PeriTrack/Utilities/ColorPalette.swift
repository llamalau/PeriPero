import SwiftUI

enum ColorPalette {
    // Background — Ivory #FEFFF3
    static let background = Color(red: 0xFE/255, green: 0xFF/255, blue: 0xF3/255)
    static let cardBackground = Color.white
    static let cardShadow = Color.black.opacity(0.06)

    // Primary Buttons — Pacific Cyan #3A8695
    static let primary = Color(red: 0x3A/255, green: 0x86/255, blue: 0x95/255)
    static let primaryLight = Color(red: 0x3A/255, green: 0x86/255, blue: 0x95/255).opacity(0.7)
    static let primaryDark = Color(red: 0x2A/255, green: 0x66/255, blue: 0x73/255)

    // Data Visualization — Pearl Aqua #80C9D1
    static let dataViz = Color(red: 0x80/255, green: 0xC9/255, blue: 0xD1/255)

    // Highlights / Positive Moments — Mustard #FFD36C
    static let highlight = Color(red: 0xFF/255, green: 0xD3/255, blue: 0x6C/255)

    // Emotional / Insight Moments — Coral #F58A7A
    static let coral = Color(red: 0xF5/255, green: 0x8A/255, blue: 0x7A/255)

    // Data visualization colors — derived from palette
    static let menstrualFlow = coral
    static let sleep = Color(red: 0x3A/255, green: 0x86/255, blue: 0x95/255)      // Pacific Cyan
    static let heartRate = Color(red: 0xF5/255, green: 0x8A/255, blue: 0x7A/255)  // Coral
    static let hrv = Color(red: 0x80/255, green: 0xC9/255, blue: 0xD1/255)        // Pearl Aqua
    static let temperature = Color(red: 0xFF/255, green: 0xD3/255, blue: 0x6C/255) // Mustard
    static let hotFlashes = Color(red: 0xE8/255, green: 0x6B/255, blue: 0x5A/255) // Deeper coral
    static let steps = Color(red: 0x5A/255, green: 0xA6/255, blue: 0xB5/255)      // Mid cyan
    static let weight = Color(red: 0x6B/255, green: 0xB0/255, blue: 0xB8/255)     // Soft teal
    static let intermenstrualBleeding = Color(red: 0xD4/255, green: 0x6B/255, blue: 0x5E/255)

    // Symptom severity gradient
    static let severityLow = Color(red: 0x80/255, green: 0xC9/255, blue: 0xD1/255)   // Pearl Aqua
    static let severityMedium = Color(red: 0xFF/255, green: 0xD3/255, blue: 0x6C/255) // Mustard
    static let severityHigh = Color(red: 0xF5/255, green: 0x8A/255, blue: 0x7A/255)   // Coral

    // Manual symptom badge colors — varied from palette
    static let brainFog = Color(red: 0x80/255, green: 0xC9/255, blue: 0xD1/255)
    static let moodSwings = Color(red: 0xF5/255, green: 0x8A/255, blue: 0x7A/255)
    static let anxiety = Color(red: 0xFF/255, green: 0xD3/255, blue: 0x6C/255)
    static let jointPain = Color(red: 0x5A/255, green: 0xA6/255, blue: 0xB5/255)
    static let fatigue = Color(red: 0x3A/255, green: 0x86/255, blue: 0x95/255)
    static let headache = Color(red: 0xD4/255, green: 0x6B/255, blue: 0x5E/255)
    static let bloating = Color(red: 0xC8/255, green: 0xBF/255, blue: 0x6C/255)
    static let irritability = Color(red: 0xE8/255, green: 0x6B/255, blue: 0x5A/255)

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
