import Foundation
import AVFoundation
import UIKit

/// Manages the camera session, permissions, camera switching and photo capture.
final class CameraManager: NSObject, ObservableObject {
    let session = AVCaptureSession()

    @Published var statusMessage: String = "Ready"
    @Published var permissionDenied = false
    @Published var isBusy = false
    @Published var lastSavedName: String = ""

    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private let processingQueue = DispatchQueue(label: "camera.processing.queue", qos: .userInitiated)
    private var currentInput: AVCaptureDeviceInput?
    private var position: AVCaptureDevice.Position = .back
    private var isConfigured = false
    private var pendingMP: Double = 5.0

    // MARK: - Start / permissions

    func start() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureAndRun()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.configureAndRun()
                    } else {
                        self.permissionDenied = true
                    }
                }
            }
        default:
            permissionDenied = true
        }
    }

    func stop() {
        sessionQueue.async {
            if self.session.isRunning { self.session.stopRunning() }
        }
    }

    private func configureAndRun() {
        sessionQueue.async {
            if !self.isConfigured {
                self.session.beginConfiguration()
                self.session.sessionPreset = .photo

                guard self.attachInput(position: self.position) else {
                    self.session.commitConfiguration()
                    DispatchQueue.main.async { self.statusMessage = "Camera not available" }
                    return
                }
                if self.session.canAddOutput(self.photoOutput) {
                    self.session.addOutput(self.photoOutput)
                }
                self.updateMaxDimensions()
                self.session.commitConfiguration()
                self.isConfigured = true
            }
            if !self.session.isRunning { self.session.startRunning() }
        }
    }

    /// Must be called inside begin/commitConfiguration. Replaces the current input.
    private func attachInput(position: AVCaptureDevice.Position) -> Bool {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
              let input = try? AVCaptureDeviceInput(device: device) else { return false }
        if let old = currentInput { session.removeInput(old) }
        if session.canAddInput(input) {
            session.addInput(input)
            currentInput = input
            return true
        }
        if let old = currentInput, session.canAddInput(old) { session.addInput(old) }
        return false
    }

    /// Allow the output to capture at the sensor's full resolution.
    private func updateMaxDimensions() {
        guard let device = currentInput?.device else { return }
        if let best = device.activeFormat.supportedMaxPhotoDimensions.last {
            photoOutput.maxPhotoDimensions = best
        }
    }

    // MARK: - Switch camera

    func switchCamera() {
        sessionQueue.async {
            guard self.isConfigured else { return }
            let newPosition: AVCaptureDevice.Position = (self.position == .back) ? .front : .back
            self.session.beginConfiguration()
            if self.attachInput(position: newPosition) {
                self.position = newPosition
                self.updateMaxDimensions()
            }
            self.session.commitConfiguration()
        }
    }

    // MARK: - Capture

    func capturePhoto(targetMP: Double) {
        guard !isBusy else { return }
        isBusy = true
        statusMessage = "Capturing..."
        pendingMP = targetMP

        sessionQueue.async {
            let settings = AVCapturePhotoSettings()
            if self.photoOutput.maxPhotoDimensions.width > 0 {
                settings.maxPhotoDimensions = self.photoOutput.maxPhotoDimensions
            }
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    private func finish(_ message: String, saved: String? = nil) {
        DispatchQueue.main.async {
            self.statusMessage = message
            if let saved = saved { self.lastSavedName = saved }
            self.isBusy = false
        }
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        let mp = pendingMP
        if let error = error {
            finish("Capture failed: \(error.localizedDescription)")
            return
        }
        guard let data = photo.fileDataRepresentation() else {
            finish("Capture failed")
            return
        }

        processingQueue.async {
            guard let image = UIImage(data: data) else {
                self.finish("Could not read photo")
                return
            }
            guard let jpeg = ResolutionEngine.resizeToMegapixels(image: image, targetMP: mp).1 else {
                self.finish("Compression failed")
                return
            }

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd_HHmmss"
            let mpText = String(format: "%g", mp)
            let fileName = "QC_\(mpText)MP_\(formatter.string(from: Date())).jpg"

            if FileExporter.saveToDocuments(data: jpeg, fileName: fileName) != nil {
                self.finish("Saved \(mpText) MP to Files", saved: fileName)
            } else {
                self.finish("Failed to save file")
            }
        }
    }
}
