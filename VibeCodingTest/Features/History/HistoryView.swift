import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                .onChange(of: selectedDate) { newDate in
                    viewModel.loadRecords(for: newDate)
                }
                
                if viewModel.records.isEmpty {
                    ContentUnavailableView(
                        "No Records",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("No food records found for this date.")
                    )
                } else {
                    List {
                        ForEach(viewModel.records) { record in
                            VStack(alignment: .leading, spacing: 8) {
                                if let image = UIImage(data: record.imageData) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 150)
                                        .cornerRadius(8)
                                }
                                
                                Text("Ingredients:")
                                    .font(.headline)
                                Text(record.ingredients.joined(separator: ", "))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Calories")
                                            .font(.caption)
                                        Text("\(Int(record.totalCalories))")
                                            .font(.headline)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .center) {
                                        Text("Protein")
                                            .font(.caption)
                                        Text("\(Int(record.nutritionalInfo.protein))g")
                                            .font(.headline)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .center) {
                                        Text("Carbs")
                                            .font(.caption)
                                        Text("\(Int(record.nutritionalInfo.carbs))g")
                                            .font(.headline)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        Text("Fat")
                                            .font(.caption)
                                        Text("\(Int(record.nutritionalInfo.fat))g")
                                            .font(.headline)
                                    }
                                }
                                .padding(.top, 4)
                            }
                            .padding(.vertical, 8)
                        }
                        .onDelete { indexSet in
                            viewModel.deleteRecords(at: indexSet)
                        }
                    }
                }
            }
            .navigationTitle("History")
        }
        .onAppear {
            viewModel.loadRecords(for: selectedDate)
        }
    }
} 