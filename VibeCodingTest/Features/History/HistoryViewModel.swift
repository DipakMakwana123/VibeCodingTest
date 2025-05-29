import Foundation

@MainActor
class HistoryViewModel: ObservableObject {
    @Published var foodRecords: [FoodRecord] = []
    private let historyManager = FoodHistoryManager.shared
    
    init() {
        loadRecords()
    }
    
    func loadRecords() {
        print("Loading food records...")
        foodRecords = historyManager.getAllRecords()
        print("Loaded \(foodRecords.count) food records")
    }
    
    func deleteRecord(_ record: FoodRecord) {
        print("Deleting food record...")
        historyManager.deleteRecord(record)
        loadRecords()
        print("Food record deleted successfully")
    }
}
