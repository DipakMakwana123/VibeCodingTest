import Foundation

actor OpenAIService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private let apiVersion = "2024-03-01"  // Latest API version
    
    private enum Endpoint {
        static let vision = "https://api.openai.com/v1/chat/completions"
        static let imageAnalysis = "https://api.openai.com/v1/vision/analysis"
        static let imageEdit = "https://api.openai.com/v1/vision/edit"
        static let imageGeneration = "https://api.openai.com/v1/vision/generate"
    }
    
    init() throws {
        // Read API key from Config.xcconfig
        self.apiKey = try Configuration.validOpenAIAPIKey()
        print("OpenAIService initialized with API key configuration")
    }
    
    func analyzeFood(imageData: Data) async throws -> FoodAnalysis {
        print("Starting food analysis with image size: \(imageData.count) bytes")
        
        let base64Image = imageData.base64EncodedString()
        print("Image converted to base64")
        
        // Create request payload using model
        let request = OpenAIRequest.createFoodAnalysisRequest(imageBase64: base64Image)
        
        var urlRequest = URLRequest(url: URL(string: Endpoint.vision)!)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue(apiVersion, forHTTPHeaderField: "OpenAI-Version")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
            print("Request payload prepared successfully")
        } catch {
            print("Failed to prepare request payload: \(error.localizedDescription)")
            throw NetworkError.invalidPayload
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response type received")
                throw NetworkError.invalidResponse
            }
            
            print("Received response with status code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = errorJson["error"] as? [String: Any] {
                    let message = error["message"] as? String ?? "Unknown error"
                    let type = error["type"] as? String ?? ""
                    
                    print("API error: \(message), type: \(type)")
                    
                    // Handle specific error types
                    if type.contains("invalid_api_version") {
                        throw NetworkError.apiError(message: "API version error. Please update the app.")
                    } else if type.contains("model") {
                        throw NetworkError.apiError(message: "Model configuration error. Please try again.")
                    } else {
                        throw NetworkError.apiError(message: message)
                    }
                } else {
                    print("Request failed with status code: \(httpResponse.statusCode)")
                    throw NetworkError.requestFailed(statusCode: httpResponse.statusCode)
                }
            }
            
            let result = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            if let content = result.choices.first?.message.content {
                print("Successfully received API response")
                return try parseAnalysis(from: content)
            } else {
                print("No content in API response")
                throw NetworkError.noData
            }
        } catch {
            print("Network request failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func parseAnalysis(from jsonString: String) throws -> FoodAnalysis {
        print("Parsing analysis response: \(jsonString)")
        
        // Clean up the response string to ensure it contains only JSON
        let cleanedString = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
        
        guard let jsonData = cleanedString.data(using: .utf8) else {
            print("Failed to convert response to data")
            throw ParsingError.invalidData
        }
        
        do {
            let analysis = try JSONDecoder().decode(FoodAnalysis.self, from: jsonData)
            print("Successfully parsed food analysis with \(analysis.ingredients.count) ingredients")
            return analysis
        } catch {
            print("JSON parsing failed: \(error.localizedDescription)")
            print("Raw JSON string: \(cleanedString)")
            throw ParsingError.invalidFormat
        }
    }
}
struct FoodAnalysis: Codable {
    var ingredients: [String]
    var totalCalories: Double
    var nutritionalInfo: NutritionalInfo
    
    struct NutritionalInfo: Codable {
        var protein: Double
        var carbs: Double
        var fat: Double
    }
}

// MARK: - Errors
enum NetworkError: Error, LocalizedError {
    case invalidResponse
    case requestFailed(statusCode: Int)
    case noData
    case invalidPayload
    case apiError(message: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .requestFailed(let statusCode):
            return "Request failed with status code: \(statusCode)"
        case .noData:
            return "No data received from server"
        case .invalidPayload:
            return "Failed to prepare request payload"
        case .apiError(let message):
            return "API Error: \(message)"
        }
    }
}

enum ParsingError: Error, LocalizedError {
    case invalidFormat
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .invalidFormat:
            return "Invalid JSON format in response"
        case .invalidData:
            return "Invalid data received"
        }
    }
} 
