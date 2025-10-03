//
//  HomeView.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import SwiftUI

struct HomeView: View {
    @State private var recentProjects: [Project] = Project.mockProjects
    @State private var recentConversations: [Conversation] = Conversation.mockConversations

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Welcome Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome to")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Text("Crooked Finger")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding(.horizontal)
                .padding(.top)

                // Quick Actions
                HStack(spacing: 16) {
                    QuickActionCard(
                        title: "New Chat",
                        icon: "message.fill",
                        color: .blue
                    )
                    QuickActionCard(
                        title: "New Project",
                        icon: "plus.circle.fill",
                        color: .green
                    )
                }
                .padding(.horizontal)

                // Recent Projects
                if !recentProjects.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recent Projects")
                                .font(.headline)
                            Spacer()
                            Button("See All") {}
                                .font(.subheadline)
                        }
                        .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(recentProjects) { project in
                                    ProjectQuickCard(project: project)
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
                            Button("See All") {}
                                .font(.subheadline)
                        }
                        .padding(.horizontal)

                        VStack(spacing: 8) {
                            ForEach(recentConversations) { conversation in
                                ConversationQuickCard(conversation: conversation)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.bottom)
        }
        .navigationTitle("Home")
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
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
}

// MARK: - Project Quick Card
struct ProjectQuickCard: View {
    let project: Project

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "folder.fill")
                    .foregroundStyle(.blue)
                Spacer()
                Image(systemName: project.isFavorite ? "star.fill" : "star")
                    .foregroundStyle(.yellow)
                    .font(.caption)
            }

            Text(project.name)
                .font(.headline)
                .lineLimit(1)

            Text(project.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack {
                StatusBadge(status: project.status)
                Spacer()
                Text(project.difficulty.rawValue.capitalized)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(width: 200)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
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
        case .planning: return "Planning"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        }
    }

    private var statusColor: Color {
        switch status {
        case .planning: return .orange
        case .inProgress: return .blue
        case .completed: return .green
        }
    }
}

// MARK: - Conversation Quick Card
struct ConversationQuickCard: View {
    let conversation: Conversation

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "message.fill")
                .foregroundStyle(.blue)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(conversation.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                if let lastMessage = conversation.messages.last {
                    Text(lastMessage.content)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
