import Foundation
import os.log

actor OpenAIService {
    private let logger = Logger(subsystem: "com.vibe.foodcalories", category: "OpenAIService")
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private let apiVersion = "2024-03-01"
    
    init(apiKey: String) {
        self.apiKey = apiKey
        logger.debug("OpenAIService initialized with API key: \(apiKey.prefix(8))...")
    }
    
    func analyzeFood(imageData: Data) async throws -> FoodAnalysis {
        logger.debug("Starting food analysis with image size: \(imageData.count) bytes")
        
        let base64Image = imageData.base64EncodedString()
        logger.debug("Image converted to base64")
        
        let payload: [String: Any] = [
            "model": "gpt-4-vision-preview",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": """
                            Analyze this food image and provide the following information in valid JSON format:
                            {
                                "ingredients": ["list of ingredients"],
                                "totalCalories": number,
                                "nutritionalInfo": {
                                    "protein": number,
                                    "carbs": number,
                                    "fat": number
                                }
                            }
                            Be precise with measurements and ensure the response is valid JSON.
                            """
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 1000
        ]
        
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiVersion, forHTTPHeaderField: "OpenAI-Version")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            logger.debug("Request payload prepared successfully")
        } catch {
            logger.error("Failed to prepare request payload: \(error.localizedDescription)")
            throw NetworkError.invalidPayload
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("Invalid response type received")
                throw NetworkError.invalidResponse
            }
            
            logger.debug("Received response with status code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = errorJson["error"] as? [String: Any] {
                    let message = error["message"] as? String ?? "Unknown error"
                    let type = error["type"] as? String ?? ""
                    
                    logger.error("API error: \(message), type: \(type)")
                    
                    // Handle specific error types
                    if type.contains("invalid_api_version") {
                        throw NetworkError.apiError(message: "API version error. Please update the app.")
                    } else if type.contains("model") {
                        throw NetworkError.apiError(message: "Model configuration error. Please try again.")
                    } else {
                        throw NetworkError.apiError(message: message)
                    }
                } else {
                    logger.error("Request failed with status code: \(httpResponse.statusCode)")
                    throw NetworkError.requestFailed(statusCode: httpResponse.statusCode)
                }
            }
            
            let result = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            if let content = result.choices.first?.message.content {
                logger.debug("Successfully received API response")
                return try parseAnalysis(from: content)
            } else {
                logger.error("No content in API response")
                throw NetworkError.noData
            }
        } catch {
            logger.error("Network request failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func parseAnalysis(from jsonString: String) throws -> FoodAnalysis {
        logger.debug("Parsing analysis response: \(jsonString)")
        
        // Clean up the response string to ensure it contains only JSON
        let cleanedString = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
        
        guard let jsonData = cleanedString.data(using: .utf8) else {
            logger.error("Failed to convert response to data")
            throw ParsingError.invalidData
        }
        
        do {
            let analysis = try JSONDecoder().decode(FoodAnalysis.self, from: jsonData)
            logger.info("Successfully parsed food analysis with \(analysis.ingredients.count) ingredients")
            return analysis
        } catch {
            logger.error("JSON parsing failed: \(error.localizedDescription)")
            logger.error("Raw JSON string: \(cleanedString)")
            throw ParsingError.invalidFormat
        }
    }
}

// MARK: - Models
struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
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