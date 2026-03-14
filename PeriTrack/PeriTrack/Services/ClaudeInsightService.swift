import Foundation

actor ClaudeInsightService {
    static let shared = ClaudeInsightService()

    struct InsightResponse {
        let dashboardCards: [InsightCard]
        let reportNarrative: String
    }

    struct InsightCard: Identifiable {
        let id = UUID()
        let title: String
        let body: String
        let category: String
    }

    func generateInsights(
        correlations: [CorrelationResult],
        cycleLengths: [Int],
        symptomSummary: [(type: String, avgSeverity: Double, count: Int)],
        dateRange: String
    ) async throws -> InsightResponse {
        let prompt = buildPrompt(
            correlations: correlations,
            cycleLengths: cycleLengths,
            symptomSummary: symptomSummary,
            dateRange: dateRange
        )

        let responseText = try await callClaudeAPI(prompt: prompt)
        return parseResponse(responseText)
    }

    private func buildPrompt(
        correlations: [CorrelationResult],
        cycleLengths: [Int],
        symptomSummary: [(type: String, avgSeverity: Double, count: Int)],
        dateRange: String
    ) -> String {
        var context = """
        You are a health data analyst helping a patient understand their perimenopause-related health patterns.
        The patient will use this information to advocate for themselves during a clinical visit.

        Data period: \(dateRange)

        """

        // Cycle data
        if !cycleLengths.isEmpty {
            let avg = Double(cycleLengths.reduce(0, +)) / Double(cycleLengths.count)
            let sorted = cycleLengths.sorted()
            let range = (sorted.first ?? 0, sorted.last ?? 0)
            context += """
            CYCLE DATA:
            - Number of cycles tracked: \(cycleLengths.count)
            - Average cycle length: \(String(format: "%.1f", avg)) days
            - Range: \(range.0)-\(range.1) days
            - Individual lengths: \(cycleLengths.map { "\($0)" }.joined(separator: ", ")) days

            """
        }

        // Correlations
        if !correlations.isEmpty {
            context += "DETECTED CORRELATIONS:\n"
            for c in correlations.prefix(10) {
                context += "- \(c.series1Label) vs \(c.series2Label): r=\(String(format: "%.3f", c.coefficient)), lag=\(c.lagDays) days, n=\(c.dataPointCount)\n"
            }
            context += "\n"
        }

        // Symptoms
        if !symptomSummary.isEmpty {
            context += "MANUALLY LOGGED SYMPTOMS:\n"
            for s in symptomSummary {
                context += "- \(s.type): logged \(s.count) times, avg severity \(String(format: "%.1f", s.avgSeverity * 10))/10\n"
            }
            context += "\n"
        }

        context += """
        Please respond in this exact JSON format:
        {
          "cards": [
            {"title": "short title", "body": "2-3 sentence insight", "category": "category name"}
          ],
          "narrative": "A 3-5 paragraph clinician-ready narrative summarizing the key findings, patterns, and what the patient might want to discuss with their healthcare provider. Use specific numbers from the data. Be factual but empathetic."
        }

        Generate 3-5 insight cards and a comprehensive narrative. Focus on:
        1. Cycle regularity/irregularity patterns
        2. Cross-symptom correlations (especially with lag patterns)
        3. Symptom severity trends
        4. Actionable discussion points for the clinician visit
        """

        return context
    }

    private func callClaudeAPI(prompt: String) async throws -> String {
        let url = URL(string: Constants.Claude.apiURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Constants.Claude.apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue(Constants.Claude.apiVersion, forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": Constants.Claude.model,
            "max_tokens": 2048,
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ClaudeError.apiError("API returned non-200 status")
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let firstContent = content.first,
              let text = firstContent["text"] as? String else {
            throw ClaudeError.parseError("Could not parse API response")
        }

        return text
    }

    private func parseResponse(_ text: String) -> InsightResponse {
        // Try to parse JSON response
        if let data = text.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {

            var cards: [InsightCard] = []
            if let cardsJSON = json["cards"] as? [[String: String]] {
                cards = cardsJSON.map { card in
                    InsightCard(
                        title: card["title"] ?? "Insight",
                        body: card["body"] ?? "",
                        category: card["category"] ?? "General"
                    )
                }
            }

            let narrative = json["narrative"] as? String ?? text

            return InsightResponse(dashboardCards: cards, reportNarrative: narrative)
        }

        // Fallback: treat entire response as narrative
        return InsightResponse(
            dashboardCards: [InsightCard(title: "Health Pattern Analysis", body: text.prefix(200) + "...", category: "General")],
            reportNarrative: text
        )
    }

    /// Fallback template-based insights when API is unavailable
    static func templateInsights(
        correlations: [CorrelationResult],
        cycleLengths: [Int]
    ) -> InsightResponse {
        var cards: [InsightCard] = []

        // Cycle insight
        if !cycleLengths.isEmpty {
            let avg = Double(cycleLengths.reduce(0, +)) / Double(cycleLengths.count)
            let variability = cycleLengths.count > 1 ?
                cycleLengths.map { abs(Double($0) - avg) }.reduce(0, +) / Double(cycleLengths.count) : 0

            let regularity = variability < 3 ? "relatively regular" : variability < 7 ? "moderately variable" : "highly variable"
            cards.append(InsightCard(
                title: "Cycle Pattern",
                body: "Your cycles average \(String(format: "%.0f", avg)) days and are \(regularity) (±\(String(format: "%.1f", variability)) days). Perimenopause commonly increases cycle variability.",
                category: "Cycles"
            ))
        }

        // Correlation insights
        for correlation in correlations.prefix(3) {
            cards.append(InsightCard(
                title: "\(correlation.series1Label) & \(correlation.series2Label)",
                body: correlation.summaryText,
                category: "Correlation"
            ))
        }

        let narrative = cards.map(\.body).joined(separator: "\n\n")

        return InsightResponse(dashboardCards: cards, reportNarrative: narrative)
    }

    enum ClaudeError: LocalizedError {
        case apiError(String)
        case parseError(String)

        var errorDescription: String? {
            switch self {
            case .apiError(let msg): return "Claude API Error: \(msg)"
            case .parseError(let msg): return "Parse Error: \(msg)"
            }
        }
    }
}
