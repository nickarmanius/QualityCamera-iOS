import Foundation

struct FileExporter {

    /// Saves image data into the app's Documents folder (visible in the Files app:
    /// On My iPhone > Quality Camera).
    static func saveToDocuments(data: Data, fileName: String) -> URL? {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let url = dir.appendingPathComponent(fileName)
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            print("Failed to save file: \(error.localizedDescription)")
            return nil
        }
    }
}
