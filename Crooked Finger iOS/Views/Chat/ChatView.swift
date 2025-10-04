//
//  ChatView.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import SwiftUI

struct ChatView: View {
    @State private var viewModel = ChatViewModel()
    @State private var messageText = ""
    @State private var scrollProxy: ScrollViewProxy?
    @State private var showImagePicker = false
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
                        showImagePicker = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.appMuted)
                    }
                }

                // Text input
                TextField("Reply to Assistant", text: $messageText, axis: .vertical)
                    .font(.body)
                    .lineLimit(1...5)
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
                                    .fill(messageText.isEmpty && attachedImages.isEmpty ? Color.appMuted : Color.primaryBrown)
                            )
                    }
                    .disabled((messageText.isEmpty && attachedImages.isEmpty) || viewModel.isLoading)
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
            .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color.appBackground)
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.clearMessages()
                } label: {
                    Image(systemName: "plus.circle")
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImages: $selectedImages, maxSelection: 5)
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

        let text = messageText
        let images = attachedImages
        messageText = ""
        attachedImages = []

        Task {
            await viewModel.sendMessage(text, images: images)
        }
    }
}

// MARK: - Message Row
struct MessageRow: View {
    let message: ChatMessage
    @State private var appeared = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.type == .user {
                Spacer(minLength: 60)
            }

            VStack(alignment: message.type == .user ? .trailing : .leading, spacing: 6) {
                // Use Text with markdown parsing for assistant messages
                if message.type == .assistant {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.caption)
                            .foregroundStyle(Color.primaryBrown)

                        Text("Assistant")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.appMuted)
                    }

                    Text(try! AttributedString(markdown: message.content))
                        .textSelection(.enabled)
                        .padding(14)
                        .background(Color.appCard)
                        .foregroundStyle(Color.appText)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.appBorder, lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
                } else {
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
                        .shadow(color: Color.primaryBrown.opacity(0.3), radius: 4, y: 2)
                }

                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(Color.appMuted)
                    .padding(.horizontal, 4)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .onAppear {
                withAnimation(.easeOut(duration: 0.3)) {
                    appeared = true
                }
            }

            if message.type == .assistant {
                Spacer(minLength: 60)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatView()
    }
}
