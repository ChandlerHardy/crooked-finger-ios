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

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TabView(selection: $currentIndex) {
                ForEach(Array(images.enumerated()), id: \.offset) { index, base64String in
                    ZoomableImageView(base64String: base64String)
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
    }
}

/// Individual zoomable image view for use within TabView
private struct ZoomableImageView: View {
    let base64String: String

    @State private var uiImage: UIImage?
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @GestureState private var dragState: CGSize = .zero

    var body: some View {
        Group {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .offset(x: offset.width + dragState.width, y: offset.height + dragState.height)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = min(max(lastScale * value, 1), 5)
                            }
                            .onEnded { value in
                                lastScale = scale
                                if scale < 1 {
                                    withAnimation(.spring(response: 0.3)) {
                                        scale = 1
                                        lastScale = 1
                                    }
                                }
                            }
                    )
                    .simultaneousGesture(
                        DragGesture()
                            .updating($dragState) { value, state, _ in
                                if scale > 1 {
                                    state = value.translation
                                }
                            }
                            .onEnded { value in
                                if scale > 1 {
                                    offset.width += value.translation.width
                                    offset.height += value.translation.height
                                }
                            }
                    )
                    .onTapGesture(count: 2) {
                        // Double tap to reset zoom
                        withAnimation(.spring(response: 0.3)) {
                            scale = 1.0
                            lastScale = 1.0
                            offset = .zero
                        }
                    }
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
            }
        }
        .task {
            // Load image once
            if uiImage == nil {
                uiImage = await Task.detached(priority: .userInitiated) { @Sendable in
                    ImageService.shared.base64ToImage(base64String: base64String)
                }.value
            }
        }
    }
}
