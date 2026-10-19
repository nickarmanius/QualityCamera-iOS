import UIKit

public struct ResolutionEngine {
    
    /// Resizes a captured image to match a target Megapixel (MP) count.
    /// - Parameters:
    ///   - image: The raw captured UIImage.
    ///   - targetMP: Desired Megapixels (e.g., 8.0, 5.0, 3.0, 1.0, 0.3).
    /// - Returns: Resized UIImage matching roughly the target pixel count, and its JPEG data representation.
    public static func resizeToMegapixels(image: UIImage, targetMP: Double) -> (UIImage?, Data?) {
        let targetPixels = targetMP * 1_000_000
        let currentPixels = image.size.width * image.size.height
        
        let targetImage: UIImage
        if currentPixels <= targetPixels {
            targetImage = image
        } else {
            let scaleFactor = sqrt(targetPixels / currentPixels)
            let newWidth = image.size.width * scaleFactor
            let newHeight = image.size.height * scaleFactor
            let newSize = CGSize(width: newWidth, height: newHeight)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            targetImage = resizedImage ?? image
        }
        
        let jpegData = targetImage.jpegData(compressionQuality: 0.9)
        return (targetImage, jpegData)
    }
}
