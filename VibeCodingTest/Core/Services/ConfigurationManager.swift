import Foundation

enum ConfigurationError: Error {
    case missingKey(String)
    case invalidPlistFile
}

final class ConfigurationManager {
    static let shared = ConfigurationManager()
    private var configuration: [String: Any]?
    
    private init() {
        loadConfiguration()
    }
    
    private func loadConfiguration() {
        guard let infoDictionary = Bundle.main.infoDictionary else {
            print("Info.plist not found in bundle")
            return
        }
        
        configuration = infoDictionary
        print("Configuration loaded successfully")
    }
    
    func getValue<T>(for key: String) throws -> T {
        guard let configuration = configuration else {
            print("Configuration not loaded")
            throw ConfigurationError.invalidPlistFile
        }
        
        guard let value = configuration[key] as? T else {
            print("Missing or invalid value for key: \(key)")
            throw ConfigurationError.missingKey(key)
        }
        
        return value
    }
    
    var openAIAPIKey: String {
        get throws {
            try getValue(for: "OPENAI_API_KEY")
        }
    }
} 