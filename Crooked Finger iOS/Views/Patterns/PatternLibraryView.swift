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
        List {
            ForEach(filteredPatterns) { pattern in
                NavigationLink {
                    PatternDetailView(pattern: pattern)
                } label: {
                    PatternRow(pattern: pattern)
                }
            }
        }
        .navigationTitle("Patterns")
        .searchable(text: $searchText, prompt: "Search patterns")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // Add pattern
                } label: {
                    Image(systemName: "plus")
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
                .foregroundStyle(.blue)
                .frame(width: 44, height: 44)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(pattern.name)
                    .font(.headline)

                if let description = pattern.description {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                HStack(spacing: 8) {
                    if let difficulty = pattern.difficulty {
                        Text(difficulty.rawValue.capitalized)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundStyle(.blue)
                            .clipShape(Capsule())
                    }

                    ForEach(pattern.tags.prefix(2), id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
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
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        PatternLibraryView()
    }
}
