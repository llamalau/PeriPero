import Foundation

enum Constants {
    static let appName = "PeriPero"
    static let minimumCorrelationDataPoints = 30
    static let maximumQueryDays = 365
    static let defaultDateRangeDays = 90
    static let sleepNightBoundaryHour = 18 // 6pm cutoff for grouping sleep by night
    static let cycleGapDaysThreshold = 2   // 2+ day gap = new cycle

    enum HealthKit {
        static let shareUsageDescription = "PeriPero reads your health data to detect patterns related to perimenopause symptoms. Your data stays on your device and is never uploaded without your explicit consent."
    }

    enum Claude {
        // Hardcoded for hackathon — would use Keychain in production
        static let apiKey = "YOUR_CLAUDE_API_KEY"
        static let apiURL = "https://api.anthropic.com/v1/messages"
        static let model = "claude-sonnet-4-6"
        static let apiVersion = "2023-06-01"
    }

    enum Report {
        static let title = "PeriPero Health Report"
        static let subtitle = "Prepared for clinician review"
        static let footer = "Data from Apple Health + manual logs. Not a diagnostic tool."
        static let pageWidth: CGFloat = 612  // US Letter
        static let pageHeight: CGFloat = 792
        static let margin: CGFloat = 50
    }

    enum Onboarding {
        static let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    }
}
