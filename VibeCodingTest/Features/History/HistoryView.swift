import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // Calendar View
                DatePicker(
                    "Select Date",
                    selection: $viewModel.selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .onChange(of: viewModel.selectedDate) { newDate in
                    viewModel.loadRecords()
                }
                .padding()
                .background(Color.systemBackground)
                
                // Records List
                if viewModel.foodRecords.isEmpty {
                    if #available(iOS 17.0, *) {
                        ContentUnavailableView(
                            "No Records",
                            systemImage: "fork.knife.circle",
                            description: Text("No food records for this date")
                        )
                        .background(Color.systemBackground)
                    } else {
                        VStack {
                            Image(systemName: "fork.knife.circle")
                                .font(.system(size: 50))
                                .foregroundColor(Color.secondaryLabel)
                            Text("No Records")
                                .font(.headline)
                                .foregroundColor(Color.label)
                            Text("No food records for this date")
                                .font(.subheadline)
                                .foregroundColor(Color.secondaryLabel)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.systemBackground)
                    }
                } else {
                    List {
                        ForEach(viewModel.foodRecords) { record in
                            FoodRecordRow(record: record)
                                .listRowBackground(Color.secondarySystemBackground)
                        }
                        .onDelete { indexSet in
                            if let index = indexSet.first {
                                viewModel.deleteRecord(viewModel.foodRecords[index])
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .background(Color.systemGroupedBackground)
                }
            }
            .background(Color.systemGroupedBackground)
            .navigationTitle("Food History")
            .toolbar {
                EditButton()
            }
        }
        .task {
            viewModel.loadRecords()
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
                        .foregroundColor(Color.label)
                        .lineLimit(1)
                    
                    Text("\(Int(record.totalCalories)) calories")
                        .font(.subheadline)
                        .foregroundColor(Color.secondaryLabel)
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
                .foregroundColor(Color.secondaryLabel)
            Text("\(Int(value))g")
                .font(.callout)
                .bold()
                .foregroundColor(Color.label)
        }
    }
}

#Preview {
    HistoryView()
}
