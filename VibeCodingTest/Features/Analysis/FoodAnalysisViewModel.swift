import Foundation
import os.log

@MainActor
class FoodAnalysisViewModel: ObservableObject {
    private let logger = Logger(subsystem: "com.vibe.foodcalories", category: "FoodAnalysisViewModel")
    private let openAIService: OpenAIService
    
    let imageData: Data
    
    @Published var analysisState: AnalysisState = .loading
    @Published var ingredients: [String] = []
    @Published var totalCalories: Double = 0
    @Published var nutritionalInfo = NutritionalInfo()
    
    init(imageData: Data, apiKey: String) {
        self.imageData = imageData
        self.openAIService = OpenAIService(apiKey: apiKey)
        logger.debug("FoodAnalysisViewModel initialized with image size: \(imageData.count) bytes")
    }
    
    func analyzeFood() async {
        analysisState = .loading
        logger.debug("Starting food analysis...")
        
        do {
            let analysis = try await openAIService.analyzeFood(imageData: imageData)
            
            // Update the UI with the analysis results
            ingredients = analysis.ingredients
            totalCalories = analysis.totalCalories
            nutritionalInfo = NutritionalInfo(
                protein: analysis.nutritionalInfo.protein,
                carbs: analysis.nutritionalInfo.carbs,
                fat: analysis.nutritionalInfo.fat
            )
            
            analysisState = .success
            logger.info("Food analysis completed successfully with \(self.ingredients.count) ingredients")
        } catch let error as NetworkError {
            logger.error("Network error during analysis: \(error.localizedDescription)")
            analysisState = .error(message: error.localizedDescription)
        } catch let error as ParsingError {
            logger.error("Parsing error during analysis: \(error.localizedDescription)")
            analysisState = .error(message: error.localizedDescription)
        } catch {
            logger.error("Unexpected error during analysis: \(error.localizedDescription)")
            analysisState = .error(message: "An unexpected error occurred. Please try again.")
        }
    }
    
    func saveAnalysis() {
        logger.debug("Saving food analysis...")
        // Create a FoodRecord
        let record = FoodRecord(
            date: Date(),
            ingredients: ingredients,
            totalCalories: totalCalories,
            nutritionalInfo: FoodAnalysis.NutritionalInfo(
                protein: nutritionalInfo.protein,
                carbs: nutritionalInfo.carbs,
                fat: nutritionalInfo.fat
            ),
            imageData: imageData
        )
        
        // Save to FoodHistoryManager
        FoodHistoryManager.shared.addRecord(record)
        logger.info("Food analysis saved successfully")
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
