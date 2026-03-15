import SwiftUI
import SwiftData

struct ReportPreviewView: View {
    @StateObject private var viewModel = ReportViewModel()
    @ObservedObject var dashboardVM: DashboardViewModel
    @ObservedObject var healthKitManager = HealthKitManager.shared
    @Query(sort: \SymptomEntry.timestamp) private var symptomEntries: [SymptomEntry]
    @State private var showingShareSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                ColorPalette.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Patient Name (optional)")
                                .font(AppFonts.bodyBold(size: 14))
                            TextField("Name for report header", text: $viewModel.patientName)
                                .font(AppFonts.body())
                                .textFieldStyle(.roundedBorder)
                        }
                        .padding()
                        .background(ColorPalette.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                

                        reportContentsPreview

                        Button(action: generateReport) {
                            HStack {
                                Image(systemName: "doc.richtext")
                                Text("Generate PDF Report")
                            }
                            .font(AppFonts.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(ColorPalette.primary)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        if viewModel.pdfData != nil {
                            Button(action: { showingShareSheet = true }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share Report")
                                }
                                .font(AppFonts.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(ColorPalette.highlight)
                                .foregroundColor(ColorPalette.textPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(AppFonts.caption())
                                .foregroundColor(ColorPalette.coral)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Advocacy Report")
            .overlay {
                if viewModel.isGenerating {
                    LoadingOverlay(message: "Generating report...")
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let data = viewModel.pdfData {
                    ReportShareView(pdfData: data)
                }
            }
        }
    }

    private var reportContentsPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Report will include:")
                .font(AppFonts.title3)

            reportItem(icon: "calendar.circle", title: "Cycle Summary", detail: "\(dashboardVM.cycleLengths.count) cycles detected")
            reportItem(icon: "link", title: "Cross-Symptom Correlations", detail: "\(dashboardVM.correlations.count) significant correlations")
            reportItem(icon: "list.bullet.clipboard", title: "Symptom Log", detail: "\(symptomEntries.count) entries")
            reportItem(icon: "chart.xyaxis.line", title: "Timeline Visualization", detail: "Multi-track health data")
            reportItem(icon: "lightbulb", title: "AI-Generated Insights", detail: "Clinician-ready narrative")
        }
        .padding()
        .background(ColorPalette.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))

    }

    private func reportItem(icon: String, title: String, detail: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(ColorPalette.primary)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFonts.bodyBold(size: 14))
                Text(detail)
                    .font(AppFonts.caption())
                    .foregroundColor(ColorPalette.textSecondary)
            }
            Spacer()
        }
    }

    private func generateReport() {
        Task {
            await viewModel.generateReport(
                correlations: dashboardVM.correlations,
                cycleLengths: dashboardVM.cycleLengths,
                symptomEntries: symptomEntries,
                intermenstrualBleedingCount: healthKitManager.intermenstrualBleedingData.count,
                dateRange: "\(dashboardVM.startDate.mediumFormatted) – \(dashboardVM.endDate.mediumFormatted)"
            )
        }
    }
}
