import SwiftUI

struct FoodAnalysisView: View {
    @StateObject private var viewModel: FoodAnalysisViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(imageData: Data, apiKey: String) {
        _viewModel = StateObject(wrappedValue: FoodAnalysisViewModel(imageData: imageData, apiKey: apiKey))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if let imageData = viewModel.imageData,
                   let uiImage = UIImage(data: imageData) {
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
                } else if let error = viewModel.error {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text(error.localizedDescription)
                            .multilineTextAlignment(.center)
                            .padding()
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
                
                if !viewModel.ingredients.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
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
        }
    }
} 