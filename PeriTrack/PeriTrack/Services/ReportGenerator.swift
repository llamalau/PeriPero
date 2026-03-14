import UIKit
import SwiftUI

final class ReportGenerator {

    struct ReportData {
        let patientName: String?
        let dateRange: String
        let cycleSummary: CycleSummary?
        let insights: [String]
        let narrative: String
        let symptomFrequencies: [(type: String, count: Int, avgSeverity: Double)]
        let intermenstrualBleedingCount: Int
    }

    struct CycleSummary {
        let averageLength: Double
        let variability: Double
        let cycleCount: Int
        let trend: String // "shortening", "lengthening", "stable", "insufficient data"
    }

    static func generatePDF(from data: ReportData) -> Data {
        let pageWidth = Constants.Report.pageWidth
        let pageHeight = Constants.Report.pageHeight
        let margin = Constants.Report.margin
        let contentWidth = pageWidth - 2 * margin

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        let pdfData = pdfRenderer.pdfData { context in
            var currentY: CGFloat = margin

            func startNewPageIfNeeded(neededHeight: CGFloat) {
                if currentY + neededHeight > pageHeight - margin {
                    drawFooter(context: context.cgContext, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin)
                    context.beginPage()
                    currentY = margin
                }
            }

            // MARK: - Page 1: Header + Cycle Summary + Insights
            context.beginPage()

            // Header
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor(red: 0.8, green: 0.35, blue: 0.56, alpha: 1)
            ]
            let title = Constants.Report.title as NSString
            title.draw(at: CGPoint(x: margin, y: currentY), withAttributes: titleAttrs)
            currentY += 35

            let subtitleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor.darkGray
            ]
            let subtitle = Constants.Report.subtitle as NSString
            subtitle.draw(at: CGPoint(x: margin, y: currentY), withAttributes: subtitleAttrs)
            currentY += 25

