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

        let success = await patternViewModel.savePattern(
            name: pattern.patternName ?? "YouTube Pattern",
            notation: pattern.patternNotation ?? "",
            instructions: pattern.patternInstructions,
            difficulty: mapDifficulty(pattern.difficultyLevel),
            materials: pattern.materials,
            estimatedTime: pattern.estimatedTime
        )

        return success
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
