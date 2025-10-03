//
//  Theme.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import SwiftUI

// MARK: - App Theme Colors
// Matching the web app's warm, earthy crochet-inspired palette

extension Color {
    // Primary Colors
    static let primaryBrown = Color(hex: "#A47764")      // Warm brown for primary actions
    static let primaryText = Color(hex: "#3c2e26")       // Dark brown text
    static let primaryTextDark = Color(hex: "#f5f1ed")   // Light cream text (dark mode)

    // Background Colors
    static let backgroundLight = Color(hex: "#fdfcfb")   // Off-white background
    static let backgroundDark = Color(hex: "#1a1a1a")    // Dark background
    static let cardLight = Color(hex: "#ffffff")         // Card background light
    static let cardDark = Color(hex: "#2a2a2a")          // Card background dark

    // Secondary Colors
    static let secondaryLight = Color(hex: "#f5f1ed")    // Light cream
    static let secondaryDark = Color(hex: "#3a3a3a")     // Dark gray
    static let mutedLight = Color(hex: "#8b7355")        // Muted brown
    static let mutedDark = Color(hex: "#C4A484")         // Light tan

    // Accent Colors
    static let accentLight = Color(hex: "#e9e2dc")       // Very light cream
    static let accentDark = Color(hex: "#e9e2dc")        // Same in dark mode
    static let destructive = Color(hex: "#d4183d")       // Red for destructive actions

    // Border Colors
    static let borderLight = Color(hex: "#A47764").opacity(0.15)
    static let borderDark = Color(hex: "#A47764").opacity(0.3)

    // Adaptive colors that change with color scheme
    static var appBackground: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color.backgroundDark)
                : UIColor(Color.backgroundLight)
        })
    }

    static var appCard: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color.cardDark)
                : UIColor(Color.cardLight)
        })
    }

    static var appSecondary: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color.secondaryDark)
                : UIColor(Color.secondaryLight)
        })
    }

    static var appMuted: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color.mutedDark)
                : UIColor(Color.mutedLight)
        })
    }

    static var appBorder: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color.borderDark)
                : UIColor(Color.borderLight)
        })
    }

    static var appText: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color.primaryTextDark)
                : UIColor(Color.primaryText)
        })
    }
}

// MARK: - Hex Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