            // Patient name & date range
            let infoAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: UIColor.darkGray
            ]
            if let name = data.patientName, !name.isEmpty {
                ("Patient: \(name)" as NSString).draw(at: CGPoint(x: margin, y: currentY), withAttributes: infoAttrs)
                currentY += 18
            }
            ("Date Range: \(data.dateRange)" as NSString).draw(at: CGPoint(x: margin, y: currentY), withAttributes: infoAttrs)
            currentY += 18
            ("Generated: \(Date().mediumFormatted)" as NSString).draw(at: CGPoint(x: margin, y: currentY), withAttributes: infoAttrs)
            currentY += 30

            // Divider
            drawDivider(context: context.cgContext, y: currentY, margin: margin, width: contentWidth)
            currentY += 15

            // MARK: - Cycle Summary
            if let cycle = data.cycleSummary {
                startNewPageIfNeeded(neededHeight: 120)
                let sectionAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
                    .foregroundColor: UIColor.black
                ]
                ("Cycle Summary" as NSString).draw(at: CGPoint(x: margin, y: currentY), withAttributes: sectionAttrs)
                currentY += 28

                let bodyAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                    .foregroundColor: UIColor.darkGray
                ]

                let cycleLines = [
                    "Cycles tracked: \(cycle.cycleCount)",
                    "Average length: \(String(format: "%.1f", cycle.averageLength)) days",
                    "Variability: ±\(String(format: "%.1f", cycle.variability)) days",
                    "Trend: \(cycle.trend)",
                    "Intermenstrual bleeding events: \(data.intermenstrualBleedingCount)"
                ]

                for line in cycleLines {
                    (line as NSString).draw(at: CGPoint(x: margin + 15, y: currentY), withAttributes: bodyAttrs)
                    currentY += 18
                }
                currentY += 15
            }

            // MARK: - Top Insights
            if !data.insights.isEmpty {
                drawDivider(context: context.cgContext, y: currentY, margin: margin, width: contentWidth)
                currentY += 15

                let sectionAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
                    .foregroundColor: UIColor.black
                ]
                ("Key Findings" as NSString).draw(at: CGPoint(x: margin, y: currentY), withAttributes: sectionAttrs)
                currentY += 28

                let bodyAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 11, weight: .regular),
                    .foregroundColor: UIColor.darkGray
                ]

                for insight in data.insights.prefix(5) {
                    startNewPageIfNeeded(neededHeight: 60)

                    let bulletText = "• \(insight)" as NSString
                    let textRect = CGRect(x: margin + 10, y: currentY, width: contentWidth - 20, height: 100)
                    let boundingRect = bulletText.boundingRect(with: CGSize(width: textRect.width, height: .greatestFiniteMagnitude),
                                                               options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                               attributes: bodyAttrs, context: nil)
                    bulletText.draw(in: textRect, withAttributes: bodyAttrs)
                    currentY += boundingRect.height + 10
                }
                currentY += 10
            }

            // MARK: - Narrative
            if !data.narrative.isEmpty {
                startNewPageIfNeeded(neededHeight: 100)
                drawDivider(context: context.cgContext, y: currentY, margin: margin, width: contentWidth)
                currentY += 15

                let sectionAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
                    .foregroundColor: UIColor.black
                ]
                ("Detailed Analysis" as NSString).draw(at: CGPoint(x: margin, y: currentY), withAttributes: sectionAttrs)
                currentY += 28

                let narrativeAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 11, weight: .regular),
                    .foregroundColor: UIColor.darkGray
                ]

                let paragraphs = data.narrative.components(separatedBy: "\n\n")
                for paragraph in paragraphs {
                    startNewPageIfNeeded(neededHeight: 80)
                    let paraText = paragraph as NSString
                    let textRect = CGRect(x: margin, y: currentY, width: contentWidth, height: 200)
                    let boundingRect = paraText.boundingRect(with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                                                              options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                              attributes: narrativeAttrs, context: nil)
                    paraText.draw(in: textRect, withAttributes: narrativeAttrs)
                    currentY += boundingRect.height + 12
                }
                currentY += 10
            }

            // MARK: - Symptom Frequency Table
            if !data.symptomFrequencies.isEmpty {
                startNewPageIfNeeded(neededHeight: 100)
                drawDivider(context: context.cgContext, y: currentY, margin: margin, width: contentWidth)
                currentY += 15

                let sectionAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
                    .foregroundColor: UIColor.black
                ]
                ("Symptom Frequency" as NSString).draw(at: CGPoint(x: margin, y: currentY), withAttributes: sectionAttrs)
                currentY += 28

                // Table header
                let headerAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 11, weight: .semibold),
                    .foregroundColor: UIColor.black
                ]
                let rowAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 11, weight: .regular),
                    .foregroundColor: UIColor.darkGray
                ]

                ("Symptom" as NSString).draw(at: CGPoint(x: margin + 10, y: currentY), withAttributes: headerAttrs)
                ("Count" as NSString).draw(at: CGPoint(x: margin + 250, y: currentY), withAttributes: headerAttrs)
                ("Avg Severity" as NSString).draw(at: CGPoint(x: margin + 350, y: currentY), withAttributes: headerAttrs)
                currentY += 20

                for symptom in data.symptomFrequencies {
                    startNewPageIfNeeded(neededHeight: 20)
                    (symptom.type as NSString).draw(at: CGPoint(x: margin + 10, y: currentY), withAttributes: rowAttrs)
                    ("\(symptom.count)" as NSString).draw(at: CGPoint(x: margin + 250, y: currentY), withAttributes: rowAttrs)
                    ("\(String(format: "%.1f", symptom.avgSeverity * 10))/10" as NSString).draw(at: CGPoint(x: margin + 350, y: currentY), withAttributes: rowAttrs)
                    currentY += 18
                }
            }

            // Footer on last page
            drawFooter(context: context.cgContext, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin)
        }

        return pdfData
    }

    private static func drawDivider(context: CGContext, y: CGFloat, margin: CGFloat, width: CGFloat) {
        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(0.5)
        context.move(to: CGPoint(x: margin, y: y))
        context.addLine(to: CGPoint(x: margin + width, y: y))
        context.strokePath()
    }

    private static func drawFooter(context: CGContext, pageWidth: CGFloat, pageHeight: CGFloat, margin: CGFloat) {
        let footerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .regular),
            .foregroundColor: UIColor.gray
        ]
        let footer = Constants.Report.footer as NSString
        let footerSize = footer.size(withAttributes: footerAttrs)
        footer.draw(
            at: CGPoint(x: (pageWidth - footerSize.width) / 2, y: pageHeight - margin + 10),
            withAttributes: footerAttrs
        )
    }
}
