//
//  ChatView.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import SwiftUI

struct ChatView: View {
    var viewModel: ChatViewModel
    @State private var messageText = ""
    @State private var scrollProxy: ScrollViewProxy?
    @State private var showMediaPicker = false
    @State private var selectedImages: [UIImage] = []
    @State private var attachedImages: [UIImage] = []
    @State private var showConversationHistory = false
    @State private var isSending = false
    @FocusState private var isInputFocused: Bool

    init(viewModel: ChatViewModel? = nil) {
        self.viewModel = viewModel ?? ChatViewModel()
    }

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
                    // Dismiss keyboard when tapping message area
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
                .task {
                    // Initialize conversation data in background
                    await viewModel.initialize()
                }
            }

            // Error message
            if let error = viewModel.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Dismiss") {
                        viewModel.errorMessage = nil
                    }
                    .font(.caption)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
            }

            // Image Attachments Preview
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
                                        .foregroundStyle(.white)
                                        .background(Circle().fill(Color.black.opacity(0.6)))
                                }
                                .offset(x: 5, y: -5)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color.appCard)
            }

            // Input Area - Claude-style integrated bar
            HStack(spacing: 12) {
                // Left side buttons
                HStack(spacing: 16) {
                    // Attachment button
                    Button {
                        showMediaPicker = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.appMuted)
                    }
                }

                // Text input
                TextField("Reply to Assistant", text: $messageText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.body)
                    .lineLimit(1...5)
                    .autocorrectionDisabled(false)
                    .textInputAutocapitalization(.sentences)
                    .submitLabel(.return)
                    .focused($isInputFocused)
                    .onSubmit {
                        sendMessage()
                    }

                Spacer()

                // Right side buttons
                HStack(spacing: 12) {
                    // Send button
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(messageText.isEmpty && attachedImages.isEmpty && !isSending ? Color.appMuted : Color.primaryBrown)
                            )
                    }
                    .disabled((messageText.isEmpty && attachedImages.isEmpty && !isSending) || viewModel.isLoading)
                }
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
        .background(Color.appBackground)
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showConversationHistory = true
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .foregroundStyle(Color.appText)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.createNewConversation()
                } label: {
                    Image(systemName: "plus.circle")
                        .foregroundStyle(Color.appText)
                }
            }
        }
        .sheet(isPresented: $showMediaPicker) {
            MediaPickerView(selectedImages: $selectedImages)
        }
        .sheet(isPresented: $showConversationHistory) {
            ConversationHistoryView(viewModel: viewModel, isPresented: $showConversationHistory)
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

        // Haptic feedback on send
        Haptics.impact(.light)

        isSending = true

        let text = messageText
        let images = attachedImages

        // Clear input and dismiss keyboard immediately
        messageText = ""
        attachedImages = []
        isInputFocused = false

        Task {
            await viewModel.sendMessage(text, images: images)
            isSending = false
        }
    }
}

// MARK: - Message Row
struct MessageRow: View {
    let message: ChatMessage
    @State private var appeared = false
    @State private var showImageViewer = false
    @State private var selectedImageIndex = 0

    // Pre-compute markdown once
    private var markdownContent: AttributedString {
        (try? AttributedString(markdown: message.content)) ?? AttributedString(message.content)
    }

    var body: some View {
        Group {
            if message.type == .assistant {
            // Assistant: Full-width, no bubble
            VStack(alignment: .leading, spacing: 8) {
                Text(markdownContent)
                    .textSelection(.enabled)
                    .font(.body)
                    .foregroundStyle(Color.appText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(Color.appMuted)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 5)
            .onAppear {
                withAnimation(.easeOut(duration: 0.15)) {
                    appeared = true
                }
            }
        } else {
            // User: Right-aligned bubble
            HStack(alignment: .top, spacing: 12) {
                Spacer(minLength: 60)

                VStack(alignment: .trailing, spacing: 6) {
                    // Attached images if any
                    if let images = message.attachedImages, !images.isEmpty {
                        VStack(spacing: 4) {
                            ForEach(Array(images.enumerated()), id: \.offset) { index, base64String in
                                if let imageData = Data(base64Encoded: base64String),
                                   let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: 250)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .onTapGesture {
                                            selectedImageIndex = index
                                            showImageViewer = true
                                        }
                                }
                            }
                        }
                        .padding(8)
                        .background(Color.primaryBrown.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Text message
                    if !message.content.isEmpty {
                        Text(message.content)
                            .padding(14)
                            .background(
                                LinearGradient(
                                    colors: [Color.primaryBrown, Color.primaryBrown.opacity(0.9)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }

                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundStyle(Color.appMuted)
                        .padding(.horizontal, 4)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 5)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.15)) {
                        appeared = true
                    }
                }
            }
        }
        }
        .fullScreenCover(isPresented: $showImageViewer) {
            if let images = message.attachedImages, !images.isEmpty {
                Base64ImageViewer(images: images, currentIndex: $selectedImageIndex)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatView()
    }
}
