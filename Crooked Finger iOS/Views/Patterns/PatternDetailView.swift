//
//  PatternDetailView.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import SwiftUI

struct PatternDetailView: View {
    let pattern: Pattern
    let viewModel: PatternViewModel
    @State private var isFavorite: Bool
    @State private var showCreateProjectSheet = false

    init(pattern: Pattern, viewModel: PatternViewModel) {
        self.pattern = pattern
        self.viewModel = viewModel
        self._isFavorite = State(initialValue: pattern.isFavorite)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(pattern.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.appText)

                        if let description = pattern.description {
                            Text(description)
                                .font(.subheadline)
                                .foregroundStyle(Color.appMuted)
                        }
                    }

                    Spacer()

                    Button {
                        isFavorite.toggle()
                    } label: {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .foregroundStyle(.yellow)
                            .font(.title2)
                    }
                }

                // Metadata
                VStack(alignment: .leading, spacing: 12) {
                    if let difficulty = pattern.difficulty {
                        MetadataRow(label: "Difficulty", value: difficulty.rawValue.capitalized)
                    }

                    if let materials = pattern.materials {
                        MetadataRow(label: "Materials", value: materials)
                    }

                    if let estimatedTime = pattern.estimatedTime {
                        MetadataRow(label: "Time", value: estimatedTime)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Notation
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pattern Notation")
                        .font(.headline)

                    Text(pattern.notation)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Instructions
                if let instructions = pattern.instructions {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Instructions")
                            .font(.headline)

                        Text(instructions)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("Pattern Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showCreateProjectSheet = true
                } label: {
                    Label("Create Project", systemImage: "folder.badge.plus")
                        .foregroundStyle(Color.primaryBrown)
                }
            }
        }
        .sheet(isPresented: $showCreateProjectSheet) {
            CreateProjectFromPatternSheet(pattern: pattern, viewModel: viewModel)
        }
    }
}

// MARK: - Create Project Sheet
struct CreateProjectFromPatternSheet: View {
    let pattern: Pattern
    let viewModel: PatternViewModel
    @Environment(\.dismiss) var dismiss
    @State private var projectName: String = ""
    @State private var isCreating = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Project Name", text: $projectName)
                } header: {
                    Text("Create a new project from this pattern")
                } footer: {
                    Text("You'll be able to add notes, images, and track progress")
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pattern: \(pattern.name)")
                            .font(.headline)
                        if let difficulty = pattern.difficulty {
                            Text("Difficulty: \(difficulty.rawValue.capitalized)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
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
                            let success = await viewModel.createProjectFromPattern(
                                pattern,
                                projectName: projectName.isEmpty ? nil : projectName
                            )
                            isCreating = false
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .disabled(isCreating)
                }
            }
        }
    }
}

// MARK: - Metadata Row
struct MetadataRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
        }
    }
}

#Preview {
    NavigationStack {
        PatternDetailView(pattern: Pattern.mockPatterns[0], viewModel: PatternViewModel())
    }
}
