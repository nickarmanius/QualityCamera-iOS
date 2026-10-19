import Foundation

public struct FileExporter {
    
    /// Saves image data directly to the local app Documents directory (accessible via Files app).
    /// - Parameters:
    ///   - data: Image data.
    ///   - fileName: Desired file name (e.g., "Photo_5MP.jpg").
    /// - Returns: URL of the saved file if successful.
    public static func saveToDocuments(data: Data, fileName: String) -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Failed to save file: \(error.localizedDescription)")
            return nil
        }
    }
}
