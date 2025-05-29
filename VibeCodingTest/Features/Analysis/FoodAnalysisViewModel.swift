import Foundation
import UIKit

@MainActor
class FoodAnalysisViewModel: ObservableObject {
    @Published var ingredients: [String] = []
    @Published var isAnalyzing = false
    @Published var error: Error?
    @Published var showError = false
    
    let imageData: Data
    private var openAIService: OpenAIService?
    private let historyManager = FoodHistoryManager.shared
    
    init(imageData: Data) {
        self.imageData = imageData
        initializeService()
        print("FoodAnalysisViewModel initialized with image size: \(imageData.count) bytes")
    }
    
    private func initializeService() {
        do {
            self.openAIService = try OpenAIService()
        } catch {
            self.error = error
            self.showError = true
            print("Error initializing OpenAI service: \(error.localizedDescription)")
        }
    }
    
    func analyzeFood() async {
        guard let openAIService = openAIService else {
            print("Cannot analyze food: OpenAI service not initialized")
            return
        }
        
        isAnalyzing = true
        print("Starting food analysis...")
        
        do {
            let analysis = try await openAIService.analyzeFood(imageData: imageData)
            await MainActor.run {
                self.ingredients = analysis.ingredients
                print("Food analysis completed successfully with \(self.ingredients.count) ingredients")
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.showError = true
                print("Error during analysis: \(error.localizedDescription)")
            }
        }
        
        await MainActor.run {
            isAnalyzing = false
        }
    }
    
    func saveAnalysis() {
        print("Saving food analysis...")
        let foodRecord = FoodRecord(
            date: Date(),
            ingredients: ingredients,
            totalCalories: 0,
            nutritionalInfo: FoodAnalysis.NutritionalInfo(protein: 0, carbs: 0, fat: 0),
            imageData: imageData
        )
        
        historyManager.addRecord(foodRecord)
        print("Food analysis saved successfully")
    }
}

// MARK: - Supporting Types
enum AnalysisState: Hashable {
    case loading
    case success
    case error(message: String)
    
    static func == (lhs: AnalysisState, rhs: AnalysisState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.success, .success):
            return true
        case (.error(let lhsMessage), .error(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .loading:
            hasher.combine(0)
        case .success:
            hasher.combine(1)
        case .error(let message):
            hasher.combine(2)
            hasher.combine(message)
        }
    }
}

struct NutritionalInfo {
    var protein: Double = 0
    var carbs: Double = 0
    var fat: Double = 0
} 
