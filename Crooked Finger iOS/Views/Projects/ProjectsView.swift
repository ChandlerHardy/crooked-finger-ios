//
//  ProjectsView.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import SwiftUI

struct ProjectsView: View {
    @State private var viewModel = ProjectViewModel()
    @State private var searchText = ""
    @State private var showCreateSheet = false

    var filteredProjects: [Project] {
        if searchText.isEmpty {
            return viewModel.projects
        }
        return viewModel.projects.filter { project in
            project.name.localizedCaseInsensitiveContains(searchText) ||
            project.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.projects.isEmpty {
                // Initial loading state
                ProgressView("Loading projects...")
                    .foregroundStyle(Color.appMuted)
            } else if filteredProjects.isEmpty {
                if searchText.isEmpty {
                    // No projects at all
                    EmptyStateView(
                        icon: "folder.badge.plus",
                        title: "No Projects Yet",
                        message: "Start your first crochet project and track your progress",
                        actionTitle: "Create Project",
                        action: {
                            showCreateSheet = true
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
                            ProjectDetailView(project: project, viewModel: viewModel)
                        } label: {
                            ProjectRow(project: project)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .refreshable {
                    await viewModel.fetchProjects()
                }
            }
        }
        .background(Color.appBackground)
        .navigationTitle("Projects")
        .searchable(text: $searchText, prompt: "Search projects")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showCreateSheet = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(Color.primaryBrown)
                }
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateProjectSheet(viewModel: viewModel)
        }
        .task {
            // Fetch projects on view appear
            if viewModel.projects.isEmpty {
                await viewModel.fetchProjects()
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
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

// MARK: - Create Project Sheet
struct CreateProjectSheet: View {
    let viewModel: ProjectViewModel
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var pattern = ""
    @State private var difficulty: PatternDifficulty = .beginner
    @State private var notes = ""
    @State private var isCreating = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)

                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(PatternDifficulty.allCases, id: \.self) { level in
                            Text(level.rawValue.capitalized).tag(level)
                        }
                    }
                } header: {
                    Text("Project Details")
                }

                Section {
                    TextEditor(text: $pattern)
                        .frame(minHeight: 100)
                } header: {
                    Text("Pattern")
                } footer: {
                    Text("The crochet pattern you'll be following")
                }

                Section {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                } header: {
                    Text("Notes (Optional)")
                }
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task {
                            isCreating = true
                            let success = await viewModel.createProject(
                                name: name,
                                pattern: pattern,
                                difficulty: difficulty,
                                notes: notes.isEmpty ? "New project" : notes
                            )
                            isCreating = false
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .disabled(name.isEmpty || pattern.isEmpty || isCreating)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProjectsView()
    }
}
