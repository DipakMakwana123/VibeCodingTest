import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var viewModel: CameraViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: CameraViewModel())
    }
    
    var body: some View {
        ZStack {
            // Camera preview
            CameraPreviewView(session: viewModel.session)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Camera controls
                HStack(spacing: 60) {
                    Button(action: {
                        viewModel.switchCamera()
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .font(.system(size: 24))
                            .foregroundColor(Color.systemBackground)
                    }
                    
                    Button(action: {
                        viewModel.capturePhoto()
                    }) {
                        Circle()
                            .strokeBorder(Color.systemBackground, lineWidth: 3)
                            .frame(width: 70, height: 70)
                    }
                    
                    Button(action: {
                        // TODO: Open photo library
                    }) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 24))
                            .foregroundColor(Color.systemBackground)
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .background(Color.black) // Camera background should always be black
        .onAppear {
            viewModel.checkCameraPermission()
        }
        .alert("Camera Access Required", isPresented: $viewModel.showPermissionAlert) {
            Button("Settings", role: .cancel) {
                viewModel.openSettings()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please allow camera access in Settings to use this feature.")
        }
        .sheet(isPresented: $viewModel.showingAnalysis) {
            if let imageData = viewModel.capturedImageData {
                FoodAnalysisView(imageData: imageData)
            }
        }
    }
}

// Camera Preview View using UIViewRepresentable
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

#Preview {
    CameraView()
} 