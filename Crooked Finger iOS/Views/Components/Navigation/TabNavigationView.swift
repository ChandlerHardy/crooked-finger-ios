//
//  TabNavigationView.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import SwiftUI

enum TabItem: String, CaseIterable {
    case home = "Home"
    case chat = "Chat"
    case patterns = "Patterns"
    case projects = "Projects"
    case settings = "Settings"

    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .chat: return "message.fill"
        case .patterns: return "book.fill"
        case .projects: return "folder.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct TabNavigationView: View {
    @State private var selectedTab: TabItem = .home
    @State private var chatViewModel = ChatViewModel()
    @State private var patternViewModel = PatternViewModel()
    @State private var projectViewModel = ProjectViewModel()
    @State private var hasVisitedChat = false
    @State private var hasVisitedPatterns = false
    @State private var hasVisitedProjects = false
    @State private var hasVisitedSettings = false

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView(selectedTab: $selectedTab, chatViewModel: chatViewModel)
                    .background(Color.appBackground)
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(TabItem.home)

            NavigationStack {
                if hasVisitedChat || selectedTab == .chat {
                    ChatView(viewModel: chatViewModel)
                        .background(Color.appBackground)
                        .onAppear { hasVisitedChat = true }
                } else {
                    Color.clear
                }
            }
            .tabItem {
                Label("Chat", systemImage: "message.fill")
            }
            .tag(TabItem.chat)

            NavigationStack {
                if hasVisitedPatterns || selectedTab == .patterns {
                    PatternLibraryView(viewModel: patternViewModel)
                        .background(Color.appBackground)
                        .onAppear { hasVisitedPatterns = true }
                } else {
                    Color.clear
                }
            }
            .tabItem {
                Label("Patterns", systemImage: "book.fill")
            }
            .tag(TabItem.patterns)

            NavigationStack {
                if hasVisitedProjects || selectedTab == .projects {
                    ProjectsView(viewModel: projectViewModel)
                        .background(Color.appBackground)
                        .onAppear { hasVisitedProjects = true }
                } else {
                    Color.clear
                }
            }
            .tabItem {
                Label("Projects", systemImage: "folder.fill")
            }
            .tag(TabItem.projects)

            NavigationStack {
                if hasVisitedSettings || selectedTab == .settings {
                    SettingsView()
                        .background(Color.appBackground)
                        .onAppear { hasVisitedSettings = true }
                } else {
                    Color.clear
                }
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(TabItem.settings)
        }
        .tint(Color.primaryBrown) // Tab bar accent color
        .task {
            await chatViewModel.initialize()
        }
    }
}

#Preview {
    TabNavigationView()
}
