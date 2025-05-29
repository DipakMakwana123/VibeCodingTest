import Foundation
import os.log

enum ConfigurationError: Error {
    case missingKey(String)
    case invalidPlistFile
}

final class ConfigurationManager {
    static let shared = ConfigurationManager()
    private let logger = Logger(subsystem: "com.vibe.foodcalories", category: "ConfigurationManager")
    
    private var configuration: [String: Any]?
    
    private init() {
        loadConfiguration()
    }
    
    private func loadConfiguration() {
        guard let plistPath = Bundle.main.path(forResource: "Config", ofType: "plist") else {
            logger.error("Config.plist not found in bundle")
            return
        }
        
        guard let plistData = FileManager.default.contents(atPath: plistPath) else {
            logger.error("Failed to read Config.plist")
            return
        }
        
        do {
            configuration = try PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any]
            logger.debug("Configuration loaded successfully")
        } catch {
            logger.error("Failed to parse Config.plist: \(error.localizedDescription)")
        }
    }
    
    func getValue<T>(for key: String) throws -> T {
        guard let configuration = configuration else {
            logger.error("Configuration not loaded")
            throw ConfigurationError.invalidPlistFile
        }
        
        guard let value = configuration[key] as? T else {
            logger.error("Missing or invalid value for key: \(key)")
            throw ConfigurationError.missingKey(key)
        }
        
        return value
    }
    
    var openAIAPIKey: String {
        get throws {
            try getValue(for: "OpenAIAPIKey")
        }
    }
} 