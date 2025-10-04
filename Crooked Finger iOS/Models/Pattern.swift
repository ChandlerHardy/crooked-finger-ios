//
//  Pattern.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import Foundation

enum PatternDifficulty: String, Codable, CaseIterable {
    case beginner
    case intermediate
    case advanced
}

struct Pattern: Identifiable, Codable {
    let id: String
    var name: String
    var description: String?
    var difficulty: PatternDifficulty?
    var category: String?
    var tags: [String]
    var notation: String
    var instructions: String?
    var materials: String?
    var estimatedTime: String?
    var videoId: String?
    var thumbnailUrl: String?
    var images: [String]
    var isFavorite: Bool
    var views: Int
    var downloads: Int
    var createdAt: Date
    var backendId: Int? // ID from backend database

    init(
        id: String = UUID().uuidString,
        name: String,
        description: String? = nil,
        difficulty: PatternDifficulty? = .beginner,
        category: String? = nil,
        tags: [String] = [],
        notation: String,
        instructions: String? = nil,
        materials: String? = nil,
        estimatedTime: String? = nil,
        videoId: String? = nil,
        thumbnailUrl: String? = nil,
        images: [String] = [],
        isFavorite: Bool = false,
        views: Int = 0,
        downloads: Int = 0,
        createdAt: Date = Date(),
        backendId: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.difficulty = difficulty
        self.category = category
        self.tags = tags
        self.notation = notation
        self.instructions = instructions
        self.materials = materials
        self.estimatedTime = estimatedTime
        self.videoId = videoId
        self.thumbnailUrl = thumbnailUrl
        self.images = images
        self.isFavorite = isFavorite
        self.views = views
        self.downloads = downloads
        self.createdAt = createdAt
        self.backendId = backendId
    }
}

// MARK: - Mock Data
extension Pattern {
    static let mockPatterns: [Pattern] = [
        Pattern(
            name: "Classic Granny Square",
            description: "A timeless granny square pattern perfect for blankets",
            difficulty: .beginner,
            category: "Squares",
            tags: ["granny-square", "blanket", "beginner-friendly"],
            notation: "Ch 4, join with sl st to form ring. Ch 3 (counts as 1st dc), 2 dc in ring, ch 2...",
            materials: "Medium weight yarn (4), Size H/8 (5.0mm) hook",
            estimatedTime: "30 minutes",
            images: []
        ),
        Pattern(
            name: "Baby Booties",
            description: "Adorable booties for newborns",
            difficulty: .intermediate,
            category: "Baby",
            tags: ["baby", "booties", "gift"],
            notation: "Ch 15. Sc in 2nd ch from hook, sc in next 12 ch...",
            materials: "Light weight yarn (3), Size F/5 (3.75mm) hook",
            estimatedTime: "2 hours",
            images: []
        )
    ]
}
