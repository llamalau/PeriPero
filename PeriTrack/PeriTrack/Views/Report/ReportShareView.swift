import SwiftUI
import UIKit

struct ReportShareView: UIViewControllerRepresentable {
    let pdfData: Data

    func makeUIViewController(context: Context) -> UIActivityViewController {
        // Create a temporary file for the PDF
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("PeriPero_Report.pdf")
        try? pdfData.write(to: tempURL)

        let activityVC = UIActivityViewController(
            activityItems: [tempURL],
            applicationActivities: nil
        )

        return activityVC
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
