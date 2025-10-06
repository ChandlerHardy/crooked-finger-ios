//
//  PatternLibraryView.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import SwiftUI

struct PatternLibraryView: View {
    @State private var viewModel = PatternViewModel()
    @State private var searchText = ""
    @State private var showCreateSheet = false
    @State private var showYouTubeSheet = false
    @Environment(\.dismiss) var dismiss

    var filteredPatterns: [Pattern] {
        if searchText.isEmpty {
            return viewModel.patterns
        }
        return viewModel.patterns.filter { pattern in
            pattern.name.localizedCaseInsensitiveContains(searchText) ||
            pattern.description?.localizedCaseInsensitiveContains(searchText) ?? false
        }
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.patterns.isEmpty {
                // Initial loading state
                ProgressView("Loading patterns...")
                    .foregroundStyle(Color.appMuted)
            } else if filteredPatterns.isEmpty {
                if searchText.isEmpty {
                    // No patterns at all
                    EmptyStateView(
                        icon: "book.closed",
                        title: "No Patterns Yet",
                        message: "Save patterns from the chat, import from YouTube, or add them manually",
                        actionTitle: "Add Pattern",
                        action: {
                            showCreateSheet = true
                        }
                    )
                } else {
                    // No search results
                    EmptyStateView(
                        icon: "magnifyingglass",
                        title: "No Results",
                        message: "No patterns match '\(searchText)'. Try a different search term."
                    )
                }
            } else {
                List {
                    ForEach(filteredPatterns) { pattern in
                        ZStack {
                            PatternRow(pattern: pattern)
                            NavigationLink(destination: PatternDetailView(pattern: pattern, viewModel: viewModel)) {
                                EmptyView()
                            }
                            .opacity(0)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .refreshable {
                    await viewModel.fetchPatterns()
                }
            }
        }
        .background(Color.appBackground)
        .navigationTitle("Patterns")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search patterns")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showCreateSheet = true
                    } label: {
                        Label("Add Pattern Manually", systemImage: "plus")
                    }

                    Button {
                        showYouTubeSheet = true
                    } label: {
                        Label("Import from YouTube", systemImage: "play.rectangle")
                    }
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(Color.primaryBrown)
                }
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            CreatePatternSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showYouTubeSheet) {
            YouTubeTranscriptView(patternViewModel: viewModel)
        }
        .task {
            // Fetch patterns on view appear
            if viewModel.patterns.isEmpty {
                await viewModel.fetchPatterns()
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("Copy Error") {
                if let errorMessage = viewModel.errorMessage {
                    UIPasteboard.general.string = errorMessage
                }
                viewModel.errorMessage = nil
            }
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

// MARK: - Pattern Row
struct PatternRow: View {
    let pattern: Pattern

    var body: some View {
        HStack(spacing: 0) {
            // Thumbnail image or placeholder - full height
            if let firstImage = pattern.images.first,
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
                    Image(systemName: "book.fill")
                        .font(.largeTitle)
                        .foregroundStyle(Color.primaryBrown)
                }
                .frame(width: 160)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(pattern.name)
                    .font(.headline)
                    .foregroundStyle(Color.appText)
                    .lineLimit(3)

                if let description = pattern.description {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(Color.appMuted)
                        .lineLimit(2)
                }

                Spacer()

                HStack(spacing: 8) {
                    if let difficulty = pattern.difficulty {
                        Text(difficulty.rawValue.capitalized)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.primaryBrown.opacity(0.1))
                            .foregroundStyle(Color.primaryBrown)
                            .clipShape(Capsule())
                    }

                    ForEach(pattern.tags.prefix(2), id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .foregroundStyle(Color.appMuted)
                    }
                }
            }
            .padding(12)
            .frame(minHeight: 110)

            Spacer()

            if pattern.isFavorite {
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

// MARK: - Create Pattern Sheet
struct CreatePatternSheet: View {
    let viewModel: PatternViewModel
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var notation = ""
    @State private var instructions = ""
    @State private var difficulty: PatternDifficulty = .beginner
    @State private var materials = ""
    @State private var estimatedTime = ""
    @State private var isCreating = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)

                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(PatternDifficulty.allCases, id: \.self) { level in
                            Text(level.rawValue.capitalized).tag(level)
                        }
                    }
                } header: {
                    Text("Pattern Details")
                }

                Section {
                    TextEditor(text: $notation)
                        .frame(minHeight: 100)
                } header: {
                    Text("Notation")
                } footer: {
                    Text("Abbreviated pattern (e.g., 'Ch 4, 12 dc in ring, sl st')")
                }

                Section {
                    TextEditor(text: $instructions)
                        .frame(minHeight: 80)
                } header: {
                    Text("Instructions (Optional)")
                }

                Section {
                    TextField("Materials", text: $materials)
                    TextField("Estimated Time", text: $estimatedTime)
                } header: {
                    Text("Additional Info (Optional)")
                }
            }
            .navigationTitle("New Pattern")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            isCreating = true
                            let success = await viewModel.savePattern(
                                name: name,
                                notation: notation,
                                instructions: instructions.isEmpty ? nil : instructions,
                                difficulty: difficulty,
                                materials: materials.isEmpty ? nil : materials,
                                estimatedTime: estimatedTime.isEmpty ? nil : estimatedTime
                            )
                            isCreating = false
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .disabled(name.isEmpty || notation.isEmpty || isCreating)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PatternLibraryView()
    }
}
