import SwiftUI

struct OnboardingContainerView: View {
    @AppStorage(Constants.Onboarding.hasCompletedOnboardingKey) private var hasCompletedOnboarding = false
    @State private var currentPage = 0

    var body: some View {
        TabView(selection: $currentPage) {
            WelcomeView {
                withAnimation { currentPage = 1 }
            }
            .tag(0)

            dataExplanationView
                .tag(1)

            HealthKitPermissionView {
                hasCompletedOnboarding = true
            }
            .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }

    private var dataExplanationView: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundStyle(ColorPalette.primary)

            VStack(spacing: 12) {
                Text("Your Data, Your Control")
                    .font(.title.weight(.bold))

                Text("PeriPero processes all data locally on your device. Nothing is uploaded to any server without your explicit action.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(alignment: .leading, spacing: 16) {
                privacyRow(icon: "iphone", title: "On-Device Processing", detail: "All pattern detection happens locally")
                privacyRow(icon: "doc.richtext", title: "Reports You Control", detail: "PDF reports are generated locally — you choose who to share them with")
                privacyRow(icon: "brain.head.profile", title: "Optional AI Insights", detail: "AI-powered analysis sends anonymized data summaries only when you request a report")
            }
            .padding(.horizontal, 32)

            Spacer()

            Button(action: { withAnimation { currentPage = 2 } }) {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(ColorPalette.primary)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 16)
        }
    }

    private func privacyRow(icon: String, title: String, detail: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(ColorPalette.primary)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
