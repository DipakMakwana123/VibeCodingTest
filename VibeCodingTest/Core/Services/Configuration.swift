import Foundation

enum Configuration {
    enum Error: LocalizedError {
        case missingKey(String)
        case invalidConfiguration
        case invalidAPIKey
        
        var errorDescription: String? {
            switch self {
            case .missingKey(let key):
                return "Missing configuration value for key: \(key)"
            case .invalidConfiguration:
                return "Invalid configuration"
            case .invalidAPIKey:
                return "Invalid OpenAI API Key,Please add valid API Key in Info.plist"
            }
        }
    }
    
    static func validateOpenAIAPIKey() throws -> String {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String else {
            throw Error.missingKey("OPENAI_API_KEY")
        }
        
        if apiKey.isEmpty || apiKey == "your_openai_api_key_here" {
            throw Error.invalidAPIKey
        }
        
        return apiKey
    }
}
