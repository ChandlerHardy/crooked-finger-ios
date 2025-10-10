//
//  HomeView.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: TabItem
    var chatViewModel: ChatViewModel
    @State private var viewModel = ProjectViewModel()
    @State private var showNewProjectSheet = false
    @State private var showConversationHistory = false

    private var recentProjects: [Project] {
        Array(viewModel.projects.prefix(5))
    }

    private var recentConversations: [Conversation] {
        // Sort by most recent and filter out empty conversations
        let sorted = chatViewModel.conversations
            .filter { $0.messageCount > 0 }
            .sorted { $0.updatedAt > $1.updatedAt }
        return Array(sorted.prefix(3))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Logo
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                    .padding(.horizontal)

                // Quick Actions
                HStack(spacing: 16) {
                    Button {
                        selectedTab = .chat
                        chatViewModel.createNewConversation()
                    } label: {
                        QuickActionCard(
                            title: "New Chat",
                            icon: "message.fill",
                            color: Color.primaryBrown
                        )
                    }

                    Button {
                        showNewProjectSheet = true
                    } label: {
                        QuickActionCard(
                            title: "New Project",
                            icon: "plus.circle.fill",
                            color: Color.primaryBrown
                        )
                    }
                }
                .padding(.horizontal)

                // Recent Projects
                if !recentProjects.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recent Projects")
                                .font(.headline)
                            Spacer()
                            Button("See All") {
                                selectedTab = .projects
                            }
                            .font(.subheadline)
                            .foregroundStyle(Color.primaryBrown)
                        }
                        .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(recentProjects) { project in
                                    NavigationLink {
                                        ProjectDetailView(project: project, viewModel: viewModel)
                                    } label: {
                                        ProjectQuickCard(project: project)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                // Recent Conversations
                if !recentConversations.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recent Conversations")
                                .font(.headline)
                            Spacer()
                            Button("See All") {
                                showConversationHistory = true
                            }
                            .font(.subheadline)
                            .foregroundStyle(Color.primaryBrown)
                        }
                        .padding(.horizontal)

                        VStack(spacing: 8) {
                            ForEach(recentConversations) { conversation in
                                Button {
                                    chatViewModel.loadConversation(conversation)
                                    selectedTab = .chat
                                } label: {
                                    ConversationQuickCard(conversation: conversation)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.bottom)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showNewProjectSheet) {
            CreateProjectSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showConversationHistory) {
            ConversationHistoryView(viewModel: chatViewModel, isPresented: $showConversationHistory)
        }
        .task {
            await viewModel.fetchProjects()
        }
    }
}

// MARK: - Quick Action Card
struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(color)
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color.appText)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appBorder, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
}

// MARK: - Project Quick Card
struct ProjectQuickCard: View {
    let project: Project

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "folder.fill")
                    .foregroundStyle(Color.primaryBrown)
                Spacer()
                Image(systemName: project.isFavorite ? "star.fill" : "star")
                    .foregroundStyle(.yellow)
                    .font(.caption)
            }

            Text(project.name.cleanedMarkdown)
                .font(.headline)
                .foregroundStyle(Color.appText)
                .lineLimit(1)

            Text(project.description.cleanedMarkdown)
                .font(.caption)
                .foregroundStyle(Color.appMuted)
                .lineLimit(2)

            HStack {
                StatusBadge(status: project.status)
                Spacer()
                Text(project.difficulty.rawValue.capitalized)
                    .font(.caption2)
                    .foregroundStyle(Color.appMuted)
            }
        }
        .padding()
        .frame(width: 200)
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appBorder, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: ProjectStatus

    var body: some View {
        Text(statusText)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundStyle(statusColor)
            .clipShape(Capsule())
    }

    private var statusText: String {
        switch status {
        case .notStarted: return "Not Started"
        case .planning: return "Planning"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        }
    }

    private var statusColor: Color {
        switch status {
        case .notStarted: return .gray
        case .planning: return .orange
        case .inProgress: return .blue
        case .completed: return .green
        }
    }
}

// MARK: - Conversation Quick Card
struct ConversationQuickCard: View {
    let conversation: Conversation

    private var previewText: String {
        // Show first user message and response if available
        if conversation.messages.count >= 2,
           let userMessage = conversation.messages.first(where: { $0.type == .user }),
           let assistantMessage = conversation.messages.first(where: { $0.type == .assistant }) {
            return "\(userMessage.content.prefix(30))... → \(assistantMessage.content.prefix(30))..."
        } else if let firstMessage = conversation.messages.first {
            return String(firstMessage.content.prefix(60))
        }
        return "No messages yet"
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "message.fill")
                .foregroundStyle(Color.primaryBrown)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(conversation.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.appText)
                    .lineLimit(1)

                Text(previewText)
                    .font(.caption)
                    .foregroundStyle(Color.appMuted)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Color.appMuted)
        }
        .padding()
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appBorder, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
}

#Preview {
    NavigationStack {
        HomeView(selectedTab: .constant(.home), chatViewModel: ChatViewModel())
    }
}
