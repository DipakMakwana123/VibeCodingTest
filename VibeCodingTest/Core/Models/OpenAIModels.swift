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
//struct OpenAIResponse: Codable {
//    let choices: [Choice]
//    
//    struct Choice: Codable {
//        let message: Message
//    }
//}

// MARK: - Factory Methods
extension OpenAIRequest {
    static func createFoodAnalysisRequest(imageBase64: String) -> OpenAIRequest {
        let textContent = Content(
            type: "text",
            text: """
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
            model: "gpt-4-vision-preview",
            messages: [message],
            maxTokens: 1000,
            temperature: 0.7
        )
    }
} 
