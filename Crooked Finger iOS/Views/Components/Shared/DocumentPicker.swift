//
//  DocumentPicker.swift
//  Crooked Finger iOS
//
//  Created by Claude Code on 10/8/25.
//

import SwiftUI
import UniformTypeIdentifiers
import PDFKit

/// Document picker for selecting image and PDF files from Files app
struct DocumentPicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedImages: [UIImage]
    var onDismiss: (() -> Void)? = nil

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // Specify supported file types explicitly for device compatibility
        let contentTypes: [UTType] = [
            .image,           // All image types
            .png,             // PNG images
            .jpeg,            // JPEG images
            .pdf              // PDF documents
        ]

        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: contentTypes,
            asCopy: true
        )
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            print("🔍 DocumentPicker: Selected \(urls.count) files")
            var images: [UIImage] = []

            for url in urls {
                print("🔍 Processing: \(url.lastPathComponent), extension: \(url.pathExtension)")

                // Start accessing security-scoped resource
                let didStartAccessing = url.startAccessingSecurityScopedResource()
                print("🔐 Security-scoped access: \(didStartAccessing)")

                // Some URLs (like those already in app sandbox) don't need security-scoped access
                // We'll defer stopping access only if we successfully started it
                defer {
                    if didStartAccessing {
                        url.stopAccessingSecurityScopedResource()
                    }
                }

                // Check if it's a PDF
                if url.pathExtension.lowercased() == "pdf" {
                    print("📄 Processing PDF: \(url.lastPathComponent)")
                    // Load PDF data into memory first (required for security-scoped resources on device)
                    do {
                        let pdfData = try Data(contentsOf: url)
                        print("📄 PDF data loaded: \(pdfData.count) bytes")

                        // Create PDF document from data instead of URL
                        if let pdfDocument = PDFDocument(data: pdfData) {
                            print("📄 PDF has \(pdfDocument.pageCount) pages")
                            for pageIndex in 0..<pdfDocument.pageCount {
                                if let page = pdfDocument.page(at: pageIndex) {
                                    let pageRect = page.bounds(for: .mediaBox)
                                    print("📄 Page \(pageIndex + 1) bounds: \(pageRect)")
                                    let renderer = UIGraphicsImageRenderer(size: pageRect.size)
                                    let image = renderer.image { ctx in
                                        UIColor.white.set()
                                        ctx.fill(pageRect)
                                        ctx.cgContext.translateBy(x: 0, y: pageRect.size.height)
                                        ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
                                        page.draw(with: .mediaBox, to: ctx.cgContext)
                                    }
                                    images.append(image)
                                    print("✅ Converted PDF page \(pageIndex + 1) to image, size: \(image.size)")
                                } else {
                                    print("❌ Failed to get page \(pageIndex + 1) from PDF")
                                }
                            }
                        } else {
                            print("❌ Failed to create PDF document from data")
                        }
                    } catch {
                        print("❌ Failed to load PDF data: \(error.localizedDescription)")
                    }
                } else {
                    print("🖼️ Processing image: \(url.lastPathComponent)")
                    // Load regular image from URL
                    if let data = try? Data(contentsOf: url),
                       let image = UIImage(data: data) {
                        images.append(image)
                        print("✅ Loaded image, size: \(image.size)")
                    } else {
                        print("❌ Failed to load image from: \(url.lastPathComponent)")
                    }
                }
            }

            print("📊 Total images converted: \(images.count)")
            DispatchQueue.main.async {
                print("📤 Appending \(images.count) images to selectedImages")
                self.parent.selectedImages.append(contentsOf: images)
                print("📤 Calling onDismiss and dismiss")
                self.parent.onDismiss?()
                self.parent.dismiss()
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.dismiss()
        }
    }
}
