//
//  ImageService.swift
//  Crooked Finger iOS
//
//  Created by Claude Code on 10/4/25.
//

import UIKit

/// Service for handling image compression, encoding, and decoding
class ImageService {
    static let shared = ImageService()

    private init() {}

    /// Maximum image dimension (width or height) before compression
    private let maxDimension: CGFloat = 1920

    /// JPEG compression quality (0.0 - 1.0)
    private let compressionQuality: CGFloat = 0.8

    /// Convert UIImage to base64 string with compression
    /// - Parameter image: The image to convert
    /// - Returns: Base64 encoded string, or nil if conversion fails
    func imageToBase64(image: UIImage) -> String? {
        // Resize image if needed
        let resizedImage = resizeImage(image: image, maxDimension: maxDimension)

        // Convert to JPEG data with compression
        guard let imageData = resizedImage.jpegData(compressionQuality: compressionQuality) else {
            print("❌ Failed to convert image to JPEG data")
            return nil
        }

        // Convert to base64
        let base64String = imageData.base64EncodedString()

        // Log size info
        let originalSize = (image.pngData()?.count ?? 0) / 1024
        let compressedSize = imageData.count / 1024
        print("📸 Image compressed: \(originalSize)KB → \(compressedSize)KB (ratio: \(String(format: "%.1f", Double(compressedSize) / Double(max(originalSize, 1)) * 100))%)")

        return base64String
    }

    /// Convert base64 string to UIImage
    /// - Parameter base64String: The base64 encoded string
    /// - Returns: UIImage, or nil if decoding fails
    func base64ToImage(base64String: String) -> UIImage? {
        guard let imageData = Data(base64Encoded: base64String) else {
            print("❌ Failed to decode base64 string")
            return nil
        }

        guard let image = UIImage(data: imageData) else {
            print("❌ Failed to create image from data")
            return nil
        }

        return image
    }

    /// Resize image to fit within max dimension while maintaining aspect ratio
    /// - Parameters:
    ///   - image: The image to resize
    ///   - maxDimension: Maximum width or height
    /// - Returns: Resized image
    private func resizeImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size

        // Check if resize is needed
        if size.width <= maxDimension && size.height <= maxDimension {
            return image
        }

        // Calculate new size maintaining aspect ratio
        let aspectRatio = size.width / size.height
        var newSize: CGSize

        if size.width > size.height {
            // Landscape
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            // Portrait or square
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }

        // Resize the image
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage ?? image
    }

    /// Convert array of UIImages to JSON array of base64 strings
    /// - Parameter images: Array of images
    /// - Returns: JSON string of base64 array, or nil if conversion fails
    func imagesToJSON(images: [UIImage]) -> String? {
        let base64Strings = images.compactMap { imageToBase64(image: $0) }

        guard let jsonData = try? JSONEncoder().encode(base64Strings),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("❌ Failed to encode images to JSON")
            return nil
        }

        return jsonString
    }

    /// Convert JSON array of base64 strings to UIImages
    /// - Parameter jsonString: JSON string containing base64 array
    /// - Returns: Array of UIImages
    func jsonToImages(jsonString: String?) -> [UIImage] {
        guard let jsonString = jsonString,
              let jsonData = jsonString.data(using: .utf8),
              let base64Strings = try? JSONDecoder().decode([String].self, from: jsonData) else {
            return []
        }

        return base64Strings.compactMap { base64ToImage(base64String: $0) }
    }

    /// Calculate estimated memory size of base64 string in KB
    /// - Parameter base64String: The base64 string
    /// - Returns: Size in KB
    func estimateSize(base64String: String) -> Int {
        return base64String.count / 1024
    }
}
