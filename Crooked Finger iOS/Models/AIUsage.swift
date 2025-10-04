//
//  AIUsage.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/4/25.
//

import Foundation

// MARK: - AI Usage Helper Extensions

extension ModelUsageStats: Identifiable {
    var id: String { modelName }

    var displayName: String {
        modelName
            .replacingOccurrences(of: "gemini-", with: "")
            .replacingOccurrences(of: "-", with: " ")
            .split(separator: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
    }

    var priorityLabel: String {
        switch priority {
        case 1: return "Premium"
        case 2: return "Fast"
        case 3: return "Standard"
        case 4: return "Efficient"
        default: return "Unknown"
        }
    }
}
