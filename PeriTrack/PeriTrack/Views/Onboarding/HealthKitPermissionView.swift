import SwiftUI

struct HealthKitPermissionView: View {
    var onComplete: () -> Void
    @State private var isRequesting = false
    @State private var showError = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "heart.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(ColorPalette.coral)

            VStack(spacing: 12) {
                Text("Health Data Access")
                    .font(AppFonts.title)
                    .foregroundColor(ColorPalette.primaryDark)

                Text("PeriPero reads your health data to detect patterns. Your data stays on your device.")
                    .font(AppFonts.body())
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(alignment: .leading, spacing: 12) {
                dataTypeRow("Menstrual cycles & flow")
                dataTypeRow("Sleep analysis")
                dataTypeRow("Heart rate & HRV")
                dataTypeRow("Basal body temperature")
                dataTypeRow("Step count")
                dataTypeRow("Body mass")
            }
            .padding(.horizontal, 40)

            Text("PeriPero only reads data — it never writes to Apple Health.")
                .font(AppFonts.caption())
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            VStack(spacing: 12) {
                Button(action: requestPermission) {
                    HStack {
                        if isRequesting {
                            ProgressView()
                                .tint(.white)
                        }
                        Text("Allow Health Access")
                    }
                    .font(AppFonts.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(ColorPalette.primary)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(isRequesting)

                Button("Skip for Now") {
                    onComplete()
                }
                .font(AppFonts.subheadline)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 16)
        }
        .background(ColorPalette.background)
        .alert("Could not request access", isPresented: $showError) {
            Button("Continue Anyway") { onComplete() }
        } message: {
            Text("You can enable Health access later in Settings > Privacy & Security > Health > PeriPero.")
        }
    }

    private func dataTypeRow(_ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(ColorPalette.primary)
            Text(text)
                .font(AppFonts.subheadline)
        }
    }

    private func requestPermission() {
        isRequesting = true
        Task {
            do {
                try await HealthKitManager.shared.requestAuthorization()
                await MainActor.run {
                    isRequesting = false
                    onComplete()
                }
            } catch {
                await MainActor.run {
                    isRequesting = false
                    showError = true
                }
            }
        }
    }
}
