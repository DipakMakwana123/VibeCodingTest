import Foundation
import os.log

@MainActor
class HistoryViewModel: ObservableObject {
    private let logger = Logger(subsystem: "com.vibe.foodcalories", category: "HistoryViewModel")
    
    @Published var records: [FoodRecord] = []
    
    func loadRecords(for date: Date) {
        logger.debug("Loading records for date: \(date)")
        records = FoodHistoryManager.shared.getRecords(for: date)
        logger.info("Loaded \(self.records.count) records")
    }
    
    func deleteRecords(at offsets: IndexSet) {
        logger.debug("Deleting records at offsets: \(offsets)")
        for index in offsets {
            let record = records[index]
            FoodHistoryManager.shared.deleteRecord(record)
        }
        records.remove(atOffsets: offsets)
        logger.info("Records deleted successfully")
    }
}
