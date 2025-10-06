//
//  String+Markdown.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/6/25.
//

import SwiftUI

extension String {
    /// Clean markdown symbols from text while preserving structure and readability
    var cleanedMarkdown: String {
        var cleaned = self.trimmingCharacters(in: .whitespacesAndNewlines)

        // Remove standalone ** at the beginning
        if cleaned.hasPrefix("**\n") {
            cleaned = String(cleaned.dropFirst(3))
        }

        // Remove heading markers (###, ##, #) but keep the text
        cleaned = cleaned.replacingOccurrences(of: "### **", with: "")
        cleaned = cleaned.replacingOccurrences(of: "### ", with: "")
        cleaned = cleaned.replacingOccurrences(of: "## **", with: "")
        cleaned = cleaned.replacingOccurrences(of: "## ", with: "")
        cleaned = cleaned.replacingOccurrences(of: "# **", with: "")
        cleaned = cleaned.replacingOccurrences(of: "# ", with: "")

        // Remove bold markers **
        cleaned = cleaned.replacingOccurrences(of: "**", with: "")

        // Remove italic markers * (but not bullet points at start of line)
        let lines = cleaned.components(separatedBy: .newlines)
        let processedLines = lines.map { line -> String in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            // Keep asterisks that are bullet points (at start with spaces after)
            if trimmed.hasPrefix("*   ") || trimmed.hasPrefix("* ") {
                return line
            }
            // Remove other asterisks (italic markers)
            return line.replacingOccurrences(of: "*", with: "")
        }
        cleaned = processedLines.joined(separator: "\n")

        // Remove backticks for code
        cleaned = cleaned.replacingOccurrences(of: "`", with: "")

        return cleaned
    }
}
