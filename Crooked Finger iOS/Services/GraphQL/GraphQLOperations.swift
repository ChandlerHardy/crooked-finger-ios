//
//  GraphQLOperations.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import Foundation

// MARK: - GraphQL Query/Mutation Strings

enum GraphQLOperations {
    // MARK: - Queries

    static let aiUsageDashboard = """
    query AIUsageDashboard {
        aiUsageDashboard {
            totalRequestsToday
            totalRemaining
            models {
                modelName
                currentUsage
                dailyLimit
                remaining
                percentageUsed
                priority
                useCase
                totalInputCharacters
                totalOutputCharacters
                totalInputTokens
                totalOutputTokens
            }
        }
    }
    """

    // MARK: - Mutations

    static let chatWithAssistantEnhanced = """
    mutation ChatWithAssistantEnhanced($message: String!, $context: String) {
        chatWithAssistantEnhanced(message: $message, context: $context) {
            message
            diagramSvg
            diagramPng
            hasPattern
        }
    }
    """

    static let fetchYoutubeTranscript = """
    mutation FetchYoutubeTranscript($videoUrl: String!, $languages: [String!]) {
        fetchYoutubeTranscript(videoUrl: $videoUrl, languages: $languages) {
            success
            videoId
            transcript
            wordCount
            language
            thumbnailUrl
            thumbnailUrlHq
            error
        }
    }
    """

    static let extractPatternFromTranscript = """
    mutation ExtractPatternFromTranscript($transcript: String!, $videoId: String, $thumbnailUrl: String) {
        extractPatternFromTranscript(transcript: $transcript, videoId: $videoId, thumbnailUrl: $thumbnailUrl) {
            success
            patternName
            patternNotation
            patternInstructions
            difficultyLevel
            materials
            estimatedTime
            videoId
            thumbnailUrl
            error
        }
    }
    """
}

// MARK: - Response Types

struct AIUsageDashboardData: Decodable {
    let aiUsageDashboard: AIUsageDashboardResponse
}

struct AIUsageDashboardResponse: Decodable {
    let totalRequestsToday: Int
    let totalRemaining: Int
    let models: [ModelUsageStats]
}

struct ModelUsageStats: Decodable {
    let modelName: String
    let currentUsage: Int
    let dailyLimit: Int
    let remaining: Int
    let percentageUsed: Float
    let priority: Int
    let useCase: String
    let totalInputCharacters: Int
    let totalOutputCharacters: Int
    let totalInputTokens: Int
    let totalOutputTokens: Int
}

struct ChatWithAssistantData: Decodable {
    let chatWithAssistantEnhanced: ChatResponse
}

struct ChatResponse: Decodable {
    let message: String
    let diagramSvg: String?
    let diagramPng: String?
    let hasPattern: Bool
}

struct FetchYoutubeTranscriptData: Decodable {
    let fetchYoutubeTranscript: YouTubeTranscriptResponse
}

struct YouTubeTranscriptResponse: Decodable {
    let success: Bool
    let videoId: String?
    let transcript: String?
    let wordCount: Int?
    let language: String?
    let thumbnailUrl: String?
    let thumbnailUrlHq: String?
    let error: String?
}

struct ExtractPatternData: Decodable {
    let extractPatternFromTranscript: ExtractedPatternResponse
}

struct ExtractedPatternResponse: Decodable {
    let success: Bool
    let patternName: String?
    let patternNotation: String?
    let patternInstructions: String?
    let difficultyLevel: String?
    let materials: String?
    let estimatedTime: String?
    let videoId: String?
    let thumbnailUrl: String?
    let error: String?
}
