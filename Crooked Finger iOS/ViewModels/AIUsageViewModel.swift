//
//  AIUsageViewModel.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/4/25.
//

import Foundation

@MainActor
@Observable
class AIUsageViewModel {
    var dashboard: AIUsageDashboardResponse?
    var isLoading = false
    var errorMessage: String?

    private let client = GraphQLClient.shared

    // Fetch AI usage dashboard data
    func fetchUsage() async {
        isLoading = true
        errorMessage = nil

        do {
            let response: AIUsageDashboardData = try await client.execute(
                query: GraphQLOperations.aiUsageDashboard
            )

            dashboard = response.aiUsageDashboard

        } catch {
            errorMessage = "Failed to load AI usage: \(error.localizedDescription)"
            print("❌ Error fetching AI usage: \(error)")
        }

        isLoading = false
    }

    // Calculate time until quota reset (midnight PST/PDT)
    func timeUntilReset() -> String {
        let now = Date()
        let calendar = Calendar.current

        // Determine PST/PDT offset
        let isDST = calendar.component(.month, from: now) >= 3 && calendar.component(.month, from: now) <= 10
        let timezoneOffset = isDST ? -7 : -8

        // Create midnight PST/PDT for tomorrow
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone(secondsFromGMT: timezoneOffset * 3600)

        guard let midnight = calendar.date(from: components) else {
            return "--h --m --s"
        }

        let tomorrow = calendar.date(byAdding: .day, value: 1, to: midnight) ?? midnight

        let timeInterval = tomorrow.timeIntervalSince(now)
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60

        return String(format: "%02dh %02dm %02ds", hours, minutes, seconds)
    }
}
