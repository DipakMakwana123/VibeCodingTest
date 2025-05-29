import Foundation

@MainActor
class HistoryViewModel: ObservableObject {
    @Published var records: [FoodRecord] = []
    private let historyManager = FoodHistoryManager.shared
    
    func loadRecords(for date: Date) {
        print("Loading records for date: \(date)")
        self.records = historyManager.getFoodRecords(for: date)
        print("Loaded \(self.records.count) records")
    }
    
    func deleteRecords(at offsets: IndexSet) {
        print("Deleting records at offsets: \(offsets)")
        offsets.forEach { index in
            historyManager.deleteFoodRecord(at: index)
        }
        print("Records deleted successfully")
    }
} 