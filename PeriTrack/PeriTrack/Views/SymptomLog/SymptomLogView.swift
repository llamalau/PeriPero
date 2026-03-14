import SwiftUI
import SwiftData

struct SymptomLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SymptomEntry.timestamp, order: .reverse) private var recentEntries: [SymptomEntry]
    @StateObject private var viewModel = SymptomLogViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Symptom type picker
                    symptomPicker

                    // Severity slider
                    VStack(alignment: .leading, spacing: 12) {
                        SeveritySliderView(severity: $viewModel.severity)
                    }
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: ColorPalette.cardShadow, radius: 4, y: 2)

                    // Date & Notes
                    VStack(spacing: 12) {
                        DatePicker("Date & Time", selection: $viewModel.selectedDate)
                            .font(.subheadline)

                        TextField("Notes (optional)", text: $viewModel.notes, axis: .vertical)
                            .lineLimit(3...6)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: ColorPalette.cardShadow, radius: 4, y: 2)

                    // Save button
                    Button(action: {
                        viewModel.save(modelContext: modelContext)
                    }) {
                        Text("Log Symptom")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(ColorPalette.primary)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Recent entries
                    if !recentEntries.isEmpty {
                        recentEntriesSection
                    }
                }
                .padding()
            }
            .background(ColorPalette.background)
            .navigationTitle("Log Symptom")
            .alert("Saved", isPresented: $viewModel.showingSaveConfirmation) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("\(viewModel.selectedType.rawValue) logged successfully.")
            }
        }
    }

    private var symptomPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What are you experiencing?")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 130), spacing: 8)
            ], spacing: 8) {
                ForEach(SymptomType.allCases) { symptom in
                    SymptomBadge(
                        symptomType: symptom,
                        isSelected: viewModel.selectedType == symptom
                    ) {
                        viewModel.selectedType = symptom
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: ColorPalette.cardShadow, radius: 4, y: 2)
    }

    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Entries")
                .font(.headline)

            ForEach(recentEntries.prefix(10)) { entry in
                HStack {
                    Image(systemName: entry.symptomType.icon)
                        .foregroundColor(entry.symptomType.color)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.symptomType.rawValue)
                            .font(.subheadline.weight(.medium))
                        Text(entry.timestamp.mediumFormatted)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Text("\(Int(entry.severity * 10))/10")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(ColorPalette.severityColor(for: entry.severity))
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: ColorPalette.cardShadow, radius: 4, y: 2)
    }
}
