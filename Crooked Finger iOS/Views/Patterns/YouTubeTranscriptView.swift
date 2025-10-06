//
//  YouTubeTranscriptView.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/5/25.
//

import SwiftUI

struct YouTubeTranscriptView: View {
    @Environment(\.dismiss) var dismiss
    let patternViewModel: PatternViewModel
    @State private var viewModel = YouTubeViewModel()
    @State private var videoUrl = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Input Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Fetch Video Transcript")
                            .font(.headline)

                        Text("Enter a YouTube URL to fetch its transcript. Try a crochet tutorial!")
                            .font(.caption)
                            .foregroundStyle(Color.appMuted)

                        HStack(spacing: 12) {
                            TextField("https://www.youtube.com/watch?v=...", text: $videoUrl)
                                .textFieldStyle(.plain)
                                .font(.body)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .focused($isInputFocused)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .onSubmit {
                                    if !viewModel.isLoadingTranscript {
                                        fetchTranscript()
                                    }
                                }

                            Button {
                                fetchTranscript()
                            } label: {
                                if viewModel.isLoadingTranscript {
                                    ProgressView()
                                        .frame(width: 20, height: 20)
                                } else {
                                    Text("Fetch")
                                }
                            }
                            .disabled(viewModel.isLoadingTranscript || videoUrl.isEmpty)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(videoUrl.isEmpty ? Color.appMuted : Color.primaryBrown)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding()
                    .background(Color.appCard)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Error Message
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.callout)
                            .foregroundStyle(.red)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Transcript Result
                    if let result = viewModel.transcriptResult {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("✅ Successfully fetched transcript!")
                                .font(.callout)
                                .foregroundStyle(.green)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.green.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            // Thumbnail
                            if let thumbnailUrl = result.thumbnailUrl {
                                AsyncImage(url: URL(string: thumbnailUrl)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                } placeholder: {
                                    ProgressView()
                                }
                            }

                            // Metadata
                            VStack(spacing: 12) {
                                if let videoId = result.videoId {
                                    MetadataCard(label: "Video ID", value: videoId)
                                }

                                if let wordCount = result.wordCount {
                                    MetadataCard(label: "Word Count", value: "\(wordCount.formatted()) words")
                                }

                                if let language = result.language {
                                    MetadataCard(label: "Language", value: language)
                                }

                                if let transcript = result.transcript {
                                    MetadataCard(label: "Characters", value: "\(transcript.count.formatted()) chars")
                                }
                            }

                            // Transcript Preview
                            if let transcript = result.transcript {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Transcript Preview")
                                        .font(.headline)

                                    ScrollView {
                                        Text(String(transcript.prefix(5000)))
                                            .font(.system(.caption, design: .monospaced))
                                            .foregroundStyle(Color.appMuted)
                                            .padding()
                                    }
                                    .frame(maxHeight: 300)
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))

                                    if transcript.count > 5000 {
                                        Text("...")
                                            .font(.caption)
                                            .foregroundStyle(Color.appMuted)
                                    }
                                }
                            }

                            // Extract Pattern Button
                            Button {
                                extractPattern()
                            } label: {
                                HStack {
                                    if viewModel.isExtractingPattern {
                                        ProgressView()
                                            .frame(width: 20, height: 20)
                                    } else {
                                        Image(systemName: "sparkles")
                                    }
                                    Text(viewModel.isExtractingPattern ? "Extracting Pattern with AI..." : "Extract Pattern with AI")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.primaryBrown)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .disabled(viewModel.isExtractingPattern)
                        }
                    }

                    // Extracted Pattern
                    if let pattern = viewModel.extractedPattern {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundStyle(Color.primaryBrown)
                                Text("Extracted Crochet Pattern")
                                    .font(.headline)
                            }

                            Text("AI-generated pattern from video transcript")
                                .font(.caption)
                                .foregroundStyle(Color.appMuted)

                            if let name = pattern.patternName {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Pattern Name:")
                                        .font(.caption)
                                        .foregroundStyle(Color.appMuted)
                                    Text(name)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                }
                            }

                            if let difficulty = pattern.difficultyLevel {
                                PatternDetailRow(label: "Difficulty", value: difficulty.capitalized)
                            }

                            if let materials = pattern.materials {
                                PatternDetailRow(label: "Materials", value: materials)
                            }

                            if let time = pattern.estimatedTime {
                                PatternDetailRow(label: "Estimated Time", value: time)
                            }

                            if let notation = pattern.patternNotation {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Pattern Notation:")
                                        .font(.caption)
                                        .foregroundStyle(Color.appMuted)
                                    Text(notation)
                                        .font(.system(.caption, design: .monospaced))
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.systemGray6))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }

                            if let instructions = pattern.patternInstructions {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Instructions:")
                                        .font(.caption)
                                        .foregroundStyle(Color.appMuted)

                                    ScrollView {
                                        Text(instructions.cleanedMarkdown)
                                            .font(.body)
                                            .textSelection(.enabled)
                                            .padding()
                                    }
                                    .frame(maxHeight: 400)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }

                            // Action Buttons
                            HStack(spacing: 12) {
                                Button {
                                    savePattern()
                                } label: {
                                    Text("Save to Library")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.appCard)
                                        .foregroundColor(Color.primaryBrown)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.primaryBrown, lineWidth: 1)
                                        )
                                }

                                Button {
                                    // Save and dismiss
                                    savePattern()
                                    dismiss()
                                } label: {
                                    Text("Start Project")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.primaryBrown)
                                        .foregroundColor(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                        .padding()
                        .background(Color.appCard)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primaryBrown, lineWidth: 2)
                        )
                    }
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("YouTube Transcript")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onTapGesture {
                isInputFocused = false
            }
        }
    }

    // MARK: - Actions

    private func fetchTranscript() {
        isInputFocused = false
        Task {
            await viewModel.fetchTranscript(videoUrl: videoUrl)
        }
    }

    private func extractPattern() {
        Task {
            await viewModel.extractPattern()
        }
    }

    private func savePattern() {
        Task {
            let success = await viewModel.savePatternToLibrary(patternViewModel: patternViewModel)
            if success {
                print("✅ Pattern saved to library")
                dismiss()
            }
        }
    }
}

// MARK: - Supporting Views

struct MetadataCard: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.appMuted)
            Text(value)
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.medium)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct PatternDetailRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(label):")
                .font(.caption)
                .foregroundStyle(Color.appMuted)
            Text(value)
                .font(.caption)
        }
    }
}

#Preview {
    YouTubeTranscriptView(patternViewModel: PatternViewModel())
}
