import SwiftUI
import SwiftData

struct SymptomLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SymptomEntry.timestamp, order: .reverse) private var recentEntries: [SymptomEntry]
    @StateObject private var viewModel = SymptomLogViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                ColorPalette.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        symptomPicker

                        VStack(alignment: .leading, spacing: 12) {
                            SeveritySliderView(severity: $viewModel.severity)
                        }
                        .padding()
                        .background(ColorPalette.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                

                        VStack(spacing: 12) {
                            DatePicker("Date & Time", selection: $viewModel.selectedDate)
                                .font(AppFonts.subheadline)

                            TextField("Notes (optional)", text: $viewModel.notes, axis: .vertical)
                                .font(AppFonts.body())
                                .lineLimit(3...6)
                                .textFieldStyle(.roundedBorder)
                        }
                        .padding()
                        .background(ColorPalette.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                

                        Button(action: {
                            viewModel.save(modelContext: modelContext)
                        }) {
                            Text("Log Symptom")
                                .font(AppFonts.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(ColorPalette.primary)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        if !recentEntries.isEmpty {
                            recentEntriesSection
                        }
                    }
                    .padding()
                }
            }
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
                .font(AppFonts.title3)

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
        .background(ColorPalette.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))

    }

    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Entries")
                .font(AppFonts.title3)

            ForEach(recentEntries.prefix(10)) { entry in
                HStack {
                    Image(systemName: entry.symptomType.icon)
                        .foregroundColor(entry.symptomType.color)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.symptomType.rawValue)
                            .font(AppFonts.bodyBold(size: 14))
                        Text(entry.timestamp.mediumFormatted)
                            .font(AppFonts.caption())
                            .foregroundColor(ColorPalette.textSecondary)
                    }

                    Spacer()

                    Text("\(Int(entry.severity * 10))/10")
                        .font(AppFonts.bodyBold(size: 14))
                        .foregroundColor(ColorPalette.severityColor(for: entry.severity))
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(ColorPalette.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))

    }
}
