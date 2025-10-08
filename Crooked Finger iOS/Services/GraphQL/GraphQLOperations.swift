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

    static let getProjects = """
    query GetProjects {
        projects {
            id
            name
            patternText
            translatedText
            difficultyLevel
            estimatedTime
            yarnWeight
            hookSize
            notes
            imageData
            isCompleted
            userId
            createdAt
            updatedAt
        }
    }
    """

    static let getProject = """
    query GetProject($projectId: Int!) {
        project(projectId: $projectId) {
            id
            name
            patternText
            translatedText
            difficultyLevel
            estimatedTime
            yarnWeight
            hookSize
            notes
            imageData
            isCompleted
            userId
            createdAt
            updatedAt
        }
    }
    """

    // MARK: - Mutations

    static let chatWithAssistantEnhanced = """
    mutation ChatWithAssistantEnhanced($message: String!, $conversationId: Int, $context: String, $imageData: String) {
        chatWithAssistantEnhanced(message: $message, conversationId: $conversationId, context: $context, imageData: $imageData) {
            message
            diagramSvg
            diagramPng
            hasPattern
        }
    }
    """

    static let getConversations = """
    query GetConversations($limit: Int) {
        conversations(limit: $limit) {
            id
            title
            userId
            createdAt
            updatedAt
            messageCount
        }
    }
    """

    static let getConversation = """
    query GetConversation($conversationId: Int!) {
        conversation(conversationId: $conversationId) {
            id
            title
            userId
            createdAt
            updatedAt
            messageCount
        }
    }
    """

    static let createConversation = """
    mutation CreateConversation($input: CreateConversationInput!) {
        createConversation(input: $input) {
            id
            title
            userId
            createdAt
            updatedAt
            messageCount
        }
    }
    """

    static let updateConversation = """
    mutation UpdateConversation($conversationId: Int!, $input: UpdateConversationInput!) {
        updateConversation(conversationId: $conversationId, input: $input) {
            id
            title
            userId
            createdAt
            updatedAt
            messageCount
        }
    }
    """

    static let deleteConversation = """
    mutation DeleteConversation($conversationId: Int!) {
        deleteConversation(conversationId: $conversationId)
    }
    """

    static let getChatMessages = """
    query GetChatMessages($conversationId: Int, $limit: Int) {
        chatMessages(conversationId: $conversationId, limit: $limit) {
            id
            message
            response
            messageType
            conversationId
            projectId
            userId
            createdAt
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

    static let createProject = """
    mutation CreateProject($input: CreateProjectInput!) {
        createProject(input: $input) {
            id
            name
            patternText
            translatedText
            difficultyLevel
            estimatedTime
            yarnWeight
            hookSize
            notes
            imageData
            isCompleted
            userId
            createdAt
            updatedAt
        }
    }
    """

    static let updateProject = """
    mutation UpdateProject($projectId: Int!, $input: UpdateProjectInput!) {
        updateProject(projectId: $projectId, input: $input) {
            id
            name
            patternText
            translatedText
            difficultyLevel
            estimatedTime
            yarnWeight
            hookSize
            notes
            imageData
            isCompleted
            userId
            createdAt
            updatedAt
        }
    }
    """

    static let deleteProject = """
    mutation DeleteProject($projectId: Int!) {
        deleteProject(projectId: $projectId)
    }
    """

    static let register = """
    mutation Register($input: RegisterInput!) {
        register(input: $input) {
            user {
                id
                email
                isActive
                isVerified
                isAdmin
                createdAt
                updatedAt
                lastLogin
            }
            accessToken
            tokenType
        }
    }
    """

    static let login = """
    mutation Login($input: LoginInput!) {
        login(input: $input) {
            user {
                id
                email
                isActive
                isVerified
                isAdmin
                createdAt
                updatedAt
                lastLogin
            }
            accessToken
            tokenType
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

// MARK: - Project Response Types

struct GetProjectsData: Decodable {
    let projects: [CrochetProjectResponse]
}

struct GetProjectData: Decodable {
    let project: CrochetProjectResponse?
}

struct CreateProjectData: Decodable {
    let createProject: CrochetProjectResponse
}

struct UpdateProjectData: Decodable {
    let updateProject: CrochetProjectResponse
}

struct DeleteProjectData: Decodable {
    let deleteProject: Bool
}

struct CrochetProjectResponse: Decodable {
    let id: Int
    let name: String
    let patternText: String?
    let translatedText: String?
    let difficultyLevel: String?
    let estimatedTime: String?
    let yarnWeight: String?
    let hookSize: String?
    let notes: String?
    let imageData: String?
    let isCompleted: Bool
    let userId: Int
    let createdAt: String
    let updatedAt: String
}

// MARK: - Input Types

struct CreateProjectInput: Encodable {
    let name: String
    let patternText: String?
    let difficultyLevel: String?
    let estimatedTime: String?
    let yarnWeight: String?
    let hookSize: String?
    let notes: String?
    let imageData: String?
}

struct UpdateProjectInput: Encodable {
    let name: String?
    let patternText: String?
    let translatedText: String?
    let difficultyLevel: String?
    let estimatedTime: String?
    let yarnWeight: String?
    let hookSize: String?
    let notes: String?
    let imageData: String?
    let isCompleted: Bool?
}

// MARK: - Auth Response Types

struct RegisterData: Decodable {
    let register: AuthResponse
}

struct LoginData: Decodable {
    let login: AuthResponse
}

struct AuthResponse: Decodable {
    let user: UserResponse
    let accessToken: String
    let tokenType: String
}

struct UserResponse: Decodable {
    let id: Int
    let email: String
    let isActive: Bool
    let isVerified: Bool
    let isAdmin: Bool
    let createdAt: String
    let updatedAt: String
    let lastLogin: String?
}

// MARK: - Conversation Response Types

struct GetConversationsData: Decodable {
    let conversations: [ConversationResponse]
}

struct GetConversationData: Decodable {
    let conversation: ConversationResponse?
}

struct CreateConversationData: Decodable {
    let createConversation: ConversationResponse
}

struct UpdateConversationData: Decodable {
    let updateConversation: ConversationResponse
}

struct DeleteConversationData: Decodable {
    let deleteConversation: Bool
}

struct ConversationResponse: Decodable {
    let id: Int
    let title: String
    let userId: Int
    let createdAt: String
    let updatedAt: String
    let messageCount: Int
}

struct GetChatMessagesData: Decodable {
    let chatMessages: [ChatMessageResponse]
}

struct ChatMessageResponse: Decodable {
    let id: Int
    let message: String
    let response: String
    let messageType: String
    let conversationId: Int?
    let projectId: Int?
    let userId: Int
    let createdAt: String
}
