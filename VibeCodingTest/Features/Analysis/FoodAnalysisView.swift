import SwiftUI

struct FoodAnalysisView: View {
    @StateObject private var viewModel: FoodAnalysisViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(imageData: Data, apiKey: String) {
        _viewModel = StateObject(wrappedValue: FoodAnalysisViewModel(imageData: imageData, apiKey: apiKey))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let image = UIImage(data: viewModel.imageData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                    }
                    
                    switch viewModel.analysisState {
                    case .loading:
                        ProgressView("Analyzing food...")
                    case .error(let message):
                        ErrorView(message: message) {
                            Task {
                                await viewModel.analyzeFood()
                            }
                        }
                    case .success:
                        analysisContent
                    }
                }
                .padding()
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
                    Button("Save") {
                        viewModel.saveAnalysis()
                        dismiss()
                    }
                    .disabled(viewModel.analysisState != .success)
                }
            }
        }
        .task {
            await viewModel.analyzeFood()
        }
    }
    
    private var analysisContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Ingredients Section
            VStack(alignment: .leading, spacing: 10) {
                Text("Ingredients")
                    .font(.headline)
                
                ForEach(viewModel.ingredients.indices, id: \.self) { index in
                    TextField("Ingredient", text: $viewModel.ingredients[index])
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Button(action: {
                    viewModel.ingredients.append("")
                }) {
                    Label("Add Ingredient", systemImage: "plus.circle.fill")
                }
            }
            
            // Calories Section
            VStack(alignment: .leading, spacing: 10) {
                Text("Total Calories")
                    .font(.headline)
                
                TextField("Calories", value: $viewModel.totalCalories, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
            }
            
            // Nutritional Info Section
            VStack(alignment: .leading, spacing: 10) {
                Text("Nutritional Information")
                    .font(.headline)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Protein (g)")
                        TextField("Protein", value: $viewModel.nutritionalInfo.protein, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Carbs (g)")
                        TextField("Carbs", value: $viewModel.nutritionalInfo.carbs, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Fat (g)")
                        TextField("Fat", value: $viewModel.nutritionalInfo.fat, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                }
            }
        }
    }
}

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text(message)
                .multilineTextAlignment(.center)
            
            Button("Retry") {
                retryAction()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    FoodAnalysisView(imageData: Data(), apiKey: "preview-key")
} 