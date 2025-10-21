//
//  ProjectViewModel.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import Foundation
import UIKit

@MainActor
@Observable
class ProjectViewModel {
    var projects: [Project] = []
    var isLoading = false
    var errorMessage: String?

    private let client = GraphQLClient.shared
    private let imageService = ImageService.shared

    init() {
        Task {
            await fetchProjects()
        }
        
        // Listen for authentication state changes
        NotificationCenter.default.addObserver(
            forName: .authStateChanged,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let isAuthenticated = notification.object as? Bool, isAuthenticated {
                Task {
                    await self?.fetchProjects()
                }
            }
        }
    }

    // MARK: - Fetch Projects

    func fetchProjects() async {
        isLoading = true
        errorMessage = nil

        do {
            let response: GetProjectsData = try await client.execute(
                query: GraphQLOperations.getProjects
            )

            // Convert backend response to app models
            projects = response.projects.map { projectResponse in
                // Parse imageData JSON into images array
                var images: [String] = []
                if let imageDataJSON = projectResponse.imageData,
                   let jsonData = imageDataJSON.data(using: .utf8),
                   let imageArray = try? JSONDecoder().decode([String].self, from: jsonData) {
                    images = imageArray
                }

                return Project(
                    id: UUID(),
                    name: projectResponse.name,
                    description: projectResponse.notes ?? "",
                    pattern: projectResponse.patternText ?? "",
                    translatedInstructions: projectResponse.translatedText,
                    status: projectResponse.isCompleted ? .completed : .inProgress,
                    difficulty: mapDifficulty(projectResponse.difficultyLevel),
                    images: images,
                    notes: projectResponse.notes,
                    isFavorite: false, // Backend doesn't have favorite field
                    backendId: projectResponse.id
                )
            }

        } catch {
            errorMessage = "Failed to load projects: \(error.localizedDescription)"
            print("❌ Error fetching projects: \(error)")
        }

        isLoading = false
    }

    // MARK: - Create Project

    func createProject(
        name: String,
        pattern: String,
        difficulty: PatternDifficulty?,
        notes: String?,
        images: [UIImage] = []
    ) async -> Bool {
        isLoading = true
        errorMessage = nil

        // Debug: Check if we have auth token
        if let token = client.authToken {
            print("🔐 createProject - Auth token present: \(token.prefix(20))...")
        } else {
            print("❌ createProject - NO AUTH TOKEN!")
            errorMessage = "Not authenticated. Please login first."
            isLoading = false
            return false
        }

        do {
            // Convert images to JSON
            let imageDataJSON = images.isEmpty ? nil : imageService.imagesToJSON(images: images)

            let input: [String: Any?] = [
                "name": name,
                "patternText": pattern,
                "difficultyLevel": difficulty?.rawValue,
                "estimatedTime": nil,
                "yarnWeight": nil,
                "hookSize": nil,
                "notes": notes,
                "imageData": imageDataJSON
            ]

            let variables: [String: Any] = [
                "input": input
            ]

            let response: CreateProjectData = try await client.execute(
                query: GraphQLOperations.createProject,
                variables: variables
            )

            // Add new project to local list
            let newProject = Project(
                id: UUID(),
                name: response.createProject.name,
                description: response.createProject.notes ?? "",
                pattern: response.createProject.patternText ?? "",
                translatedInstructions: response.createProject.translatedText,
                status: .notStarted,
                difficulty: mapDifficulty(response.createProject.difficultyLevel),
                notes: response.createProject.notes,
                isFavorite: false,
                backendId: response.createProject.id
            )

            projects.insert(newProject, at: 0)
            isLoading = false
            return true

        } catch {
            errorMessage = "Failed to create project: \(error.localizedDescription)"
            print("❌ Error creating project: \(error)")
            isLoading = false
            return false
        }
    }

    // MARK: - Update Project

    func updateProject(
        projectId: Int,
        name: String? = nil,
        pattern: String? = nil,
        difficulty: PatternDifficulty? = nil,
        notes: String? = nil,
        images: [UIImage]? = nil,
        isCompleted: Bool? = nil
    ) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            var inputDict: [String: Any] = [:]
            if let name = name {
                inputDict["name"] = name
            }
            if let pattern = pattern {
                inputDict["patternText"] = pattern
            }
            if let difficulty = difficulty {
                inputDict["difficultyLevel"] = difficulty.rawValue
            }
            if let notes = notes {
                inputDict["notes"] = notes
            }
            if let images = images {
                // Convert images to JSON
                let imageDataJSON = imageService.imagesToJSON(images: images)
                inputDict["imageData"] = imageDataJSON
            }
            if let isCompleted = isCompleted {
                inputDict["isCompleted"] = isCompleted
            }

            let variables: [String: Any] = [
                "projectId": projectId,
                "input": inputDict
            ]

            let response: UpdateProjectData = try await client.execute(
                query: GraphQLOperations.updateProject,
                variables: variables
            )

            // Update local project
            if let index = projects.firstIndex(where: { $0.backendId == projectId }) {
                // Parse imageData JSON into images array
                var updatedImages: [String] = []
                if let imageDataJSON = response.updateProject.imageData,
                   let jsonData = imageDataJSON.data(using: .utf8),
                   let imageArray = try? JSONDecoder().decode([String].self, from: jsonData) {
                    updatedImages = imageArray
                }

                projects[index] = Project(
                    id: projects[index].id,
                    name: response.updateProject.name,
                    description: response.updateProject.notes ?? "",
                    pattern: response.updateProject.patternText ?? "",
                    translatedInstructions: response.updateProject.translatedText,
                    status: response.updateProject.isCompleted ? .completed : projects[index].status,
                    difficulty: mapDifficulty(response.updateProject.difficultyLevel),
                    images: updatedImages,
                    notes: response.updateProject.notes,
                    isFavorite: projects[index].isFavorite,
                    backendId: response.updateProject.id
                )
            }

            isLoading = false
            return true

        } catch {
            errorMessage = "Failed to update project: \(error.localizedDescription)"
            print("❌ Error updating project: \(error)")
            isLoading = false
            return false
        }
    }

    // MARK: - Delete Project

    func deleteProject(projectId: Int) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let variables: [String: Any] = [
                "projectId": projectId
            ]

            let response: DeleteProjectData = try await client.execute(
                query: GraphQLOperations.deleteProject,
                variables: variables
            )

            if response.deleteProject {
                // Remove from local list
                projects.removeAll { $0.backendId == projectId }
                isLoading = false
                return true
            } else {
                errorMessage = "Failed to delete project"
                isLoading = false
                return false
            }

        } catch {
            errorMessage = "Failed to delete project: \(error.localizedDescription)"
            print("❌ Error deleting project: \(error)")
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
    
    // MARK: - Refresh Methods
    
    func refreshProjects() async {
        await fetchProjects()
    }
}
