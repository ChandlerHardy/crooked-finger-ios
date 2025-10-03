//
//  ProjectsView.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import SwiftUI

struct ProjectsView: View {
    @State private var projects: [Project] = Project.mockProjects
    @State private var searchText = ""

    var filteredProjects: [Project] {
        if searchText.isEmpty {
            return projects
        }
        return projects.filter { project in
            project.name.localizedCaseInsensitiveContains(searchText) ||
            project.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        Group {
            if filteredProjects.isEmpty {
                if searchText.isEmpty {
                    // No projects at all
                    EmptyStateView(
                        icon: "folder.badge.plus",
                        title: "No Projects Yet",
                        message: "Start your first crochet project and track your progress",
                        actionTitle: "Create Project",
                        action: {
                            // TODO: Show create project sheet
                        }
                    )
                } else {
                    // No search results
                    EmptyStateView(
                        icon: "magnifyingglass",
                        title: "No Results",
                        message: "No projects match '\(searchText)'. Try a different search term."
                    )
                }
            } else {
                List {
                    ForEach(filteredProjects) { project in
                        NavigationLink {
                            ProjectDetailView(project: project)
                        } label: {
                            ProjectRow(project: project)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .refreshable {
                    // TODO: Refresh projects from backend
                }
            }
        }
        .background(Color.appBackground)
        .navigationTitle("Projects")
        .searchable(text: $searchText, prompt: "Search projects")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // Add project
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(Color.primaryBrown)
                }
            }
        }
    }
}

// MARK: - Project Row
struct ProjectRow: View {
    let project: Project

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "folder.fill")
                .font(.title2)
                .foregroundStyle(Color.primaryBrown)
                .frame(width: 44, height: 44)
                .background(Color.primaryBrown.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(project.name)
                    .font(.headline)
                    .foregroundStyle(Color.appText)

                Text(project.description)
                    .font(.caption)
                    .foregroundStyle(Color.appMuted)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    StatusBadge(status: project.status)

                    Text(project.difficulty.rawValue.capitalized)
                        .font(.caption2)
                        .foregroundStyle(Color.appMuted)
                }
            }

            Spacer()

            if project.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appBorder, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

#Preview {
    NavigationStack {
        ProjectsView()
    }
}
