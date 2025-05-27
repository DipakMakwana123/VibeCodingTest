import Foundation
import os.log

class FoodHistoryManager {
    static let shared = FoodHistoryManager()
    private let logger = Logger(subsystem: "com.vibe.foodcalories", category: "FoodHistoryManager")
    
    private let userDefaults = UserDefaults.standard
    private let recordsKey = "food_records"
    
    private init() {}
    
    func addRecord(_ record: FoodRecord) {
        logger.debug("Adding new food record...")
        var records = getAllRecords()
        records.append(record)
        
        do {
            let encodedData = try JSONEncoder().encode(records)
            userDefaults.set(encodedData, forKey: recordsKey)
            logger.info("Food record added successfully")
        } catch {
            logger.error("Failed to save food record: \(error.localizedDescription)")
        }
    }
    
    func getAllRecords() -> [FoodRecord] {
        logger.debug("Fetching all food records...")
        guard let data = userDefaults.data(forKey: recordsKey) else {
            logger.info("No food records found")
            return []
        }
        
        do {
            let records = try JSONDecoder().decode([FoodRecord].self, from: data)
            logger.info("Retrieved \(records.count) food records")
            return records
        } catch {
            logger.error("Failed to decode food records: \(error.localizedDescription)")
            return []
        }
    }
    
    func getRecords(for date: Date) -> [FoodRecord] {
        logger.debug("Fetching food records for date: \(date)")
        let calendar = Calendar.current
        return getAllRecords().filter { record in
            calendar.isDate(record.date, inSameDayAs: date)
        }
    }
    
    func deleteRecord(_ record: FoodRecord) {
        logger.debug("Deleting food record...")
        var records = getAllRecords()
        records.removeAll { $0.id == record.id }
        
        do {
            let encodedData = try JSONEncoder().encode(records)
            userDefaults.set(encodedData, forKey: recordsKey)
            logger.info("Food record deleted successfully")
        } catch {
            logger.error("Failed to delete food record: \(error.localizedDescription)")
        }
    }
    
    func clearAllRecords() {
        logger.debug("Clearing all food records...")
        userDefaults.removeObject(forKey: recordsKey)
        logger.info("All food records cleared")
    }
}

// MARK: - Models
struct FoodRecord: Codable, Identifiable {
    let id: UUID
    let date: Date
    let ingredients: [String]
    let totalCalories: Double
    let nutritionalInfo: FoodAnalysis.NutritionalInfo
    let imageData: Data
    
    init(date: Date, ingredients: [String], totalCalories: Double, nutritionalInfo: FoodAnalysis.NutritionalInfo, imageData: Data) {
        self.id = UUID()
        self.date = date
        self.ingredients = ingredients
        self.totalCalories = totalCalories
        self.nutritionalInfo = nutritionalInfo
        self.imageData = imageData
    }
} 