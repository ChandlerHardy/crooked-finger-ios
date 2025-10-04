//
//  ProjectDetailView.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import SwiftUI

struct ProjectDetailView: View {
    let project: Project
    let viewModel: ProjectViewModel
    @State private var isFavorite: Bool
    @State private var status: ProjectStatus
    @State private var showImagePicker = false
    @State private var selectedImages: [UIImage] = []
    @State private var projectImages: [String] = []
    @State private var showImageViewer = false
    @State private var selectedImageIndex = 0

    init(project: Project, viewModel: ProjectViewModel) {
        self.project = project
        self.viewModel = viewModel
        self._isFavorite = State(initialValue: project.isFavorite)
        self._status = State(initialValue: project.status)
        self._projectImages = State(initialValue: project.images)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                statusSection
                patternSection
                imageGallerySection
                notesSection
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("Project Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImages: $selectedImages, maxSelection: 10)
        }
        .fullScreenCover(isPresented: $showImageViewer) {
            Base64ImageViewer(images: projectImages, currentIndex: $selectedImageIndex)
        }
        .onChange(of: selectedImages) { _, newImages in
            if !newImages.isEmpty {
                uploadImages(newImages)
            }
        }
        .onAppear {
            // Refresh images from the latest project data in viewModel
            if let backendId = project.backendId,
               let updatedProject = viewModel.projects.first(where: { $0.backendId == backendId }) {
                projectImages = updatedProject.images
            }
        }
    }

    // MARK: - View Components

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(project.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appText)

                Text(project.description)
                    .font(.subheadline)
                    .foregroundStyle(Color.appMuted)
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
    }

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Status")
                .font(.headline)

            Picker("Status", selection: $status) {
                ForEach(ProjectStatus.allCases, id: \.self) { status in
                    Text(status.rawValue.capitalized).tag(status)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: status) { oldValue, newValue in
                // Update backend when status changes
                Task {
                    if let backendId = project.backendId {
                        _ = await viewModel.updateProject(
                            projectId: backendId,
                            isCompleted: newValue == .completed
                        )
                    }
                }
            }
        }
    }

    private var patternSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pattern")
                .font(.headline)

            Text(project.pattern)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var imageGallerySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Photos")
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

            if !projectImages.isEmpty {
                Base64ImageGallery(
                    images: projectImages,
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

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.headline)

            if let notes = project.notes {
                Text(notes)
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Text("No notes yet")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Image Methods

    private func uploadImages(_ images: [UIImage]) {
        Task {
            guard let backendId = project.backendId else { return }

            // Convert new images to base64
            let newBase64Images = images.compactMap { ImageService.shared.imageToBase64(image: $0) }

            // Append to existing images
            var allImages = projectImages
            allImages.append(contentsOf: newBase64Images)

            // Update backend
            let success = await viewModel.updateProject(
                projectId: backendId,
                images: images
            )

            if success {
                await MainActor.run {
                    projectImages = allImages
                    selectedImages = [] // Clear selected images
                }
            }
        }
    }

    private func deleteImage(at index: Int) {
        Task {
            guard let backendId = project.backendId else { return }

            // Remove image from array
            var updatedImages = projectImages
            updatedImages.remove(at: index)

            // Convert base64 strings back to UIImages for update
            let uiImages = updatedImages.compactMap { ImageService.shared.base64ToImage(base64String: $0) }

            // Update backend
            let success = await viewModel.updateProject(
                projectId: backendId,
                images: uiImages
            )

            if success {
                await MainActor.run {
                    projectImages = updatedImages
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProjectDetailView(project: Project.mockProjects[0], viewModel: ProjectViewModel())
    }
}
