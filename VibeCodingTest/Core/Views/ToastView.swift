import SwiftUI

struct ToastView: View {
    let message: String
    let systemImage: String
    let description: String?
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            if let description = description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 6)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.3))
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ToastView(
        message: "API Key Missing",
        systemImage: "exclamationmark.triangle",
        description: "Please add your OpenAI API key to Config.plist"
    )
} 