import SwiftUI

struct WelcomeView: View {
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "sun.max.fill")
                .font(.system(size: 80))
                .foregroundStyle(ColorPalette.highlight)

            VStack(spacing: 16) {
                Text("Welcome to the\nSummer of your Life")
                    .font(AppFonts.largeTitle)
                    .multilineTextAlignment(.center)
                    .foregroundColor(ColorPalette.primaryDark)

                Text("Clarity for your changing body")
                    .font(AppFonts.body(size: 18))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            VStack(alignment: .leading, spacing: 20) {
                featureRow(icon: "chart.xyaxis.line", title: "Track Patterns", description: "Automatically pull data from Apple Health and log symptoms manually")
                featureRow(icon: "link", title: "Detect Correlations", description: "Find hidden connections between sleep, heart rate, cycles, and symptoms")
                featureRow(icon: "doc.richtext", title: "Generate Reports", description: "Create clinician-ready advocacy reports backed by your data")
            }
            .padding(.horizontal, 32)

            Spacer()

            Button(action: onContinue) {
                Text("Get Started")
                    .font(AppFonts.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(ColorPalette.primary)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 16)
        }
        .background(ColorPalette.background)
    }

    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(ColorPalette.primary)
                .frame(width: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppFonts.headline)
                Text(description)
                    .font(AppFonts.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
