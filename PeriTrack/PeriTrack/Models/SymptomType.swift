import SwiftUI

enum SymptomType: String, Codable, CaseIterable, Identifiable {
    case brainFog = "Brain Fog"
    case moodSwings = "Mood Swings"
    case anxiety = "Anxiety"
    case jointPain = "Joint Pain"
    case fatigue = "Fatigue"
    case headache = "Headache"
    case bloating = "Bloating"
    case vaginalDryness = "Vaginal Dryness"
    case irritability = "Irritability"
    case nightSweats = "Night Sweats"
    case lowLibido = "Low Libido"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .brainFog: return "cloud.fog"
        case .moodSwings: return "arrow.up.arrow.down"
        case .anxiety: return "exclamationmark.triangle"
        case .jointPain: return "figure.walk"
        case .fatigue: return "battery.25percent"
        case .headache: return "bolt"
        case .bloating: return "circle.dashed"
        case .vaginalDryness: return "drop.triangle"
        case .irritability: return "flame"
        case .nightSweats: return "moon.stars"
        case .lowLibido: return "heart.slash"
        case .other: return "ellipsis.circle"
        }
    }

    var color: Color {
        switch self {
        case .brainFog: return ColorPalette.brainFog
        case .moodSwings: return ColorPalette.moodSwings
        case .anxiety: return ColorPalette.anxiety
        case .jointPain: return ColorPalette.jointPain
        case .fatigue: return ColorPalette.fatigue
        case .headache: return ColorPalette.headache
        case .bloating: return ColorPalette.bloating
        case .vaginalDryness: return ColorPalette.primaryLight
        case .irritability: return ColorPalette.irritability
        case .nightSweats: return ColorPalette.sleep
        case .lowLibido: return ColorPalette.primaryDark
        case .other: return .gray
        }
    }
}
