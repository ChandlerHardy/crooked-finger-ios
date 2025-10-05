//
//  ChatViewModel.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import Foundation
import SwiftUI
import UIKit

@MainActor
@Observable
class ChatViewModel {
    var conversations: [Conversation] = []
    var currentConversation: Conversation?
    var messages: [ChatMessage] = []
    var isLoading = false
    var errorMessage: String?

    private let client = GraphQLClient.shared
    private let imageService = ImageService.shared

    init() {
        loadConversations()
        // Start with a new conversation if none exist
        if conversations.isEmpty {
            createNewConversation()
        } else {
            currentConversation = conversations.first
            messages = currentConversation?.messages ?? []
        }
    }

    // Send a message to the AI assistant
    func sendMessage(_ text: String, images: [UIImage] = []) async {
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
            // Convert images to base64 if any
            var imageData: String? = nil
            if !images.isEmpty {
                imageData = imageService.imagesToJSON(images: images)
            }

            // Call GraphQL mutation
            var variables: [String: Any] = [
                "message": text,
                "context": "crochet_pattern_assistant"
            ]

            if let imageData = imageData {
                variables["imageData"] = imageData
            }

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

        // Save conversation after each message
        saveCurrentConversation()
    }

    // Create a new conversation
    func createNewConversation() {
        // Save current conversation first
        if let current = currentConversation, !current.messages.isEmpty {
            saveCurrentConversation()
        }

        // Create new conversation with auto-generated title
        let newConversation = Conversation(
            title: "New Chat",
            messages: [],
            createdAt: Date(),
            updatedAt: Date()
        )

        currentConversation = newConversation
        messages = []
        conversations.insert(newConversation, at: 0)
        saveConversations()
    }

    // Load a specific conversation
    func loadConversation(_ conversation: Conversation) {
        // Save current conversation first
        if let current = currentConversation, current.id != conversation.id {
            saveCurrentConversation()
        }

        currentConversation = conversation
        messages = conversation.messages
    }

    // Delete a conversation
    func deleteConversation(_ conversation: Conversation) {
        conversations.removeAll { $0.id == conversation.id }
        saveConversations()

        // If we deleted the current conversation, create a new one
        if currentConversation?.id == conversation.id {
            createNewConversation()
        }
    }

    // MARK: - Private Methods

    private func saveCurrentConversation() {
        guard var current = currentConversation else { return }

        // Update conversation with current messages
        current.messages = messages
        current.updatedAt = Date()

        // Auto-generate title from first user message if still "New Chat"
        if current.title == "New Chat", let firstUserMessage = messages.first(where: { $0.type == .user }) {
            current.title = String(firstUserMessage.content.prefix(50))
        }

        // Update in conversations list
        if let index = conversations.firstIndex(where: { $0.id == current.id }) {
            conversations[index] = current
        } else {
            conversations.insert(current, at: 0)
        }

        currentConversation = current
        saveConversations()
    }

    private func loadConversations() {
        if let data = UserDefaults.standard.data(forKey: "conversations"),
           let decoded = try? JSONDecoder().decode([Conversation].self, from: data) {
            conversations = decoded
        }
    }

    private func saveConversations() {
        if let encoded = try? JSONEncoder().encode(conversations) {
            UserDefaults.standard.set(encoded, forKey: "conversations")
        }
    }
}
