//
//  PatternDetailView.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import SwiftUI

struct PatternDetailView: View {
    let pattern: Pattern
    @State private var isFavorite: Bool

    init(pattern: Pattern) {
        self.pattern = pattern
        self._isFavorite = State(initialValue: pattern.isFavorite)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(pattern.name)
                            .font(.title)
                            .fontWeight(.bold)

                        if let description = pattern.description {
                            Text(description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    Button {
                        isFavorite.toggle()
                    } label: {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .foregroundStyle(.yellow)
                            .font(.title2)
                    }
                }

                // Metadata
                VStack(alignment: .leading, spacing: 12) {
                    if let difficulty = pattern.difficulty {
                        MetadataRow(label: "Difficulty", value: difficulty.rawValue.capitalized)
                    }

                    if let materials = pattern.materials {
                        MetadataRow(label: "Materials", value: materials)
                    }

                    if let estimatedTime = pattern.estimatedTime {
                        MetadataRow(label: "Time", value: estimatedTime)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Notation
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pattern Notation")
                        .font(.headline)

                    Text(pattern.notation)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Instructions
                if let instructions = pattern.instructions {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Instructions")
                            .font(.headline)

                        Text(instructions)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Pattern Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Metadata Row
struct MetadataRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
        }
    }
}

#Preview {
    NavigationStack {
        PatternDetailView(pattern: Pattern.mockPatterns[0])
    }
}
