//
//  PatternLibraryView.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import SwiftUI

struct PatternLibraryView: View {
    @State var viewModel: PatternViewModel
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
                .id(UUID()) // Force recreation each time sheet is presented
        }
        .sheet(isPresented: $showYouTubeSheet) {
            YouTubeTranscriptView(patternViewModel: viewModel)
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
    @State private var selectedTab = 0
    @State private var name = ""
    @State private var notation = ""
    @State private var instructions = ""
    @State private var difficulty: PatternDifficulty = .beginner
    @State private var materials = ""
    @State private var estimatedTime = ""
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker = false
    @State private var showDocumentPicker = false
    @State private var isCreating = false
    @State private var isTranslating = false
    @State private var chatViewModel: ChatViewModel? = nil

    init(viewModel: PatternViewModel) {
        self.viewModel = viewModel
        // Force fresh chat initialization
        let fresh = ChatViewModel()
        _chatViewModel = State(initialValue: fresh)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Picker
                Picker("Mode", selection: $selectedTab) {
                    Text("Manual").tag(0)
                    Text("AI Assistant").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                if selectedTab == 0 {
                    manualEntryView
                } else {
                    aiAssistantView
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
                if selectedTab == 0 {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            Task {
                                await savePattern()
                            }
                        }
                        .disabled(name.isEmpty || notation.isEmpty || isCreating)
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImages: $selectedImages, maxSelection: 10)
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker(selectedImages: $selectedImages)
            }
        }
        .task {
            // Force fresh chat conversation without loading existing conversations
            if let chat = chatViewModel {
                chat.createNewConversation()
            }
        }
    }

    // MARK: - Manual Entry View

    private var manualEntryView: some View {
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

                if !notation.isEmpty && instructions.isEmpty {
                    Button {
                        Task {
                            await translateNotation()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "wand.and.stars")
                            Text(isTranslating ? "Translating..." : "Generate Instructions with AI")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(isTranslating)
                }
            } header: {
                Text("Notation")
            } footer: {
                Text("Abbreviated pattern (e.g., 'Ch 4, 12 dc in ring, sl st')")
            }

            Section {
                TextEditor(text: $instructions)
                    .frame(minHeight: 80)
            } header: {
                Text("Instructions \(instructions.isEmpty ? "(Optional)" : "")")
            } footer: {
                if !instructions.isEmpty {
                    Text("AI-generated instructions. Edit as needed.")
                }
            }

            Section {
                TextField("Materials", text: $materials)
                TextField("Estimated Time", text: $estimatedTime)
            } header: {
                Text("Additional Info (Optional)")
            }

            Section {
                if !selectedImages.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))

                                    Button {
                                        selectedImages.remove(at: index)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.white)
                                            .background(Circle().fill(.black.opacity(0.6)))
                                    }
                                    .padding(4)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Button {
                    showImagePicker = true
                } label: {
                    Label("Add from Photo Library", systemImage: "photo.badge.plus")
                }

                Button {
                    showDocumentPicker = true
                } label: {
                    Label("Browse Files", systemImage: "folder.badge.plus")
                }
            } header: {
                Text("Photos (Optional)")
            }
        }
    }

    // MARK: - AI Assistant View

    private var aiAssistantView: some View {
        VStack(spacing: 0) {
            // Info banner
            VStack(spacing: 8) {
                Text("AI Pattern Assistant")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Ask the AI to help you create a pattern, parse notation, or analyze pattern images.")
                    .font(.caption)
                    .foregroundStyle(Color.appMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(Color.appCard)

            // Chat interface
            if let chatVM = chatViewModel {
                PatternCreationChatView(
                    viewModel: chatVM,
                    currentName: $name,
                    currentNotation: $notation,
                    currentInstructions: $instructions,
                    currentDifficulty: $difficulty,
                    currentMaterials: $materials,
                    currentEstimatedTime: $estimatedTime,
                    onPatternExtracted: { extractedName, extractedNotation, extractedInstructions in
                        // Fill in the manual form with extracted data
                        name = extractedName ?? name
                        notation = extractedNotation ?? notation
                        instructions = extractedInstructions ?? instructions
                        selectedTab = 0 // Switch to manual tab
                    }
                )
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    // MARK: - Actions

    private func translateNotation() async {
        isTranslating = true

        // Use chat API to translate pattern notation to plain instructions
        let chatVM = ChatViewModel()
        await chatVM.initialize()

        let prompt = """
        Translate this crochet pattern notation into detailed, plain English instructions:

        \(notation)

        Please provide step-by-step instructions that a beginner could follow.
        """

        await chatVM.sendMessage(prompt, images: [])

        // Get the AI response
        if let lastMessage = chatVM.messages.last, lastMessage.type == .assistant {
            instructions = lastMessage.content
        }

        isTranslating = false
    }

    private func savePattern() async {
        isCreating = true
        let success = await viewModel.savePattern(
            name: name,
            notation: notation,
            instructions: instructions.isEmpty ? nil : instructions,
            difficulty: difficulty,
            materials: materials.isEmpty ? nil : materials,
            estimatedTime: estimatedTime.isEmpty ? nil : estimatedTime,
            images: selectedImages
        )
        isCreating = false
        if success {
            dismiss()
        }
    }
}

// MARK: - Pattern Creation Chat View
struct PatternCreationChatView: View {
    @Bindable var viewModel: ChatViewModel
    @Binding var currentName: String
    @Binding var currentNotation: String
    @Binding var currentInstructions: String
    @Binding var currentDifficulty: PatternDifficulty
    @Binding var currentMaterials: String
    @Binding var currentEstimatedTime: String
    let onPatternExtracted: (String?, String?, String?) -> Void
    @State private var messageText = ""
    @State private var scrollProxy: ScrollViewProxy?
    @FocusState private var isInputFocused: Bool
    @State private var showImagePicker = false
    @State private var showDocumentPicker = false
    @State private var selectedImages: [UIImage] = []
    @State private var attachedImages: [UIImage] = []

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

            // Image attachments preview
            if !attachedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(attachedImages.enumerated()), id: \.offset) { index, image in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))

                                Button {
                                    attachedImages.remove(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption)
                                        .foregroundStyle(.white)
                                        .background(Circle().fill(.black.opacity(0.6)))
                                }
                                .padding(2)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color.appCard.opacity(0.5))
            }

            // Input Area
            HStack(spacing: 12) {
                // Simple attachment button - taps to show photo picker
                Button {
                    showImagePicker = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.appMuted)
                }

                TextField("Ask about pattern notation, materials, etc.", text: $messageText, axis: .vertical)
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
                                .fill(messageText.isEmpty && attachedImages.isEmpty ? Color.appMuted : Color.primaryBrown)
                        )
                }
                .disabled((messageText.isEmpty && attachedImages.isEmpty) || viewModel.isLoading)
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
        .sheet(isPresented: $showImagePicker) {
            MediaPickerView(selectedImages: $selectedImages)
        }
        .onChange(of: selectedImages) { _, newImages in
            if !newImages.isEmpty {
                attachedImages.append(contentsOf: newImages)
                selectedImages = []
            }
        }
    }

    private func sendMessage() {
        guard !messageText.isEmpty || !attachedImages.isEmpty else { return }

        // Build context from manual form data
        var contextParts: [String] = []

        if !currentName.isEmpty {
            contextParts.append("Pattern Name: \(currentName)")
        }
        if !currentNotation.isEmpty {
            contextParts.append("Current Notation: \(currentNotation)")
        }
        if !currentInstructions.isEmpty {
            contextParts.append("Current Instructions: \(currentInstructions)")
        }
        if currentDifficulty != .beginner {
            contextParts.append("Difficulty: \(currentDifficulty.rawValue)")
        }
        if !currentMaterials.isEmpty {
            contextParts.append("Materials: \(currentMaterials)")
        }
        if !currentEstimatedTime.isEmpty {
            contextParts.append("Estimated Time: \(currentEstimatedTime)")
        }

        // Build full message with explicit pattern creation instructions
        var contextMessage = """
        SYSTEM CONTEXT: You are an AI assistant embedded in a pattern creation form. Your responses will be automatically parsed to populate the pattern fields. When the user provides pattern information (via text or images), respond in this EXACT format:

        NAME: [Pattern name - descriptive title like "Granny Square" or "Simple Beanie"]
        NOTATION: [Abbreviated crochet notation using standard abbreviations like ch, dc, sc, etc.]
        INSTRUCTIONS: [Full step-by-step instructions in plain English with line breaks between rounds/rows]
        DIFFICULTY: [beginner, intermediate, or advanced]
        MATERIALS: [Yarn weight, hook size, and supplies]
        TIME: [Estimated completion time]

        IMPORTANT: Use this exact format with these exact header names. The app will extract these sections and auto-populate the pattern creation form.

        """

        if !contextParts.isEmpty {
            contextMessage += "CURRENT PATTERN DATA:\n" + contextParts.joined(separator: "\n") + "\n\n"
        }

        contextMessage += "USER REQUEST: \(messageText)"

        let text = messageText
        let images = attachedImages
        messageText = ""
        attachedImages = []
        isInputFocused = false

        Task {
            await viewModel.sendMessage(contextMessage, images: images)

            // Try to extract pattern info from the response and populate manual form
            if let lastMessage = viewModel.messages.last, lastMessage.type == .assistant {
                extractPatternFromResponse(lastMessage.content)
            }
        }
    }

    private func extractPatternFromResponse(_ response: String) {
        // Extract pattern data from AI response and populate manual form fields
        // Parse multi-line sections properly

        print("🔍 Extracting pattern from response:")
        print(response)
        print("---")

        func extractSection(from text: String, headers: [String]) -> String? {
            for header in headers {
                // Find the header line
                let headerPattern = "(?:^|\\n)(?:[0-9]\\.\\s*)?(?:\\*\\*)?(\(header))(?:\\*\\*)?\\s*:"
                guard let headerRange = text.range(of: headerPattern, options: [.regularExpression, .caseInsensitive]) else {
                    continue
                }

                // Start extraction after the colon
                let afterHeader = text[headerRange.upperBound...]

                // Find where this section ends (next major header or end of string)
                let nextSectionPattern = "\\n(?:NAME|NOTATION|INSTRUCTIONS|DIFFICULTY|MATERIALS|TIME)\\s*:"
                var content: String
                if let nextRange = afterHeader.range(of: nextSectionPattern, options: [.regularExpression, .caseInsensitive]) {
                    content = String(afterHeader[..<nextRange.lowerBound])
                } else {
                    content = String(afterHeader)
                }

                // Clean up the content
                content = content.trimmingCharacters(in: .whitespacesAndNewlines)

                if !content.isEmpty {
                    print("✅ Extracted '\(header)': \(content.prefix(50))...")
                    return content
                }
            }
            return nil
        }

        let extractedName = extractSection(from: response, headers: ["NAME", "Pattern Name", "Name"])
        let extractedNotation = extractSection(from: response, headers: ["NOTATION", "Pattern Notation", "Notation"])
        let extractedInstructions = extractSection(from: response, headers: ["INSTRUCTIONS", "Detailed Instructions", "Instructions"])

        // Directly update bindings if data found
        if let name = extractedName, !name.isEmpty {
            print("📝 Setting name: \(name)")
            currentName = name
        }
        if let notation = extractedNotation, !notation.isEmpty {
            print("📝 Setting notation: \(notation.prefix(50))...")
            currentNotation = notation
        }
        if let instructions = extractedInstructions, !instructions.isEmpty {
            print("📝 Setting instructions: \(instructions.prefix(50))...")
            currentInstructions = instructions
        }

        // Also trigger callback for tab switching
        if extractedName != nil || extractedNotation != nil || extractedInstructions != nil {
            onPatternExtracted(extractedName, extractedNotation, extractedInstructions)
        }
    }
}

#Preview {
    NavigationStack {
        PatternLibraryView(viewModel: PatternViewModel())
    }
}
