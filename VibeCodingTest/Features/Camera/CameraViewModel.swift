import AVFoundation
import SwiftUI

@MainActor
class CameraViewModel: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var isSessionRunning = false
    @Published var error: Error?
    @Published var showPermissionAlert = false
    @Published var capturedImageData: Data?
    
    private var deviceInput: AVCaptureDeviceInput?
    private let photoOutput = AVCapturePhotoOutput()
    private var position: AVCaptureDevice.Position = .back
    private var isCameraAuthorized = false
    private var isConfigured = false
    let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
        super.init()
        checkPermission()
    }
    
    private func checkPermission() {
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
        
        do {
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                          for: .video,
                                                          position: position) else {
                print("Failed to get camera device")
                return
            }
            
            deviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if session.canAddInput(deviceInput!) {
                session.addInput(deviceInput!)
            }
            
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            }
            
            session.commitConfiguration()
            isConfigured = true
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.startRunning()
                DispatchQueue.main.async {
                    self?.isSessionRunning = true
                }
            }
            
            print("Camera setup completed successfully")
        } catch {
            print("Error setting up camera: \(error.localizedDescription)")
            self.error = error
        }
    }
    
    func switchCamera() {
        print("Switching camera...")
        session.beginConfiguration()
        
        // Remove existing input
        if let input = session.inputs.first {
            session.removeInput(input)
        }
        
        // Toggle camera position
        position = position == .back ? .front : .back
        
        do {
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                          for: .video,
                                                          position: position) else { return }
            
            let newInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if session.canAddInput(newInput) {
                session.addInput(newInput)
                deviceInput = newInput
            }
            
            session.commitConfiguration()
            print("Camera switched successfully")
        } catch {
            print("Error switching camera: \(error.localizedDescription)")
            self.error = error
        }
    }
    
    func capturePhoto(completion: @escaping (Result<Data, Error>) -> Void) {
        print("Capturing photo...")
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: PhotoCaptureProcessor(completion: { [weak self] result in
            if case .success(let data) = result {
                self?.capturedImageData = data
            }
            completion(result)
        }))
    }
    
    func openSettings() {
        print("Opening app settings...")
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

class PhotoCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (Result<Data, Error>) -> Void
    
    init(completion: @escaping (Result<Data, Error>) -> Void) {
        self.completion = completion
        super.init()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("Failed to get image data")
            completion(.failure(NSError(domain: "CameraError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get image data"])))
            return
        }
        
        print("Photo captured successfully")
        completion(.success(imageData))
    }
} 