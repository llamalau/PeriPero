import SwiftUI

struct HealthKitPermissionView: View {
    var onComplete: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(ColorPalette.primary)

            VStack(spacing: 12) {
                Text("You're All Set")
                    .font(AppFonts.title)
                    .foregroundColor(ColorPalette.primaryDark)

                Text("PeriPero is loaded with sample health data so you can explore the full experience right away.")
                    .font(AppFonts.body())
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(alignment: .leading, spacing: 12) {
                dataTypeRow("90 days of cycle, sleep & heart data")
                dataTypeRow("Correlation detection across symptoms")
                dataTypeRow("AI-powered advocacy reports")
                dataTypeRow("Manual symptom logging")
            }
            .padding(.horizontal, 40)

            Text("With a paid Apple Developer account, PeriPero can connect to real Apple Health data.")
                .font(AppFonts.caption())
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            Button(action: onComplete) {
                Text("Start Exploring")
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

    private func dataTypeRow(_ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(ColorPalette.highlight)
            Text(text)
                .font(AppFonts.subheadline)
        }
    }
}
