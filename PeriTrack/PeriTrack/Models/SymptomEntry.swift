import Foundation
import SwiftData

@Model
final class SymptomEntry {
    var id: UUID
    var type: String  // SymptomType.rawValue — SwiftData doesn't support enums directly
    var severity: Double  // 0.0 to 1.0
    var notes: String
    var timestamp: Date

    init(type: SymptomType, severity: Double, notes: String = "", timestamp: Date = .now) {
        self.id = UUID()
        self.type = type.rawValue
        self.severity = severity
        self.notes = notes
        self.timestamp = timestamp
    }

    var symptomType: SymptomType {
        SymptomType(rawValue: type) ?? .other
    }
}
