//
//  PatternViewModel.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import Foundation
import UIKit

@MainActor
@Observable
class PatternViewModel {
    var patterns: [Pattern] = []
    var isLoading = false
    var errorMessage: String?

    private let client = GraphQLClient.shared
    private let imageService = ImageService.shared

    // MARK: - Fetch Patterns

    func fetchPatterns() async {
        isLoading = true
        errorMessage = nil

        do {
            let response: GetProjectsData = try await client.execute(
                query: GraphQLOperations.getProjects
            )

            // Filter for "pattern templates" - projects that haven't been started yet
            // These are reference patterns saved from chat/YouTube
            let patternProjects = response.projects.filter { project in
                project.isCompleted == false &&
                (project.notes?.isEmpty ?? true || project.notes == nil)
            }

            // Convert backend response to Pattern models
            patterns = patternProjects.map { projectResponse in
                // Parse imageData JSON into images array
                var images: [String] = []
                if let imageDataJSON = projectResponse.imageData,
                   let jsonData = imageDataJSON.data(using: .utf8),
                   let imageArray = try? JSONDecoder().decode([String].self, from: jsonData) {
                    images = imageArray
                }

                return Pattern(
                    id: UUID().uuidString,
                    name: projectResponse.name,
                    description: nil, // Patterns don't have descriptions
                    difficulty: mapDifficulty(projectResponse.difficultyLevel),
                    category: nil,
                    tags: [], // Backend doesn't have tags yet
                    notation: projectResponse.patternText ?? "",
                    instructions: projectResponse.translatedText,
                    materials: projectResponse.yarnWeight != nil ?
                        "Yarn: \(projectResponse.yarnWeight ?? ""), Hook: \(projectResponse.hookSize ?? "")" : nil,
                    estimatedTime: projectResponse.estimatedTime,
                    videoId: nil,
                    thumbnailUrl: nil,
                    images: images,
                    isFavorite: false,
                    views: 0,
                    downloads: 0,
                    createdAt: ISO8601DateFormatter().date(from: projectResponse.createdAt) ?? Date(),
                    backendId: projectResponse.id
                )
            }

        } catch {
            errorMessage = "Failed to load patterns: \(error.localizedDescription)"
            print("❌ Error fetching patterns: \(error)")
        }

        isLoading = false
    }

    // MARK: - Save Pattern

