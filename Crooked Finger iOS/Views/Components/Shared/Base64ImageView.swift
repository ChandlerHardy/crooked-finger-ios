//
//  Base64ImageView.swift
//  Crooked Finger iOS
//
//  Created by Claude Code on 10/4/25.
//

import SwiftUI

/// Display an image from a base64 encoded string
struct Base64ImageView: View {
    let base64String: String
    let contentMode: ContentMode

    @State private var uiImage: UIImage?
    @State private var isLoading = true

    init(base64String: String, contentMode: ContentMode = .fill) {
        self.base64String = base64String
        self.contentMode = contentMode
    }

    var body: some View {
        Group {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.gray.opacity(0.1))
            } else {
                // Error state - show placeholder
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.gray.opacity(0.1))
            }
        }
        .task {
            await loadImage()
        }
    }

    private func loadImage() async {
        // Decode on background thread
        let base64 = base64String
        let image = await Task.detached(priority: .userInitiated) { @Sendable in
            ImageService.shared.base64ToImage(base64String: base64)
        }.value

        await MainActor.run {
            self.uiImage = image
            self.isLoading = false
        }
    }
}

/// Image gallery grid view for displaying multiple base64 images
struct Base64ImageGallery: View {
    let images: [String]
    let columns: [GridItem]
    let onImageTap: (Int) -> Void
    let onDeleteImage: ((Int) -> Void)?

    init(
        images: [String],
        columns: Int = 3,
        onImageTap: @escaping (Int) -> Void,
        onDeleteImage: ((Int) -> Void)? = nil
    ) {
        self.images = images
        self.columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: columns)
        self.onImageTap = onImageTap
        self.onDeleteImage = onDeleteImage
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(images.enumerated()), id: \.offset) { index, base64String in
                ZStack(alignment: .topTrailing) {
                    Base64ImageView(base64String: base64String)
                        .frame(height: 120)
                        .cornerRadius(8)
                        .clipped()
                        .onTapGesture {
                            onImageTap(index)
                        }

                    // Delete button if deletion is enabled
                    if let onDeleteImage = onDeleteImage {
                        Button {
                            onDeleteImage(index)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                                .background(Circle().fill(Color.black.opacity(0.6)))
                        }
                        .padding(8)
                    }
                }
            }
        }
    }
}

/// Fullscreen image viewer with swipe navigation
struct Base64ImageViewer: View {
    let images: [String]
    @Binding var currentIndex: Int
    @Environment(\.dismiss) private var dismiss

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TabView(selection: $currentIndex) {
                ForEach(Array(images.enumerated()), id: \.offset) { index, base64String in
                    Base64ImageView(base64String: base64String, contentMode: .fit)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let delta = value / lastScale
                                    lastScale = value
                                    scale = min(max(scale * delta, 1), 5)
                                }
                                .onEnded { _ in
                                    lastScale = 1.0
                                    if scale < 1 {
                                        withAnimation {
                                            scale = 1
                                        }
                                    }
                                }
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if scale > 1 {
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }

            // Image counter
            VStack {
                Spacer()
                Text("\(currentIndex + 1) / \(images.count)")
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(20)
                    .padding(.bottom, 50)
            }
        }
        .onChange(of: currentIndex) {
            // Reset zoom when changing images
            withAnimation {
                scale = 1.0
                offset = .zero
                lastOffset = .zero
            }
        }
    }
}
