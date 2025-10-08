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
    @State private var selectedTab = 0
    @State private var isEditingPattern = false
    @State private var editedPattern: String
    @State private var editedNotes: String
    @State private var projectChatViewModel: ChatViewModel?
    @State private var showDeleteAlert = false
    @State private var showNotation = true // Toggle between notation and instructions
    @Environment(\.dismiss) var dismiss
    @FocusState private var isPatternFocused: Bool
    @FocusState private var isNotesFocused: Bool

    init(project: Project, viewModel: ProjectViewModel) {
        self.project = project
        self.viewModel = viewModel
        self._isFavorite = State(initialValue: project.isFavorite)
        self._status = State(initialValue: project.status)
        self._projectImages = State(initialValue: project.images)
        self._editedPattern = State(initialValue: project.pattern)
        self._editedNotes = State(initialValue: project.notes ?? "")
    }

    var body: some View {
        ZStack {
            // Background color
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Hero Image - slide up when switching to chat
                if selectedTab != 2 && !projectImages.isEmpty {
                    TabView(selection: $selectedImageIndex) {
                        ForEach(Array(projectImages.enumerated()), id: \.offset) { index, base64String in
                            if let image = ImageService.shared.base64ToImage(base64String: base64String) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 250)
                                    .tag(index)
                                    .onTapGesture {
                                        showImageViewer = true
                                    }
                            }
                        }
                    }
                    .tabViewStyle(.page)
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    .frame(height: 250)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                // Header - slide up when switching to chat
                if selectedTab != 2 {
                    headerSection
                        .padding()
                        .padding(.top, projectImages.isEmpty ? 0 : 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                // Status Badge - slide up when switching to chat
                if selectedTab != 2 {
                    HStack {
                        StatusBadge(status: status)

                        Spacer()

                        Menu {
                            ForEach(ProjectStatus.allCases, id: \.self) { projectStatus in
                                Button {
                                    status = projectStatus
                                    updateStatus(projectStatus)
                                } label: {
                                    Label(projectStatus.rawValue.capitalized, systemImage: projectStatus == status ? "checkmark" : "")
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text("Change Status")
                                Image(systemName: "chevron.down")
                            }
                            .font(.subheadline)
                            .foregroundStyle(Color.primaryBrown)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                // Tab Picker - always visible
                Picker("View", selection: $selectedTab) {
                    Text("Pattern").tag(0)
                    Text("Images").tag(1)
                    Text("Chat").tag(2)
                    Text("Notes").tag(3)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)

                // Content area
                if selectedTab != 2 {
                    ScrollView {
                        Group {
                            switch selectedTab {
                            case 0:
                                patternTabContent
                            case 1:
                                imageTabContent
                            case 3:
                                notesTabContent
                            default:
                                patternTabContent
                            }
                        }
                    }
                    .transition(.opacity)
                } else {
                    chatTabContent
                        .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: selectedTab)
        .navigationTitle("Project Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
            }
        }
        .alert("Delete Project?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteProject()
            }
        } message: {
            Text("This project will be permanently deleted. This action cannot be undone.")
        }
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

            // Initialize project-specific chat
            initializeProjectChat()
        }
    }

    // MARK: - View Components

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(project.name.cleanedMarkdown)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appText)

                Text(project.description.cleanedMarkdown)
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

    private func updateStatus(_ newStatus: ProjectStatus) {
        Task {
            if let backendId = project.backendId {
                _ = await viewModel.updateProject(
                    projectId: backendId,
                    isCompleted: newStatus == .completed
                )
            }
        }
    }

    // MARK: - Tab Content

    private var patternTabContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Pattern")
                    .font(.headline)

                Spacer()

                if isEditingPattern {
                    Button("Cancel") {
                        editedPattern = project.pattern
                        isEditingPattern = false
                    }
                    .font(.subheadline)
                    .foregroundStyle(Color.appMuted)
                }

                Button(isEditingPattern ? "Save" : "Edit") {
                    if isEditingPattern {
                        savePattern()
                    }
                    isEditingPattern.toggle()
                }
                .font(.subheadline)
                .foregroundStyle(Color.primaryBrown)
            }
            .padding(.horizontal)

            // Toggle between Notation and Instructions
            if !isEditingPattern && project.translatedInstructions != nil {
                Picker("View Mode", selection: $showNotation) {
                    Text("Notation").tag(true)
                    Text("Instructions").tag(false)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
            }

            if isEditingPattern {
                TextEditor(text: $editedPattern)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 300)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    .focused($isPatternFocused)
            } else {
                let displayText = showNotation ? project.pattern : (project.translatedInstructions ?? project.pattern)

                if displayText.isEmpty {
                    Text("No pattern yet. Tap 'Edit' to add one.")
                        .font(.body)
                        .foregroundStyle(Color.appMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        if !showNotation {
                            HStack {
                                Image(systemName: "text.alignleft")
                                    .font(.caption)
                                Text("Plain English Instructions")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundStyle(Color.primaryBrown)
                            .padding(.horizontal)
                        }

                        Text(displayText.cleanedMarkdown)
                            .font(showNotation ? .system(.body, design: .monospaced) : .body)
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                    }
                }
            }
        }
    }

    private var imageTabContent: some View {
        imageGallerySection
    }

    private var chatTabContent: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("Project Discussion")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Ask questions specific to this project. Chat history is saved separately.")
                    .font(.caption)
                    .foregroundStyle(Color.appMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(Color.appCard)

            // Chat interface
            if let chatVM = projectChatViewModel {
                ProjectChatView(viewModel: chatVM)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private var notesTabContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Project Notes")
                    .font(.headline)

                Spacer()

                Button("Save") {
                    saveNotes()
                }
                .font(.subheadline)
                .foregroundStyle(Color.primaryBrown)
            }
            .padding(.horizontal)

            TextEditor(text: $editedNotes)
                .font(.body)
                .frame(minHeight: 300)
                .padding(8)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                .focused($isNotesFocused)
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
            .padding(.horizontal)

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

    // MARK: - Chat Initialization

    private func initializeProjectChat() {
        guard projectChatViewModel == nil else { return }

        let chatVM = ChatViewModel()

        // Load or create project-specific conversation
        Task {
            await chatVM.initialize()

            if let conversationId = project.conversationId,
               let existingConversation = chatVM.conversations.first(where: { $0.id == conversationId }) {
                // Load existing project conversation
                chatVM.loadConversation(existingConversation)
            } else {
                // Create new conversation for this project
                chatVM.createNewConversation()
                if let newConversation = chatVM.currentConversation {
                    // Update project with conversation ID
                    var updatedProject = project
                    updatedProject.conversationId = newConversation.id
                    // Save to view model (would need to add this method)
                }
            }

            await MainActor.run {
                projectChatViewModel = chatVM
            }
        }
    }

    // MARK: - Delete Method

    private func deleteProject() {
        Task {
            guard let backendId = project.backendId else { return }

            let success = await viewModel.deleteProject(projectId: backendId)

            if success {
                await MainActor.run {
                    dismiss()
                }
            }
        }
    }

    // MARK: - Save Methods

    private func savePattern() {
        Task {
            guard let backendId = project.backendId else { return }

            let success = await viewModel.updateProject(
                projectId: backendId,
                pattern: editedPattern
            )

            if success {
                isEditingPattern = false
            }
        }
    }

    private func saveNotes() {
        Task {
            guard let backendId = project.backendId else { return }

            let success = await viewModel.updateProject(
                projectId: backendId,
                notes: editedNotes
            )

            if !success {
                // Revert on failure
                editedNotes = project.notes ?? ""
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

// MARK: - Project Chat View
struct ProjectChatView: View {
    @Bindable var viewModel: ChatViewModel
    @State private var messageText = ""
    @State private var scrollProxy: ScrollViewProxy?
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.messages) { message in
                            MessageRow(message: message)
                                .id(message.id)
                        }

                        // Loading indicator
                        if viewModel.isLoading {
                            HStack {
                                ProgressView()
                                    .padding(.leading, 8)
                                Text("Thinking...")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .padding()
                        }
                    }
                    .padding()
                }
                .contentMargins(.bottom, 8, for: .scrollContent)
                .onTapGesture {
                    isInputFocused = false
                }
                .onAppear {
                    scrollProxy = proxy
                }
                .onChange(of: viewModel.messages.count) { _, _ in
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Input Area
            HStack(spacing: 12) {
                TextField("Ask about this project", text: $messageText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.body)
                    .lineLimit(1...5)
                    .focused($isInputFocused)
                    .onSubmit {
                        sendMessage()
                    }

                Button(action: sendMessage) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(messageText.isEmpty ? Color.appMuted : Color.primaryBrown)
                        )
                }
                .disabled(messageText.isEmpty || viewModel.isLoading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.appCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.appBorder, lineWidth: 1)
            )
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }

    private func sendMessage() {
        guard !messageText.isEmpty else { return }

        let text = messageText
        messageText = ""
        isInputFocused = false

        Task {
            await viewModel.sendMessage(text, images: [])
        }
    }
}

#Preview {
    NavigationStack {
        ProjectDetailView(project: Project.mockProjects[0], viewModel: ProjectViewModel())
    }
}
