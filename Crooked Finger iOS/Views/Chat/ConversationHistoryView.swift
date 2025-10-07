//
//  ConversationHistoryView.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/4/25.
//

import SwiftUI

struct ConversationHistoryView: View {
    @Bindable var viewModel: ChatViewModel
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // New Chat Button
                    Button {
                        viewModel.createNewConversation()
                        isPresented = false
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                            Text("New Chat")
                                .font(.headline)
                            Spacer()
                        }
                        .padding()
                        .background(Color.primaryBrown)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    // Conversations List
                    if viewModel.conversations.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "message")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                            Text("No conversations yet")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(viewModel.conversations) { conversation in
                                ConversationRow(
                                    conversation: conversation,
                                    isSelected: conversation.id == viewModel.currentConversation?.id,
                                    onTap: {
                                        viewModel.loadConversation(conversation)
                                        isPresented = false
                                    },
                                    onDelete: {
                                        viewModel.deleteConversation(conversation)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .background(Color.appBackground)
            .navigationTitle("Conversations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.appMuted)
                    }
                }
            }
        }
    }
}

// MARK: - Conversation Row

struct ConversationRow: View {
    let conversation: Conversation
    let isSelected: Bool
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(conversation.title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? Color.primaryBrown : Color.appText)
                    .lineLimit(2)

                HStack(spacing: 6) {
                    Image(systemName: "message.fill")
                        .font(.caption2)
                    Text("\(conversation.messageCount) messages")
                        .font(.caption)
                    Text("•")
                        .font(.caption2)
                    Text(conversation.updatedAt, format: .dateTime.month().day().hour().minute())
                        .font(.caption)
                }
                .foregroundStyle(Color.appMuted)
            }

            Spacer()

            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(isSelected ? Color.primaryBrown.opacity(0.1) : Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.primaryBrown : Color.appBorder, lineWidth: 1)
        )
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    ConversationHistoryView(
        viewModel: ChatViewModel(),
        isPresented: .constant(true)
    )
}
