//
//  Conversation.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import Foundation

struct Conversation: Identifiable, Codable {
    let id: String
    var title: String
    var messages: [ChatMessage]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        title: String,
        messages: [ChatMessage] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Mock Data
extension Conversation {
    static let mockConversations: [Conversation] = [
        Conversation(
            title: "What does sc2tog mean?",
            messages: [
                ChatMessage(type: .user, content: "What does sc2tog mean?"),
                ChatMessage(type: .assistant, content: "'sc2tog' means 'single crochet 2 together' - it's a decrease stitch that combines two stitches into one.", isPattern: true)
            ]
        )
    ]
}
