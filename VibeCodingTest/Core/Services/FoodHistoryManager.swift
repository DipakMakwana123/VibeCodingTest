import Foundation

final class FoodHistoryManager {
    static let shared = FoodHistoryManager()
    private let userDefaults = UserDefaults.standard
    private let recordsKey = "foodRecords"
    
    private init() {}
    
    func addRecord(_ record: FoodRecord) {
        print("Adding new food record...")
        var records = getAllRecords()
        records.append(record)
        saveRecords(records)
        print("Food record added successfully")
    }
    
    func getAllRecords() -> [FoodRecord] {
        print("Fetching all food records...")
        guard let data = userDefaults.data(forKey: recordsKey) else {
            print("No food records found")
            return []
        }
        
        do {
            let records = try JSONDecoder().decode([FoodRecord].self, from: data)
            print("Retrieved \(records.count) food records")
            return records
        } catch {
            print("Error decoding food records: \(error.localizedDescription)")
            return []
        }
    }
    
    func getRecords(for date: Date) -> [FoodRecord] {
        print("Fetching food records for date: \(date)")
        let calendar = Calendar.current
        return getAllRecords().filter { record in
            calendar.isDate(record.date, inSameDayAs: date)
        }
    }
    
    func deleteRecord(_ record: FoodRecord) {
        print("Deleting food record...")
        var records = getAllRecords()
        records.removeAll { $0.id == record.id }
        saveRecords(records)
        print("Food record deleted successfully")
    }
    
    func clearAllRecords() {
        print("Clearing all food records...")
        userDefaults.removeObject(forKey: recordsKey)
        print("All food records cleared")
    }
    
    private func saveRecords(_ records: [FoodRecord]) {
        print("Saving food records...")
        do {
            let data = try JSONEncoder().encode(records)
            userDefaults.set(data, forKey: recordsKey)
            print("Food records saved successfully")
        } catch {
            print("Error saving food records: \(error.localizedDescription)")
        }
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