import Foundation
import UIKit

@MainActor
class FoodAnalysisViewModel: ObservableObject {
    @Published var ingredients: [String] = []
    @Published var isAnalyzing = false
    @Published var error: Error?
    @Published var showError = false
    @Published var analysis: FoodAnalysis?
    
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
    
    private func compressImage(_ data: Data, maxSizeKB: Int = 1024) -> Data {
        print("Starting image compression. Original size: \(Double(data.count) / 1024) KB")
        
        guard let image = UIImage(data: data) else {
            print("Failed to create UIImage from data")
            return data
        }
        
        // Start with original quality
        var compression: CGFloat = 1.0
        var imageData = image.jpegData(compressionQuality: compression) ?? data
        
        // Maximum number of iterations to prevent infinite loop
        let maxIterations = 10
        var currentIteration = 0
        
        // Target size in bytes
        let maxBytes = maxSizeKB * 1024
        
        // Binary search for appropriate compression value
        var minCompression: CGFloat = 0.0
        var maxCompression: CGFloat = 1.0
        
        while imageData.count > maxBytes && currentIteration < maxIterations {
            compression = (minCompression + maxCompression) / 2
            
            if let compressedData = image.jpegData(compressionQuality: compression) {
                if compressedData.count > maxBytes {
                    maxCompression = compression
                } else {
                    minCompression = compression
                }
                imageData = compressedData
            }
            
            currentIteration += 1
            print("Compression iteration \(currentIteration): size = \(Double(imageData.count) / 1024) KB, quality = \(compression)")
        }
        
        // If still too large, resize the image
        if imageData.count > maxBytes {
            print("Compression alone insufficient, attempting resize")
            let scale = sqrt(Double(maxBytes) / Double(imageData.count))
            let newSize = CGSize(
                width: image.size.width * scale,
                height: image.size.height * scale
            )
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if let resizedData = resizedImage?.jpegData(compressionQuality: compression) {
                imageData = resizedData
                print("Image resized. Final size: \(Double(imageData.count) / 1024) KB")
            }
        }
        
        print("Compression complete. Final size: \(Double(imageData.count) / 1024) KB")
        return imageData
    }
    
    func analyzeFood() async {
        guard let openAIService = openAIService else {
            print("Cannot analyze food: OpenAI service not initialized")
            return
        }
        
        isAnalyzing = true
        print("Starting food analysis...")
        
        // Compress image before analysis
        let compressedImageData = compressImage(imageData)
        
        do {
            let analysis = try await openAIService.analyzeFood(imageData: compressedImageData)
            await MainActor.run {
                self.analysis = analysis
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
        guard let analysis = analysis else {
            print("Cannot save: No analysis data available")
            return
        }
        
        let foodRecord = FoodRecord(
            date: Date(),
            ingredients: ingredients,
            totalCalories: analysis.totalCalories,
            nutritionalInfo: analysis.nutritionalInfo,
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
