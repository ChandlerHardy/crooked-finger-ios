//
//  ChatViewModel.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import Foundation
import SwiftUI

@MainActor
@Observable
class ChatViewModel {
    var messages: [ChatMessage] = []
    var isLoading = false
    var errorMessage: String?

    private let client = GraphQLClient.shared

    // Send a message to the AI assistant
    func sendMessage(_ text: String) async {
        // Add user message
        let userMessage = ChatMessage(
            type: .user,
            content: text,
            timestamp: Date()
        )
        messages.append(userMessage)

        isLoading = true
        errorMessage = nil

        do {
            // Call GraphQL mutation
            let variables: [String: Any] = [
                "message": text,
                "context": "crochet_pattern_assistant"
            ]

            let response: ChatWithAssistantData = try await client.execute(
                query: GraphQLOperations.chatWithAssistantEnhanced,
                variables: variables
            )

            // Add AI response message
            let aiMessage = ChatMessage(
                type: .assistant,
                content: response.chatWithAssistantEnhanced.message,
                timestamp: Date(),
                isPattern: response.chatWithAssistantEnhanced.hasPattern,
                diagramSvg: response.chatWithAssistantEnhanced.diagramSvg,
                diagramPng: response.chatWithAssistantEnhanced.diagramPng
            )
            messages.append(aiMessage)

        } catch {
            errorMessage = error.localizedDescription

            // Add error message for user visibility
            let errorAIMessage = ChatMessage(
                type: .assistant,
                content: "Sorry, I'm having trouble responding right now. Please try again. (\(error.localizedDescription))",
                timestamp: Date()
            )
            messages.append(errorAIMessage)
        }

        isLoading = false
    }

    // Clear all messages (new conversation)
    func clearMessages() {
        messages = []
        errorMessage = nil
    }

    // Load conversation history (from local storage if needed)
    func loadConversation(_ conversation: Conversation) {
        messages = conversation.messages
    }
}
