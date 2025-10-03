//
//  Project.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import Foundation

enum ProjectStatus: String, Codable, CaseIterable {
    case planning
    case inProgress = "in-progress"
    case completed
}

struct Project: Identifiable, Codable {
    let id: String
    var name: String
    var description: String
    var pattern: String
    var status: ProjectStatus
    var difficulty: PatternDifficulty
    var tags: [String]
    var images: [String]
    var notes: String?
    var createdAt: Date
    var updatedAt: Date
    var isFavorite: Bool

    init(
        id: String = UUID().uuidString,
        name: String,
        description: String,
        pattern: String,
        status: ProjectStatus = .planning,
        difficulty: PatternDifficulty = .beginner,
        tags: [String] = [],
        images: [String] = [],
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.pattern = pattern
        self.status = status
        self.difficulty = difficulty
        self.tags = tags
        self.images = images
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isFavorite = isFavorite
    }
}

// MARK: - Mock Data
extension Project {
    static let mockProjects: [Project] = [
        Project(
            name: "Cozy Blanket",
            description: "A warm granny square blanket for winter evenings",
            pattern: "CLASSIC GRANNY SQUARE BLANKET\n\nMaterials:\n- Medium weight yarn (4) in 4 colors...",
            status: .inProgress,
            difficulty: .beginner,
            tags: ["blanket", "granny-square", "winter"],
            isFavorite: true
        ),
        Project(
            name: "Baby Booties",
            description: "Adorable booties for newborns",
            pattern: "BABY BOOTIES PATTERN\n\nSize: 0-3 months...",
            status: .completed,
            difficulty: .intermediate,
            tags: ["baby", "booties", "gift"]
        )
    ]
}
