import SwiftUI

public struct ContentView: View {
    // Track selected Megapixel tier (defaults to 5MP)
    @State private var selectedMP: Double = 5.0
    private let presets: [Double] = [8.0, 5.0, 3.0, 1.0, 0.3]
    
    public var body: some View {
        ZStack {
            // Dark Camera Viewfinder Background
            Color.black
                .ignoresSafeArea()
            
            VStack {
                // Top Bar: Megapixel Resolution Selector
                Picker("Resolution", selection: $selectedMP) {
                    ForEach(presets, id: \.self) { mp in
                        Text("\(String(format: "%.1f", mp)) MP").tag(mp)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                
                // Viewfinder Center Indicator
                VStack(spacing: 8) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.4))
                    Text("Ready • Target: \(String(format: "%.1f", mpFormat(selectedMP))) MP")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.caption)
                }
                
                Spacer()
                
                // Bottom Controls: Yellow Shutter Button
                HStack {
                    Spacer()
                    
                    // Distinct Yellow Shutter Button
                    Button(action: {
                        triggerCapture()
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
    }
    
    private func mpFormat(_ value: Double) -> String {
        return value == 1.0 || value == 3.0 || value == 5.0 || value == 8.0 ? String(format: "%.0f", value) : String(format: "%.1f", value)
    }
    
    private func triggerCapture() {
        print("Shutter clicked! Capturing at \(selectedMP) MP target.")
        // Here is where you will call CameraManager and pass the output to ResolutionEngine
    }
}