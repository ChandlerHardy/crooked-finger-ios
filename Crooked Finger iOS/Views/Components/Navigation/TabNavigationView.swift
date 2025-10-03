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

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                NavigationStack {
                    tabContent(for: tab)
                        .background(Color.appBackground)
                }
                .tabItem {
                    Label(tab.rawValue, systemImage: tab.iconName)
                }
                .tag(tab)
            }
        }
        .tint(Color.primaryBrown) // Tab bar accent color
    }

    @ViewBuilder
    private func tabContent(for tab: TabItem) -> some View {
        switch tab {
        case .home:
            HomeView()
        case .chat:
            ChatView()
        case .patterns:
            PatternLibraryView()
        case .projects:
            ProjectsView()
        case .settings:
            SettingsView()
        }
    }
}

#Preview {
    TabNavigationView()
}
