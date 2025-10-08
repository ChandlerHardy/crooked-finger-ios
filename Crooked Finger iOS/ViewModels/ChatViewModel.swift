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
    private var isInitialized = false

    private let client = GraphQLClient.shared
    private let imageService = ImageService.shared

    init() {
        // Empty init - load data lazily when needed
    }

    func initialize() async {
        guard !isInitialized else { return }
        isInitialized = true

        await loadConversations()
        if conversations.isEmpty {
            createNewConversation()
        } else {
            currentConversation = conversations.first
            if let conversationId = currentConversation?.backendId {
                await loadMessages(for: conversationId)
            } else {
                messages = currentConversation?.messages ?? []
            }
        }
    }

    // Load messages for a specific conversation from backend
    func loadMessages(for conversationId: Int) async {
        do {
            let variables: [String: Any] = [
                "conversationId": conversationId,
                "limit": 100
            ]

            let response: GetChatMessagesData = try await client.execute(
                query: GraphQLOperations.getChatMessages,
                variables: variables
            )

            // Convert backend messages to app model
            var loadedMessages: [ChatMessage] = []
            for msgResponse in response.chatMessages {
                // User message
                loadedMessages.append(ChatMessage(
                    type: .user,
                    content: msgResponse.message,
                    timestamp: ISO8601DateFormatter().date(from: msgResponse.createdAt) ?? Date()
                ))
                // AI response
                loadedMessages.append(ChatMessage(
                    type: .assistant,
                    content: msgResponse.response,
                    timestamp: ISO8601DateFormatter().date(from: msgResponse.createdAt) ?? Date()
                ))
            }

            messages = loadedMessages

            // Update currentConversation with loaded messages
            if let index = conversations.firstIndex(where: { $0.backendId == conversationId }) {
                conversations[index].messages = loadedMessages
            }

        } catch {
            print("❌ Error loading messages from backend: \(error)")
            // Fallback to conversation's cached messages
            messages = currentConversation?.messages ?? []
        }
    }

    // Send a message to the AI assistant
    func sendMessage(_ text: String, images: [UIImage] = []) async {
        // Convert images to base64 array for display
        var base64Images: [String]? = nil
        if !images.isEmpty {
            base64Images = images.compactMap { imageService.imageToBase64(image: $0) }
        }

        // Add user message with images
        let userMessage = ChatMessage(
            type: .user,
            content: text,
            timestamp: Date(),
            attachedImages: base64Images
        )
        messages.append(userMessage)

        isLoading = true
        errorMessage = nil

        do {
            // Ensure we have a backend conversation
            if currentConversation?.backendId == nil {
                await createBackendConversation()
            }

            // Convert images to JSON for backend if any
            var imageData: String? = nil
            if !images.isEmpty {
                imageData = imageService.imagesToJSON(images: images)
            }

            // Call GraphQL mutation with conversation_id
            var variables: [String: Any] = [
                "message": text,
                "context": "crochet_pattern_assistant"
            ]

            if let backendId = currentConversation?.backendId {
                variables["conversationId"] = backendId
            }

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
        // Delete from backend if it has a backend ID
        if let backendId = conversation.backendId {
            Task {
                await deleteBackendConversation(backendId)
            }
        }

        conversations.removeAll { $0.id == conversation.id }
        saveConversations()

        // If we deleted the current conversation, create a new one
        if currentConversation?.id == conversation.id {
            createNewConversation()
        }
    }

    // MARK: - Private Methods

    private func createBackendConversation() async {
        guard var current = currentConversation else { return }
        guard current.backendId == nil else { return } // Already has backend ID

        do {
            let variables: [String: Any] = [
                "input": [
                    "title": current.title
                ]
            ]

            let response: CreateConversationData = try await client.execute(
                query: GraphQLOperations.createConversation,
                variables: variables
            )

            // Update local conversation with backend ID
            current.backendId = response.createConversation.id
            currentConversation = current

            // Update in conversations list
            if let index = conversations.firstIndex(where: { $0.id == current.id }) {
                conversations[index] = current
            }
            saveConversations()

        } catch {
            print("Failed to create backend conversation: \(error)")
            errorMessage = "Failed to sync conversation"
        }
    }

    private func deleteBackendConversation(_ backendId: Int) async {
        do {
            let variables: [String: Any] = ["conversationId": backendId]
            let _: DeleteConversationData = try await client.execute(
                query: GraphQLOperations.deleteConversation,
                variables: variables
            )
        } catch {
            print("Failed to delete backend conversation: \(error)")
        }
    }

    private func saveCurrentConversation() {
        guard var current = currentConversation else { return }

        // Update conversation with current messages
        current.messages = messages
        current.updatedAt = Date()

        // Auto-generate title from first user message if still "New Chat"
        var titleChanged = false
        if current.title == "New Chat", let firstUserMessage = messages.first(where: { $0.type == .user }) {
            current.title = String(firstUserMessage.content.prefix(50))
            titleChanged = true
        }

        // Update in conversations list
        if let index = conversations.firstIndex(where: { $0.id == current.id }) {
            conversations[index] = current
        } else {
            conversations.insert(current, at: 0)
        }

        currentConversation = current
        saveConversations()

        // Update backend title if changed and we have a backend ID
        if titleChanged, let backendId = current.backendId {
            Task {
                await updateBackendConversationTitle(backendId, title: current.title)
            }
        }
    }

    private func updateBackendConversationTitle(_ backendId: Int, title: String) async {
        do {
            let variables: [String: Any] = [
                "conversationId": backendId,
                "input": ["title": title]
            ]
            let _: UpdateConversationData = try await client.execute(
                query: GraphQLOperations.updateConversation,
                variables: variables
            )
        } catch {
            print("Failed to update backend conversation title: \(error)")
        }
    }

    private func loadConversations() async {
        // Fetch conversations from backend
        do {
            let variables: [String: Any] = [
                "limit": 50
            ]

            let response: GetConversationsData = try await client.execute(
                query: GraphQLOperations.getConversations,
                variables: variables
            )

            // Convert backend conversations to app model
            conversations = response.conversations.map { conv in
                Conversation(
                    id: UUID().uuidString,
                    backendId: conv.id,
                    title: conv.title,
                    messages: [], // Load messages separately when conversation is selected
                    messageCount: conv.messageCount,
                    createdAt: ISO8601DateFormatter().date(from: conv.createdAt) ?? Date(),
                    updatedAt: ISO8601DateFormatter().date(from: conv.updatedAt) ?? Date()
                )
            }

            // Also save to UserDefaults as offline cache
            saveConversations()

        } catch {
            print("❌ Error loading conversations from backend: \(error)")
            // Fallback to UserDefaults if backend fails
            let data = await Task.detached {
                UserDefaults.standard.data(forKey: "conversations")
            }.value

            if let data = data,
               let decoded = try? JSONDecoder().decode([Conversation].self, from: data) {
                conversations = decoded
            }
        }
    }

    private func saveConversations() {
        // Perform UserDefaults I/O off main thread
        let conversationsToSave = conversations
        Task.detached {
            if let encoded = try? JSONEncoder().encode(conversationsToSave) {
                UserDefaults.standard.set(encoded, forKey: "conversations")
            }
        }
    }
}
