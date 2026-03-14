import Foundation
import SwiftData

@MainActor
final class SymptomLogViewModel: ObservableObject {
    @Published var selectedType: SymptomType = .brainFog
    @Published var severity: Double = 0.5
    @Published var notes: String = ""
    @Published var selectedDate: Date = .now
    @Published var showingSaveConfirmation = false

    func save(modelContext: ModelContext) {
        let entry = SymptomEntry(
            type: selectedType,
            severity: severity,
            notes: notes,
            timestamp: selectedDate
        )
        modelContext.insert(entry)

        // Reset form
        severity = 0.5
        notes = ""
        selectedDate = .now
        showingSaveConfirmation = true
    }

    func deleteEntry(_ entry: SymptomEntry, modelContext: ModelContext) {
        modelContext.delete(entry)
    }

    func symptomSummary(entries: [SymptomEntry]) -> [(type: String, avgSeverity: Double, count: Int)] {
        let grouped = Dictionary(grouping: entries) { $0.type }
        return grouped.map { type, entries in
            let avgSeverity = entries.map(\.severity).reduce(0, +) / Double(entries.count)
            return (type: type, avgSeverity: avgSeverity, count: entries.count)
        }.sorted { $0.count > $1.count }
    }
}
