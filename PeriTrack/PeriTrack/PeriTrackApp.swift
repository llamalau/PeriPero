import SwiftUI
import SwiftData

@main
struct PeriPeroApp: App {
    @AppStorage(Constants.Onboarding.hasCompletedOnboardingKey) private var hasCompletedOnboarding = false
    @StateObject private var dashboardVM = DashboardViewModel()

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                mainTabView
            } else {
                OnboardingContainerView()
            }
        }
        .modelContainer(for: SymptomEntry.self)
    }

    private var mainTabView: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.xyaxis.line")
                }

            SymptomLogView()
                .tabItem {
                    Label("Log", systemImage: "plus.circle")
                }

            ReportPreviewView(dashboardVM: dashboardVM)
                .tabItem {
                    Label("Report", systemImage: "doc.richtext")
                }
        }
        .tint(ColorPalette.primary)
    }
}
