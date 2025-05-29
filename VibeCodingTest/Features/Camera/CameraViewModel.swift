import AVFoundation
import SwiftUI

@MainActor
class CameraViewModel: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var isSessionRunning = false
    @Published var error: Error?
    @Published var showPermissionAlert = false
    @Published var capturedImageData: Data?
    @Published var showingAnalysis = false
    
    private var deviceInput: AVCaptureDeviceInput?
    private let photoOutput = AVCapturePhotoOutput()
    private var position: AVCaptureDevice.Position = .back
    private var isCameraAuthorized = false
    private var isConfigured = false
    private var setupTask: Task<Void, Never>?

    override init() {
        super.init()
        checkCameraPermission()
    }
    
    deinit {
        setupTask?.cancel()
        Task {
            await stopCameraSession()
        }
    }
    
    private func stopCameraSession() {
        if session.isRunning {
            session.stopRunning()
            isSessionRunning = false
        }
    }
    
    func checkCameraPermission() {
        print("Checking camera permission...")
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("Camera access authorized")
            isCameraAuthorized = true
            setupCamera()
        case .notDetermined:
            print("Camera authorization not determined, requesting...")
            Task {
                if await requestCameraAccess() {
                    isCameraAuthorized = true
                    setupCamera()
                }
            }
        case .denied, .restricted:
            print("Camera access denied or restricted")
            showPermissionAlert = true
        @unknown default:
            print("Unknown camera authorization status")
        }
    }
    
    private func requestCameraAccess() async -> Bool {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                continuation.resume(returning: granted)
            }
        }
    }
    
    func setupCamera() {
        guard !isConfigured else { return }
        
        print("Setting up camera session...")
        session.beginConfiguration()
        
        // Add video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                      for: .video,
                                                      position: position) else {
            print("Failed to get camera device")
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
                deviceInput = videoInput
            }
            
            // Add photo output
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            }
            
            session.commitConfiguration()
            isConfigured = true
            
            Task {
                session.startRunning()
            }
            
            print("Camera setup completed successfully")
        } catch {
            print("Error setting up camera: \(error.localizedDescription)")
        }
    }
    
    func switchCamera() {
        print("Switching camera...")
        guard let currentInput = deviceInput else { return }
              let currentPosition = currentInput.device.position
        
        let newPosition: AVCaptureDevice.Position = currentPosition == .back ? .front : .back
        guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                    for: .video,
                                                    position: newPosition) else { return }
        
        session.beginConfiguration()
        session.removeInput(currentInput)
        
        do {
            let newInput = try AVCaptureDeviceInput(device: newDevice)
            if session.canAddInput(newInput) {
                session.addInput(newInput)
                deviceInput = newInput
            }
            session.commitConfiguration()
            print("Camera switched successfully")
        } catch {
            print("Error switching camera: \(error.localizedDescription)")
            session.addInput(currentInput)
            session.commitConfiguration()
        }
    }
    
    func capturePhoto() {
        print("Capturing photo...")
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func openSettings() {
        print("Opening app settings...")
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            Task { @MainActor in
                await UIApplication.shared.open(settingsUrl)
            }
        }
    }
}

extension CameraViewModel: @preconcurrency AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("Failed to get image data")
            return
        }
        
        print("Photo captured successfully")
        self.capturedImageData = imageData
        self.showingAnalysis = true
    }
} 
