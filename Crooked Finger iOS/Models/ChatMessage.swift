//
//  ChatMessage.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import Foundation

enum MessageType: String, Codable {
    case user
    case assistant
}

struct ChatMessage: Identifiable, Codable {
    let id: String
    let type: MessageType
    let content: String
    let timestamp: Date
    var isPattern: Bool
    var diagramSvg: String?
    var diagramPng: String?
    var attachedImages: [String]? // Base64 encoded images

    init(
        id: String = UUID().uuidString,
        type: MessageType,
        content: String,
        timestamp: Date = Date(),
        isPattern: Bool = false,
        diagramSvg: String? = nil,
        diagramPng: String? = nil,
        attachedImages: [String]? = nil
    ) {
        self.id = id
        self.type = type
        self.content = content
        self.timestamp = timestamp
        self.isPattern = isPattern
        self.diagramSvg = diagramSvg
        self.diagramPng = diagramPng
        self.attachedImages = attachedImages
    }
}
