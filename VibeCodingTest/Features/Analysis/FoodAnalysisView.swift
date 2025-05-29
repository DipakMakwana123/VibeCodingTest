import SwiftUI

struct FoodAnalysisView: View {
    @StateObject private var viewModel: FoodAnalysisViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(imageData: Data) {
        _viewModel = StateObject(wrappedValue: FoodAnalysisViewModel(imageData: imageData))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if let uiImage = UIImage(data: viewModel.imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .padding()
                }
                
                if viewModel.isAnalyzing {
                    ProgressView("Analyzing food...")
                        .padding()
                } else if !viewModel.ingredients.isEmpty {
                    List {
                        Section("Ingredients") {
                            ForEach(viewModel.ingredients, id: \.self) { ingredient in
                                Text(ingredient)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Food Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !viewModel.ingredients.isEmpty {
                        Button("Save") {
                            viewModel.saveAnalysis()
                            dismiss()
                        }
                    }
                }
            }
            .task {
                await viewModel.analyzeFood()
            }
            .overlay {
                if viewModel.showError, let error = viewModel.error {
                    ToastView(
                        message: "Error",
                        systemImage: "exclamationmark.triangle",
                        description: error.localizedDescription
                    )
                    .onTapGesture {
                        viewModel.showError = false
                    }
                }
            }
        }
    }
}

#Preview {
    FoodAnalysisView(imageData: Data())
} 