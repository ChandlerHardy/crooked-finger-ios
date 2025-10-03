//
//  PatternLibraryView.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import SwiftUI

struct PatternLibraryView: View {
    @State private var patterns: [Pattern] = Pattern.mockPatterns
    @State private var searchText = ""

    var filteredPatterns: [Pattern] {
        if searchText.isEmpty {
            return patterns
        }
        return patterns.filter { pattern in
            pattern.name.localizedCaseInsensitiveContains(searchText) ||
            pattern.description?.localizedCaseInsensitiveContains(searchText) ?? false
        }
    }

    var body: some View {
        Group {
            if filteredPatterns.isEmpty {
                if searchText.isEmpty {
                    // No patterns at all
                    EmptyStateView(
                        icon: "book.closed",
                        title: "No Patterns Yet",
                        message: "Save patterns from the chat or import from YouTube to build your library",
                        actionTitle: "Start Chatting",
                        action: {
                            // TODO: Navigate to chat
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
                        NavigationLink {
                            PatternDetailView(pattern: pattern)
                        } label: {
                            PatternRow(pattern: pattern)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .refreshable {
                    // TODO: Refresh patterns from backend
                }
            }
        }
        .background(Color.appBackground)
        .navigationTitle("Patterns")
        .searchable(text: $searchText, prompt: "Search patterns")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // Add pattern
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(Color.primaryBrown)
                }
            }
        }
    }
}

// MARK: - Pattern Row
struct PatternRow: View {
    let pattern: Pattern

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "book.fill")
                .font(.title2)
                .foregroundStyle(Color.primaryBrown)
                .frame(width: 44, height: 44)
                .background(Color.primaryBrown.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(pattern.name)
                    .font(.headline)
                    .foregroundStyle(Color.appText)

                if let description = pattern.description {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(Color.appMuted)
                        .lineLimit(1)
                }

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

            Spacer()

            if pattern.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appBorder, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

#Preview {
    NavigationStack {
        PatternLibraryView()
    }
}
