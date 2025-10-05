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
    @State private var showImagePicker = false
    @State private var selectedImages: [UIImage] = []
    @State private var patternImages: [String] = []
    @State private var showImageViewer = false
    @State private var selectedImageIndex = 0
    @State private var isEditingNotation = false
    @State private var isEditingInstructions = false
    @State private var editedNotation: String
    @State private var editedInstructions: String
    @FocusState private var isNotationFocused: Bool
    @FocusState private var isInstructionsFocused: Bool

    init(pattern: Pattern, viewModel: PatternViewModel) {
        self.pattern = pattern
        self.viewModel = viewModel
        self._isFavorite = State(initialValue: pattern.isFavorite)
        self._patternImages = State(initialValue: pattern.images)
        self._editedNotation = State(initialValue: pattern.notation)
        self._editedInstructions = State(initialValue: pattern.instructions ?? "")
    }

    var body: some View {
        ZStack {
            // Tap area to dismiss keyboard
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    isNotationFocused = false
                    isInstructionsFocused = false
                }

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
                        HStack {
                            Text("Pattern Notation")
                                .font(.headline)

                            Spacer()

                            if isEditingNotation {
                                Button("Cancel") {
                                    editedNotation = pattern.notation
                                    isEditingNotation = false
                                }
                                .font(.subheadline)
                                .foregroundStyle(Color.appMuted)
                            }

                            Button(isEditingNotation ? "Save" : "Edit") {
                                if isEditingNotation {
                                    saveNotation()
                                }
                                isEditingNotation.toggle()
                            }
                            .font(.subheadline)
                            .foregroundStyle(Color.primaryBrown)
                        }

                        if isEditingNotation {
                            TextEditor(text: $editedNotation)
                                .font(.system(.body, design: .monospaced))
                                .frame(minHeight: 100)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .focused($isNotationFocused)
                        } else {
                            Text(pattern.notation)
                                .font(.system(.body, design: .monospaced))
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    // Instructions
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Instructions")
                                .font(.headline)

                            Spacer()

                            if isEditingInstructions {
                                Button("Cancel") {
                                    editedInstructions = pattern.instructions ?? ""
                                    isEditingInstructions = false
                                }
                                .font(.subheadline)
                                .foregroundStyle(Color.appMuted)
                            }

                            Button(isEditingInstructions ? "Save" : "Edit") {
                                if isEditingInstructions {
                                    saveInstructions()
                                }
                                isEditingInstructions.toggle()
                            }
                            .font(.subheadline)
                            .foregroundStyle(Color.primaryBrown)
                        }

                        if isEditingInstructions {
                            TextEditor(text: $editedInstructions)
                                .font(.system(.body, design: .monospaced))
                                .frame(minHeight: 150)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .focused($isInstructionsFocused)
                        } else {
                            Text(pattern.instructions?.isEmpty == false ? pattern.instructions! : "No instructions yet. Tap 'Edit' to add them.")
                                .font(.system(.body, design: .monospaced))
                                .foregroundStyle(pattern.instructions?.isEmpty == false ? Color.appText : Color.appMuted)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    // Image Gallery
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Diagrams & Photos")
                                .font(.headline)

                            Spacer()

                            Button {
                                showImagePicker = true
                            } label: {
                                Label("Add Photos", systemImage: "photo.badge.plus")
                                    .font(.subheadline)
                                    .foregroundColor(.primaryBrown)
                            }
                        }

                        if !patternImages.isEmpty {
                            Base64ImageGallery(
                                images: patternImages,
                                columns: 3,
                                onImageTap: { index in
                                    selectedImageIndex = index
                                    showImageViewer = true
                                },
                                onDeleteImage: { index in
                                    deleteImage(at: index)
                                }
                            )
                        } else {
                            Text("No photos yet")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding()
                .allowsHitTesting(true)
            }
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
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImages: $selectedImages, maxSelection: 10)
        }
        .fullScreenCover(isPresented: $showImageViewer) {
            Base64ImageViewer(images: patternImages, currentIndex: $selectedImageIndex)
        }
        .onChange(of: selectedImages) { _, newImages in
            if !newImages.isEmpty {
                uploadImages(newImages)
            }
        }
        .onAppear {
            // Refresh images from the latest pattern data in viewModel
            if let backendId = pattern.backendId,
               let updatedPattern = viewModel.patterns.first(where: { $0.backendId == backendId }) {
                patternImages = updatedPattern.images
            }
        }
    }

    // MARK: - Save Methods

    private func saveNotation() {
        Task {
            guard let backendId = pattern.backendId else { return }

            let success = await viewModel.updatePattern(
                patternId: backendId,
                patternText: editedNotation
            )

            if success {
                isEditingNotation = false
            }
        }
    }

    private func saveInstructions() {
        Task {
            guard let backendId = pattern.backendId else { return }

            let success = await viewModel.updatePattern(
                patternId: backendId,
                translatedText: editedInstructions
            )

            if success {
                isEditingInstructions = false
            }
        }
    }

    // MARK: - Image Methods

    private func uploadImages(_ images: [UIImage]) {
        Task {
            guard let backendId = pattern.backendId else { return }

            // Convert new images to base64
            let newBase64Images = images.compactMap { ImageService.shared.imageToBase64(image: $0) }

            // Append to existing images
            var allImages = patternImages
            allImages.append(contentsOf: newBase64Images)

            // Update backend - patterns use the same updateProject mutation
            let success = await viewModel.updatePattern(
                patternId: backendId,
                images: images
            )

            if success {
                await MainActor.run {
                    patternImages = allImages
                    selectedImages = []
                }
            }
        }
    }

    private func deleteImage(at index: Int) {
        Task {
            guard let backendId = pattern.backendId else { return }

            // Remove image from array
            var updatedImages = patternImages
            updatedImages.remove(at: index)

            // Convert base64 strings back to UIImages for update
            let uiImages = updatedImages.compactMap { ImageService.shared.base64ToImage(base64String: $0) }

            // Update backend
            let success = await viewModel.updatePattern(
                patternId: backendId,
                images: uiImages
            )

            if success {
                await MainActor.run {
                    patternImages = updatedImages
                }
            }
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