    func savePattern(
        name: String,
        notation: String,
        instructions: String?,
        difficulty: PatternDifficulty?,
        materials: String?,
        estimatedTime: String?,
        imageData: String? = nil
    ) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            // Convert single image to JSON array format if provided
            var imageDataJSON: String?
            if let imageData = imageData {
                let imageArray = [imageData]
                if let jsonData = try? JSONEncoder().encode(imageArray),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    imageDataJSON = jsonString
                }
            }

            let input: [String: Any?] = [
                "name": name,
                "patternText": notation,
                "translatedText": instructions,
                "difficultyLevel": difficulty?.rawValue,
                "estimatedTime": estimatedTime,
                "yarnWeight": materials,
                "hookSize": nil,
                "notes": nil,
                "imageData": imageDataJSON
            ]

            print("💾 Saving pattern with:")
            print("  - notation: \(notation.prefix(100))")
            print("  - instructions: \(instructions?.prefix(100) ?? "nil")")
            print("  - imageData: \(imageDataJSON != nil ? "present" : "nil")")

            let variables: [String: Any] = [
                "input": input
            ]

            let response: CreateProjectData = try await client.execute(
                query: GraphQLOperations.createProject,
                variables: variables
            )

            print("📋 Backend response:")
            print("  - patternText: \(response.createProject.patternText?.prefix(100) ?? "nil")")
            print("  - translatedText: \(response.createProject.translatedText?.prefix(100) ?? "nil")")
            print("  - imageData: \(response.createProject.imageData != nil ? "present" : "nil")")

            // Parse imageData JSON into images array
            var images: [String] = []
            if let imageDataJSON = response.createProject.imageData,
               let jsonData = imageDataJSON.data(using: .utf8),
               let imageArray = try? JSONDecoder().decode([String].self, from: jsonData) {
                images = imageArray
                print("✅ Saved pattern with \(images.count) image(s)")
            } else {
                print("⚠️ No images in response")
            }

            // Add new pattern to local list
            let newPattern = Pattern(
                id: UUID().uuidString,
                name: response.createProject.name,
                description: nil, // Patterns don't have descriptions (that's for display in UI)
                difficulty: mapDifficulty(response.createProject.difficultyLevel),
                notation: response.createProject.patternText ?? "",
                instructions: response.createProject.translatedText, // Instructions from backend
                materials: response.createProject.yarnWeight,
                estimatedTime: response.createProject.estimatedTime,
                images: images,
                createdAt: ISO8601DateFormatter().date(from: response.createProject.createdAt) ?? Date(),
                backendId: response.createProject.id
            )

            patterns.insert(newPattern, at: 0)
            isLoading = false
            return true

        } catch {
            let detailedError = """
            Failed to save pattern!

            Error: \(error.localizedDescription)

            Full error: \(error)
            """
            errorMessage = detailedError
            print("❌ Error saving pattern: \(error)")
            if let graphQLError = error as? GraphQLError {
                print("   GraphQL Error details: \(graphQLError.errorDescription ?? "unknown")")
            }
            isLoading = false
            return false
        }
    }

    // MARK: - Update Pattern

    func updatePattern(
        patternId: Int,
        patternText: String? = nil,
        translatedText: String? = nil,
        images: [UIImage]? = nil
    ) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            var inputDict: [String: Any] = [:]

            if let patternText = patternText {
                inputDict["patternText"] = patternText
            }

            if let translatedText = translatedText {
                inputDict["translatedText"] = translatedText
            }

            if let images = images {
                // Convert images to JSON
                let imageDataJSON = imageService.imagesToJSON(images: images)
                inputDict["imageData"] = imageDataJSON
            }

            let variables: [String: Any] = [
                "projectId": patternId,
                "input": inputDict
            ]

            let response: UpdateProjectData = try await client.execute(
                query: GraphQLOperations.updateProject,
                variables: variables
            )

            // Update local pattern
            if let index = patterns.firstIndex(where: { $0.backendId == patternId }) {
                // Parse imageData JSON
                var images: [String] = []
                if let imageDataJSON = response.updateProject.imageData,
                   let jsonData = imageDataJSON.data(using: .utf8),
                   let imageArray = try? JSONDecoder().decode([String].self, from: jsonData) {
                    images = imageArray
                }

                patterns[index] = Pattern(
                    id: patterns[index].id,
                    name: response.updateProject.name,
                    description: response.updateProject.translatedText,
                    difficulty: mapDifficulty(response.updateProject.difficultyLevel),
                    notation: response.updateProject.patternText ?? "",
                    instructions: response.updateProject.translatedText,
                    materials: response.updateProject.yarnWeight,
                    estimatedTime: response.updateProject.estimatedTime,
                    images: images,
                    isFavorite: patterns[index].isFavorite,
                    createdAt: patterns[index].createdAt,
                    backendId: response.updateProject.id
                )
            }

            isLoading = false
            return true

        } catch {
            errorMessage = "Failed to update pattern: \(error.localizedDescription)"
            print("❌ Error updating pattern: \(error)")
            isLoading = false
            return false
        }
    }

    // MARK: - Delete Pattern

    func deletePattern(patternId: Int) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let variables: [String: Any] = [
                "projectId": patternId
            ]

            let response: DeleteProjectData = try await client.execute(
                query: GraphQLOperations.deleteProject,
                variables: variables
            )

            if response.deleteProject {
                // Remove from local list
                patterns.removeAll { $0.backendId == patternId }
                isLoading = false
                return true
            } else {
                errorMessage = "Failed to delete pattern"
                isLoading = false
                return false
            }

        } catch {
            errorMessage = "Failed to delete pattern: \(error.localizedDescription)"
            print("❌ Error deleting pattern: \(error)")
            isLoading = false
            return false
        }
    }

    // MARK: - Create Project from Pattern

    func createProjectFromPattern(_ pattern: Pattern, projectName: String? = nil) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            // Duplicate the pattern as a new project with notes to mark it as active
            let input: [String: Any?] = [
                "name": projectName ?? "\(pattern.name) - My Project",
                "patternText": pattern.notation,
                "difficultyLevel": pattern.difficulty?.rawValue,
                "estimatedTime": pattern.estimatedTime,
                "yarnWeight": pattern.materials,
                "hookSize": nil,
                "notes": "Created from pattern: \(pattern.name)"
            ]

            let variables: [String: Any] = [
                "input": input
            ]

            let _: CreateProjectData = try await client.execute(
                query: GraphQLOperations.createProject,
                variables: variables
            )

            isLoading = false
            return true

        } catch {
            errorMessage = "Failed to create project from pattern: \(error.localizedDescription)"
            print("❌ Error creating project from pattern: \(error)")
            isLoading = false
            return false
        }
    }

    // MARK: - Helper Methods

    private func mapDifficulty(_ level: String?) -> PatternDifficulty {
        guard let level = level?.lowercased() else { return .beginner }

        switch level {
        case "beginner":
            return .beginner
        case "intermediate":
            return .intermediate
        case "advanced":
            return .advanced
        default:
            return .beginner
        }
    }
}
