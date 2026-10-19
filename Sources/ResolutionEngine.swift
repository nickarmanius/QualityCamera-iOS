import UIKit

struct ResolutionEngine {

    /// Resizes a captured image so it has roughly `targetMP` megapixels (never upscales).
    /// Returns the resized image and its JPEG data.
    static func resizeToMegapixels(image: UIImage, targetMP: Double) -> (UIImage?, Data?) {
        let targetPixels = targetMP * 1_000_000
        // image.size is in points; with scale 1 (photo data) this equals pixels.
        let pixelW = image.size.width * image.scale
        let pixelH = image.size.height * image.scale
        let currentPixels = pixelW * pixelH

        var result = image
        if currentPixels > targetPixels {
            let factor = (targetPixels / currentPixels).squareRoot()
            let newSize = CGSize(width: (pixelW * factor).rounded(),
                                 height: (pixelH * factor).rounded())
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1          // 1 point = 1 real pixel
            format.opaque = true
            let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
            // draw(in:) respects the photo's orientation, so the result is upright.
            result = renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: newSize))
            }
        } else {
            // Keep original size but bake in orientation so every viewer shows it upright.
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            format.opaque = true
            let size = CGSize(width: pixelW, height: pixelH)
            result = UIGraphicsImageRenderer(size: size, format: format).image { _ in
                image.draw(in: CGRect(origin: .zero, size: size))
            }
        }
        return (result, result.jpegData(compressionQuality: 0.9))
    }
}
