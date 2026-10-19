import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var camera = CameraManager()
    @State private var selectedMP: Double = 5.0
    private let presets: [Double] = [8.0, 5.0, 3.0, 1.0, 0.3]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if camera.permissionDenied {
                permissionView
            } else {
                // Live viewfinder
                CameraPreview(session: camera.session)
                    .ignoresSafeArea()

                VStack {
                    // Top: resolution selector
                    Picker("Resolution", selection: $selectedMP) {
                        ForEach(presets, id: \.self) { mp in
                            Text("\(String(format: "%g", mp)) MP").tag(mp)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(6)
                    .background(Color.black.opacity(0.45))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    Spacer()

                    // Status line
                    Text(camera.statusMessage)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                        .padding(.bottom, 12)

                    // Bottom: shutter + switch camera
                    ZStack {
                        Button(action: { camera.capturePhoto(targetMP: selectedMP) }) {
                            ZStack {
                                Circle()
                                    .fill(Color.yellow)
                                    .frame(width: 82, height: 82)
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                                    .frame(width: 92, height: 92)
                            }
                            .opacity(camera.isBusy ? 0.5 : 1.0)
                        }
                        .disabled(camera.isBusy)

                        HStack {
                            Spacer()
                            Button(action: { camera.switchCamera() }) {
                                Image(systemName: "arrow.triangle.2.circlepath.camera")
                                    .font(.system(size: 26))
                                    .foregroundColor(.white)
                                    .frame(width: 56, height: 56)
                                    .background(Color.black.opacity(0.45))
                                    .clipShape(Circle())
                            }
                            .padding(.trailing, 28)
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .onAppear { camera.start() }
        .onDisappear { camera.stop() }
    }

    private var permissionView: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.6))
            Text("Camera access is turned off")
                .font(.headline)
                .foregroundColor(.white)
            Text("Open Settings > Quality Camera and allow Camera.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(Color.yellow)
            .foregroundColor(.black)
            .cornerRadius(10)
        }
        .padding(32)
    }
}
