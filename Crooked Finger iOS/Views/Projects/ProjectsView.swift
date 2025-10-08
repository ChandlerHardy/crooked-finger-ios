//
//  ProjectsView.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import SwiftUI

struct ProjectsView: View {
    @State var viewModel: ProjectViewModel
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
                        ZStack {
                            ProjectRow(project: project)
                            NavigationLink(destination: ProjectDetailView(project: project, viewModel: viewModel)) {
                                EmptyView()
                            }
                            .opacity(0)
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
        .navigationBarTitleDisplayMode(.inline)
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
        HStack(spacing: 0) {
            // Thumbnail image or placeholder - full height
            if let firstImage = project.images.first,
               let imageData = Data(base64Encoded: firstImage),
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 160)
                    .clipped()
            } else {
                ZStack {
                    Color.primaryBrown.opacity(0.1)
                    Image(systemName: "folder.fill")
                        .font(.largeTitle)
                        .foregroundStyle(Color.primaryBrown)
                }
                .frame(width: 160)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(project.name)
                    .font(.headline)
                    .foregroundStyle(Color.appText)
                    .lineLimit(3)

                Text(project.description)
                    .font(.caption)
                    .foregroundStyle(Color.appMuted)
                    .lineLimit(2)

                Spacer()

                HStack(spacing: 8) {
                    StatusBadge(status: project.status)

                    Text(project.difficulty.rawValue.capitalized)
                        .font(.caption2)
                        .foregroundStyle(Color.appMuted)
                }
            }
            .padding(12)
            .frame(minHeight: 110)

            Spacer()

            if project.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .font(.caption)
                    .padding(.trailing, 12)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appBorder, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
    }
}

// MARK: - Create Project Sheet
struct CreateProjectSheet: View {
    let viewModel: ProjectViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab = 0
    @State private var name = ""
    @State private var description = ""
    @State private var pattern = ""
    @State private var difficulty: PatternDifficulty = .beginner
    @State private var notes = ""
    @State private var isCreating = false
    @State private var showPatternPicker = false
    @State private var patternViewModel = PatternViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Picker
                Picker("Source", selection: $selectedTab) {
                    Text("From Scratch").tag(0)
                    Text("From Pattern").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                if selectedTab == 0 {
                    manualEntryView
                } else {
                    patternLibraryView
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
                if selectedTab == 0 {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Create") {
                            Task {
                                await createProject()
                            }
                        }
                        .disabled(name.isEmpty || pattern.isEmpty || isCreating)
                    }
                }
            }
        }
    }

    private var manualEntryView: some View {
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
    }

    private var patternLibraryView: some View {
        Group {
            if patternViewModel.isLoading && patternViewModel.patterns.isEmpty {
                ProgressView("Loading patterns...")
                    .foregroundStyle(Color.appMuted)
            } else if patternViewModel.patterns.isEmpty {
                EmptyStateView(
                    icon: "doc.text",
                    title: "No Patterns Yet",
                    message: "Create some patterns first, then start projects from them"
                )
            } else {
                List {
                    ForEach(patternViewModel.patterns) { pattern in
                        Button {
                            createProjectFromPattern(pattern)
                        } label: {
                            PatternSelectionRow(pattern: pattern)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .background(Color.appBackground)
    }

    private func createProject() async {
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

    private func createProjectFromPattern(_ pattern: Pattern) {
        Task {
            isCreating = true
            let success = await viewModel.createProject(
                name: "\(pattern.name) - My Project",
                pattern: pattern.notation,
                difficulty: pattern.difficulty ?? .beginner,
                notes: "Started from pattern: \(pattern.name)"
            )
            isCreating = false
            if success {
                dismiss()
            }
        }
    }
}

// MARK: - Pattern Selection Row
struct PatternSelectionRow: View {
    let pattern: Pattern

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            if let firstImage = pattern.images.first,
               let imageData = Data(base64Encoded: firstImage),
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                ZStack {
                    Color.primaryBrown.opacity(0.1)
                    Image(systemName: "doc.text.fill")
                        .font(.title2)
                        .foregroundStyle(Color.primaryBrown)
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(pattern.name)
                    .font(.headline)
                    .foregroundStyle(Color.appText)
                    .lineLimit(2)

                if let difficulty = pattern.difficulty {
                    Text(difficulty.rawValue.capitalized)
                        .font(.caption)
                        .foregroundStyle(Color.appMuted)
                }

                if let materials = pattern.materials {
                    Text(materials)
                        .font(.caption2)
                        .foregroundStyle(Color.appMuted)
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Color.appMuted)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack {
        ProjectsView(viewModel: ProjectViewModel())
    }
}
