import SwiftUI

public struct ContentView: View {
    @State private var selectedMP: Double = 5.0
    private let presets: [Double] = [8.0, 5.0, 3.0, 1.0, 0.3]
    
    // Instantiate our camera manager
    @StateObject private var cameraManagerWrapper = CameraManagerWrapper()
    @State private var statusMessage: String = "Ready"
    
    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                // Top Bar: Resolution Selector
                Picker("Resolution", selection: $selectedMP) {
                    ForEach(presets, id: \.self) { mp in
                        Text("\(String(format: "%.1f", mp)) MP").tag(mp)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                
                // Status / Viewfinder Center Indicator
                VStack(spacing: 8) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.4))
                    Text(statusMessage)
                        .foregroundColor(.white.opacity(0.8))
                        .font(.caption)
                }
                
                Spacer()
                
                // Bottom Controls: Yellow Shutter Button
                HStack {
                    Spacer()
                    
                    Button(action: {
                        triggerCaptureAndProcess()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.yellow)
                                .frame(width: 82, height: 82)
                                .shadow(color: Color.yellow.opacity(0.4), radius: 8, x: 0, y: 4)
                            
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 70, height: 70)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            cameraManagerWrapper.setupCamera()
        }
    }
    
    private func triggerCaptureAndProcess() {
        statusMessage = "Capturing..."
        
        cameraManagerWrapper.manager.onPhotoCaptured = { rawImage in
            statusMessage = "Resizing to \(selectedMP) MP..."
            
            // 1. Resize via ResolutionEngine
            let (_, jpegData) = ResolutionEngine.resizeToMegapixels(image: rawImage, targetMP: selectedMP)
            
            guard let data = jpegData else {
                statusMessage = "Compression failed."
                return
            }
            
            // 2. Generate unique filename with timestamp
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd_HHmmss"
            let timestamp = formatter.string(from: Date())
            let fileName = "QC_\(selectedMP)MP_\(timestamp).jpg"
            
            // 3. Save to Files app directory via FileExporter
            if let savedURL = FileExporter.saveToDocuments(data: data, fileName: fileName) {
                statusMessage = "Saved to Files App!"
                print("Successfully saved to: \(savedURL.path)")
            } else {
                statusMessage = "Failed to save file."
            }
        }
        
        // Trigger the shutter capture
        cameraManagerWrapper.manager.capturePhoto()
    }
}

// Helper wrapper to handle lifecycle observation for SwiftUI
class CameraManagerWrapper: ObservableObject {
    let manager = CameraManager()
    
    func setupCamera() {
        manager.configureSession { success in
            if !success {
                print("Camera session configuration failed.")
            }
        }
    }
}