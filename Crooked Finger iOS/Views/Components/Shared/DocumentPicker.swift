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
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.image, .pdf],
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
            var images: [UIImage] = []

            for url in urls {
                // Start accessing security-scoped resource
                guard url.startAccessingSecurityScopedResource() else {
                    continue
                }
                defer {
                    url.stopAccessingSecurityScopedResource()
                }

                // Check if it's a PDF
                if url.pathExtension.lowercased() == "pdf" {
                    print("📄 Processing PDF: \(url.lastPathComponent)")
                    // Convert PDF pages to images
                    if let pdfDocument = PDFDocument(url: url) {
                        print("📄 PDF has \(pdfDocument.pageCount) pages")
                        for pageIndex in 0..<pdfDocument.pageCount {
                            if let page = pdfDocument.page(at: pageIndex) {
                                let pageRect = page.bounds(for: .mediaBox)
                                let renderer = UIGraphicsImageRenderer(size: pageRect.size)
                                let image = renderer.image { ctx in
                                    UIColor.white.set()
                                    ctx.fill(pageRect)
                                    ctx.cgContext.translateBy(x: 0, y: pageRect.size.height)
                                    ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
                                    page.draw(with: .mediaBox, to: ctx.cgContext)
                                }
                                images.append(image)
                                print("✅ Converted PDF page \(pageIndex + 1) to image")
                            }
                        }
                    } else {
                        print("❌ Failed to open PDF document")
                    }
                } else {
                    // Load regular image from URL
                    if let data = try? Data(contentsOf: url),
                       let image = UIImage(data: data) {
                        images.append(image)
                    }
                }
            }

            DispatchQueue.main.async {
                self.parent.selectedImages.append(contentsOf: images)
                self.parent.onDismiss?()
                self.parent.dismiss()
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.dismiss()
        }
    }
}
