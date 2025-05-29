import Foundation

class FoodHistoryManager {
    static let shared = FoodHistoryManager()
    private let userDefaults = UserDefaults.standard
    private let foodRecordsKey = "foodRecords"
    
    private init() {}
    
    func addFoodRecord(_ record: FoodRecord) {
        var records = getAllFoodRecords()
        records.append(record)
        
        do {
            let encodedData = try JSONEncoder().encode(records)
            userDefaults.set(encodedData, forKey: foodRecordsKey)
            print("Food record added successfully")
        } catch {
            print("Failed to save food record: \(error.localizedDescription)")
        }
    }
    
    func getAllFoodRecords() -> [FoodRecord] {
        guard let data = userDefaults.data(forKey: foodRecordsKey) else {
            print("No food records found")
            return []
        }
        
        do {
            let records = try JSONDecoder().decode([FoodRecord].self, from: data)
            print("Retrieved \(records.count) food records")
            return records
        } catch {
            print("Failed to decode food records: \(error.localizedDescription)")
            return []
        }
    }
    
    func getFoodRecords(for date: Date) -> [FoodRecord] {
        let calendar = Calendar.current
        return getAllFoodRecords().filter { record in
            calendar.isDate(record.date, inSameDayAs: date)
        }
    }
    
    func deleteFoodRecord(at index: Int) {
        var records = getAllFoodRecords()
        guard index < records.count else { return }
        
        records.remove(at: index)
        
        do {
            let encodedData = try JSONEncoder().encode(records)
            userDefaults.set(encodedData, forKey: foodRecordsKey)
            print("Food record deleted successfully")
        } catch {
            print("Failed to delete food record: \(error.localizedDescription)")
        }
    }
    
    func clearAllRecords() {
        userDefaults.removeObject(forKey: foodRecordsKey)
        print("All food records cleared")
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
} 