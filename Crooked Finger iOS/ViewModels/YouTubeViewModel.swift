//
//  YouTubeViewModel.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/5/25.
//

import Foundation

@MainActor
@Observable
class YouTubeViewModel {
    var isLoadingTranscript = false
    var isExtractingPattern = false
    var errorMessage: String?
    var transcriptResult: YouTubeTranscriptResponse?
    var extractedPattern: ExtractedPatternResponse?

    private let client = GraphQLClient.shared

    // MARK: - Fetch Transcript

    func fetchTranscript(videoUrl: String) async {
        guard !videoUrl.isEmpty else {
            errorMessage = "Please enter a YouTube URL"
            return
        }

        isLoadingTranscript = true
        errorMessage = nil
        transcriptResult = nil
        extractedPattern = nil

        do {
            let variables: [String: Any] = [
                "videoUrl": videoUrl,
                "languages": ["en"]
            ]

            print("🎬 Fetching YouTube transcript for: \(videoUrl)")
            print("📝 Variables: \(variables)")

            let response: FetchYoutubeTranscriptData = try await client.execute(
                query: GraphQLOperations.fetchYoutubeTranscript,
                variables: variables
            )

            print("✅ Received response: success=\(response.fetchYoutubeTranscript.success)")

            if response.fetchYoutubeTranscript.success {
                print("✅ Transcript fetched successfully! Video ID: \(response.fetchYoutubeTranscript.videoId ?? "unknown")")
                transcriptResult = response.fetchYoutubeTranscript
            } else {
                let error = response.fetchYoutubeTranscript.error ?? "Failed to fetch transcript"
                print("❌ YouTube service returned error: \(error)")
                errorMessage = error
            }
        } catch {
            let fullError = "Network error: \(error.localizedDescription)\n\nFull error: \(error)"
            print("❌ Error fetching transcript: \(fullError)")
            errorMessage = fullError
        }

        isLoadingTranscript = false
    }

    // MARK: - Extract Pattern

    func extractPattern() async {
        guard let transcript = transcriptResult?.transcript else {
            errorMessage = "Please fetch a transcript first"
            return
        }

        isExtractingPattern = true
        errorMessage = nil
        extractedPattern = nil

        do {
            let variables: [String: Any] = [
                "transcript": transcript,
                "videoId": transcriptResult?.videoId as Any,
                "thumbnailUrl": transcriptResult?.thumbnailUrl as Any
            ]

            let response: ExtractPatternData = try await client.execute(
                query: GraphQLOperations.extractPatternFromTranscript,
                variables: variables
            )

            if response.extractPatternFromTranscript.success {
                extractedPattern = response.extractPatternFromTranscript
            } else {
                errorMessage = response.extractPatternFromTranscript.error ?? "Failed to extract pattern"
            }
        } catch {
            errorMessage = "Network error: \(error.localizedDescription)"
            print("❌ Error extracting pattern: \(error)")
        }

        isExtractingPattern = false
    }

    // MARK: - Save Pattern to Library

    func savePatternToLibrary(patternViewModel: PatternViewModel) async -> Bool {
        guard let pattern = extractedPattern else { return false }

        // Download and convert thumbnail to base64 if available
        var thumbnailBase64: String?
        if let thumbnailUrl = transcriptResult?.thumbnailUrl,
           let url = URL(string: thumbnailUrl) {
            print("📥 Downloading thumbnail from: \(thumbnailUrl)")
            thumbnailBase64 = await downloadImageAsBase64(url: url)
            if let thumbData = thumbnailBase64 {
                print("✅ Thumbnail downloaded successfully (\(thumbData.count) chars)")
            } else {
                print("❌ Failed to download thumbnail")
            }
        } else {
            print("⚠️ No thumbnail URL available. transcriptResult: \(transcriptResult != nil), thumbnailUrl: \(transcriptResult?.thumbnailUrl ?? "nil")")
        }

        // Parse notation and instructions
        let (cleanedNotation, extractedInstructions) = parseNotationAndInstructions(
            notation: pattern.patternNotation,
            existingInstructions: pattern.patternInstructions
        )

        let success = await patternViewModel.savePattern(
            name: pattern.patternName ?? "YouTube Pattern",
            notation: cleanedNotation,
            instructions: extractedInstructions,
            difficulty: mapDifficulty(pattern.difficultyLevel),
            materials: pattern.materials,
            estimatedTime: pattern.estimatedTime,
            imageData: thumbnailBase64
        )

        return success
    }

    /// Parse pattern notation and extract instructions section if present
    /// - Parameters:
    ///   - notation: The pattern notation text
    ///   - existingInstructions: Existing instructions from the pattern
    /// - Returns: Tuple of (cleaned notation, combined instructions)
    private func parseNotationAndInstructions(notation: String?, existingInstructions: String?) -> (String, String?) {
        guard let notation = notation else {
            return ("", existingInstructions)
        }

        // Try to find "INSTRUCTIONS" with or without colon, optionally with newline after
        let patterns = [
            "INSTRUCTIONS:",
            "INSTRUCTIONS",
            "Instructions:",
            "Instructions"
        ]

        for pattern in patterns {
            if let instructionsRange = notation.range(of: pattern, options: .caseInsensitive) {
                // Split at "INSTRUCTIONS"
                let beforeInstructions = notation[..<instructionsRange.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines)
                var instructionsText = notation[instructionsRange.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)

                // Remove leading colon if present
                if instructionsText.hasPrefix(":") {
                    instructionsText = String(instructionsText.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
                }

                // Combine with existing instructions if any
                var combinedInstructions = instructionsText
                if let existing = existingInstructions, !existing.isEmpty {
                    combinedInstructions = existing + "\n\n" + instructionsText
                }

                print("✂️ Extracted instructions from notation using pattern '\(pattern)' (\(instructionsText.count) chars)")
                return (beforeInstructions, combinedInstructions)
            }
        }

        // No "INSTRUCTIONS" section found, return as-is
        return (notation, existingInstructions)
    }

    // MARK: - Image Download

    private func downloadImageAsBase64(url: URL) async -> String? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data.base64EncodedString()
        } catch {
            print("❌ Error downloading thumbnail: \(error)")
            return nil
        }
    }

    // MARK: - Helper Methods

    private func mapDifficulty(_ level: String?) -> PatternDifficulty? {
        guard let level = level?.lowercased() else { return nil }

        switch level {
        case "beginner":
            return .beginner
        case "intermediate":
            return .intermediate
        case "advanced":
            return .advanced
        default:
            return nil
        }
    }

    func reset() {
        transcriptResult = nil
        extractedPattern = nil
        errorMessage = nil
    }
}
