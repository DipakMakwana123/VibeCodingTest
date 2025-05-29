import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var viewModel: CameraViewModel
    @State private var showingAnalysis = false
    
    init(apiKey: String) {
        _viewModel = StateObject(wrappedValue: CameraViewModel(apiKey: apiKey))
    }
    
    var body: some View {
        ZStack {
            // Camera Preview
            if viewModel.isSessionRunning {
                CameraPreviewView(session: viewModel.session)
                    .ignoresSafeArea()
            }
            
            // Controls Overlay
            VStack {
                Spacer()
                
                HStack {
                    // Switch Camera Button
                    Button(action: viewModel.switchCamera) {
                        Image(systemName: "camera.rotate")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Capture Button
                    Button(action: {
                        viewModel.capturePhoto { result in
                            switch result {
                            case .success(let imageData):
                                showingAnalysis = true
                            case .failure(let error):
                                print("Failed to capture photo: \(error.localizedDescription)")
                            }
                        }
                    }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle()
                                    .stroke(Color.black.opacity(0.8), lineWidth: 2)
                            )
                            .padding()
                    }
                    
                    Spacer()
                    
                    // Placeholder for symmetry
                    Color.clear
                        .frame(width: 50, height: 50)
                        .padding()
                }
                .padding(.bottom)
            }
        }
        .alert("Camera Access Required", isPresented: $viewModel.showPermissionAlert) {
            Button("Settings", action: viewModel.openSettings)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please grant camera access in Settings to use this feature.")
        }
        .sheet(isPresented: $showingAnalysis) {
            if let imageData = viewModel.capturedImageData {
                FoodAnalysisView(imageData: imageData, apiKey: viewModel.apiKey)
            }
        }
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = .black
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.frame
        }
    }
} 