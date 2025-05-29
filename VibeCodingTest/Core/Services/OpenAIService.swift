import Foundation

class OpenAIService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func analyzeImage(_ imageData: Data) async throws -> ImageAnalysisResponse {
        let endpoint = "\(baseURL)/chat/completions"
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        
        // Convert image data to base64
        let base64Image = imageData.base64EncodedString()
        
        // Create request body
        let requestBody = ChatCompletionRequest(
            model: "gpt-4-vision-preview",
            messages: [
                Message(
                    role: "user",
                    content: [
                        MessageContent(
                            type: "text",
                            text: "Analyze this food image and list all visible ingredients. Format the response as a JSON array of strings containing only the ingredient names."
                        ),
                        MessageContent(
                            type: "image_url",
                            imageUrl: ImageUrl(
                                url: "data:image/jpeg;base64,\(base64Image)"
                            )
                        )
                    ]
                )
            ],
            maxTokens: 300
        )
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        // Make request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            let result = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
            guard let content = result.choices.first?.message.content else {
                throw ParsingError.missingData
            }
            
            // Parse the JSON string response
            guard let jsonData = content.data(using: .utf8),
                  let ingredients = try? JSONDecoder().decode([String].self, from: jsonData) else {
                throw ParsingError.invalidData
            }
            
            return ImageAnalysisResponse(ingredients: ingredients)
            
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError
        }
    }
}

// MARK: - Request Models
struct ChatCompletionRequest: Codable {
    let model: String
    let messages: [Message]
    let maxTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case maxTokens = "max_tokens"
    }
}

struct Message: Codable {
    let role: String
    let content: [MessageContent]
}

struct MessageContent: Codable {
    let type: String
    let text: String?
    let imageUrl: ImageUrl?
    
    enum CodingKeys: String, CodingKey {
        case type
        case text
        case imageUrl = "image_url"
    }
}

struct ImageUrl: Codable {
    let url: String
}

// MARK: - Response Models
struct ChatCompletionResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: ResponseMessage
}

struct ResponseMessage: Codable {
    let content: String
}

struct ImageAnalysisResponse {
    let ingredients: [String]
} 