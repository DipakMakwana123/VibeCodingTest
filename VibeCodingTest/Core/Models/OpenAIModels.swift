import Foundation

// MARK: - Request Models
struct OpenAIRequest: Codable {
    let model: String
    let messages: [Message]
    let maxTokens: Int
    let temperature: Double
    
    enum CodingKeys: String, CodingKey {
        case model, messages
        case maxTokens = "max_tokens"
        case temperature
    }
}

struct Message: Codable {
    let role: String
    let content: [Content]
}

struct Content: Codable {
    let type: String
    let text: String?
    let imageUrl: ImageURL?
    
    enum CodingKeys: String, CodingKey {
        case type, text
        case imageUrl = "image_url"
    }
}

struct ImageURL: Codable {
    let url: String
    let detail: String?
}

// MARK: - Response Models
struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: ResponseMessage
    }
    
    struct ResponseMessage: Codable {
        let content: String
    }
}

// MARK: - Factory Methods
extension OpenAIRequest {
    static func createFoodAnalysisRequest(imageBase64: String) -> OpenAIRequest {
        let textContent = Content(
            type: "text",
            text: """
            You are a food analysis expert. Please analyze this food image and provide the following information in valid JSON format:
            {
                "ingredients": ["list of visible ingredients"],
                "totalCalories": estimated total calories as a number,
                "nutritionalInfo": {
                    "protein": estimated grams of protein,
                    "carbs": estimated grams of carbohydrates,
                    "fat": estimated grams of fat
                }
            }
            Be precise with measurements and ensure the response is valid JSON. If you can't see certain details clearly, provide your best estimate based on similar foods.
            """,
            imageUrl: nil
        )
        
        let imageContent = Content(
            type: "image_url",
            text: nil,
            imageUrl: ImageURL(
                url: "data:image/jpeg;base64,\(imageBase64)",
                detail: "high"
            )
        )
        
        let message = Message(
            role: "user",
            content: [textContent, imageContent]
        )
        
        return OpenAIRequest(
            model: "gpt-4o",
            messages: [message],
            maxTokens: 1000,
            temperature: 0.7
        )
    }
} 
