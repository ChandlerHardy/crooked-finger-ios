//
//  MediaPickerView.swift
//  Crooked Finger iOS
//
//  Created by Claude Code on 10/8/25.
//

import SwiftUI
import PhotosUI

/// Combined media picker with options for photo library, camera, and files
struct MediaPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedImages: [UIImage]

    @State private var showPhotoPicker = false
    @State private var showDocumentPicker = false
    @State private var showCamera = false
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var documentPickerImageCount = 0

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        showCamera = true
                    } label: {
                        Label("Take Photo", systemImage: "camera.fill")
                            .foregroundStyle(Color.primaryBrown)
                    }

                    Button {
                        showPhotoPicker = true
                    } label: {
                        Label("Photo Library", systemImage: "photo.on.rectangle")
                            .foregroundStyle(Color.primaryBrown)
                    }

                    Button {
                        showDocumentPicker = true
                    } label: {
                        Label("Browse Files", systemImage: "folder")
                            .foregroundStyle(Color.primaryBrown)
                    }
                }
            }
            .navigationTitle("Add Media")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView { image in
                selectedImages.append(image)
                dismiss()
            }
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotoItems, maxSelectionCount: 5, matching: .images)
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(selectedImages: $selectedImages, onDismiss: {
                dismiss()
            })
        }
        .onAppear {
            documentPickerImageCount = selectedImages.count
        }
        .onChange(of: selectedImages.count) { oldCount, newCount in
            print("🎯 MediaPickerView: selectedImages count changed from \(oldCount) to \(newCount)")
            // If images were added (from any source), dismiss
            if newCount > oldCount {
                print("✅ MediaPickerView: Dismissing (images added)")
                dismiss()
            }
        }
        .onChange(of: selectedPhotoItems) { _, items in
            Task {
                var images: [UIImage] = []
                for item in items {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        images.append(image)
                    }
                }
                await MainActor.run {
                    selectedImages.append(contentsOf: images)
                    dismiss()
                }
            }
        }
    }
}
