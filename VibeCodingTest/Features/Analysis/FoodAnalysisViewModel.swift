import Foundation
import UIKit

@MainActor
class FoodAnalysisViewModel: ObservableObject {
    @Published var ingredients: [String] = []
    @Published var isAnalyzing = false
    @Published var error: Error?
    
    let imageData: Data
    private let openAIService: OpenAIService
    private let historyManager = FoodHistoryManager.shared
    
    init(imageData: Data, apiKey: String) {
        self.imageData = imageData
        self.openAIService = OpenAIService(apiKey: apiKey)
        print("FoodAnalysisViewModel initialized with image size: \(imageData.count) bytes")
    }
    
    func analyzeFood() async {
        isAnalyzing = true
        print("Starting food analysis...")
        
        do {
            let response = try await openAIService.analyzeImage(imageData)
            self.ingredients = response.ingredients
            print("Food analysis completed successfully with \(self.ingredients.count) ingredients")
            
        } catch let error as NetworkError {
            self.error = error
            print("Network error during analysis: \(error.localizedDescription)")
            
        } catch let error as ParsingError {
            self.error = error
            print("Parsing error during analysis: \(error.localizedDescription)")
            
        } catch {
            self.error = error
            print("Unexpected error during analysis: \(error.localizedDescription)")
        }
        
        isAnalyzing = false
    }
    
    func saveAnalysis() {
        print("Saving food analysis...")
        let foodRecord = FoodRecord(
            id: UUID(),
            date: Date(),
            ingredients: ingredients,
            totalCalories: 0,
            nutritionalInfo: FoodAnalysis.NutritionalInfo(protein: 0, carbs: 0, fat: 0),
            imageData: imageData
        )
        
        historyManager.addFoodRecord(foodRecord)
        print("Food analysis saved successfully")
    }
}

// MARK: - Supporting Types
struct FoodAnalysis {
    struct NutritionalInfo: Codable {
        let protein: Double
        let carbs: Double
        let fat: Double
    }
}

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Unauthorized access"
        case .serverError:
            return "Server error"
        }
    }
}

enum ParsingError: LocalizedError {
    case invalidData
    case missingData
    
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid data format"
        case .missingData:
            return "Missing required data"
        }
    }
} 