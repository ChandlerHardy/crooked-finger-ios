//
//  ImagePicker.swift
//  Crooked Finger iOS
//
//  Created by Claude Code on 10/4/25.
//

import SwiftUI
import PhotosUI

/// Image picker for selecting photos from library or camera
struct ImagePicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedImages: [UIImage]
    let maxSelection: Int

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showCamera = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Camera option
                Button {
                    showCamera = true
                } label: {
                    Label("Take Photo", systemImage: "camera.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primaryBrown)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                // Photo library picker
                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: maxSelection,
                    matching: .images
                ) {
                    Label("Choose from Library", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primaryBrown.opacity(0.1))
                        .foregroundStyle(Color.primaryBrown)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .onChange(of: selectedItems) {
                    loadSelectedPhotos()
                }

                Spacer()
            }
            .padding(.top)
            .navigationTitle("Add Photos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraView { image in
                    selectedImages.append(image)
                    dismiss()
                }
            }
        }
    }

    private func loadSelectedPhotos() {
        Task {
            var images: [UIImage] = []

            for item in selectedItems {
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

/// Camera view using UIImagePickerController
struct CameraView: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageCaptured(image)
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
