import Foundation
import AVFoundation
import UIKit

/// Manages the camera session, device inputs, and photo capturing.
public class CameraManager: NSObject {
    public let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    public var onPhotoCaptured: ((UIImage) -> Void)?

    public override init() {
        super.init()
    }

    public func configureSession(completion: @escaping (Bool) -> Void) {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo

            // Configure back camera
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
                  self.session.canAddInput(videoDeviceInput) else {
                self.session.commitConfiguration()
                DispatchQueue.main.async { completion(false) }
                return
            }

            self.session.addInput(videoDeviceInput)

            // Configure photo output
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
                self.photoOutput.isHighResolutionCaptureEnabled = true
            }

            self.session.commitConfiguration()
            self.session.startRunning()
            DispatchQueue.main.async { completion(true) }
        }
    }

    public func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.isHighResolutionPhotoEnabled = true
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil, let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) else {
            return
        }
        DispatchQueue.main.async {
            self.onPhotoCaptured?(image)
        }
    }
}
