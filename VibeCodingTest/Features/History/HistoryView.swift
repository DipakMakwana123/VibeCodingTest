import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                // Calendar View
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .onChange(of: selectedDate) { newDate in
                    viewModel.loadRecords(for: newDate)
                }
                
                // Records List
                if viewModel.records.isEmpty {
                    if #available(iOS 17.0, *) {
                        ContentUnavailableView(
                            "No Records",
                            systemImage: "fork.knife.circle",
                            description: Text("No food records for this date")
                        )
                    } else {
                        // Fallback on earlier versions
                    }
                } else {
                    List {
                        ForEach(viewModel.records) { record in
                            FoodRecordRow(record: record)
                        }
                        .onDelete { indexSet in
                            viewModel.deleteRecords(at: indexSet)
                        }
                    }
                }
            }
            .navigationTitle("Food History")
            .toolbar {
                EditButton()
            }
        }
        .task {
            viewModel.loadRecords(for: selectedDate)
        }
    }
}

struct FoodRecordRow: View {
    let record: FoodRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let image = UIImage(data: record.imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading) {
                    Text(record.ingredients.joined(separator: ", "))
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text("\(Int(record.totalCalories)) calories")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Nutritional Info
            HStack(spacing: 16) {
                NutrientView(label: "Protein", value: record.nutritionalInfo.protein)
                NutrientView(label: "Carbs", value: record.nutritionalInfo.carbs)
                NutrientView(label: "Fat", value: record.nutritionalInfo.fat)
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }
}

struct NutrientView: View {
    let label: String
    let value: Double
    
    var body: some View {
        VStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text("\(Int(value))g")
                .font(.callout)
                .bold()
        }
    }
}

#Preview {
    HistoryView()
}
