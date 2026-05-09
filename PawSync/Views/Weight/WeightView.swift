import SwiftUI
import SwiftData
import Charts

struct WeightView: View {
    @Binding var selectedPet: Pet?
    @Query private var pets: [Pet]
    @Environment(PurchaseManager.self) private var purchaseManager
    @State private var showingAddWeight = false
    @State private var showingExport = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    PetPickerView(selectedPet: $selectedPet)

                    if let pet = selectedPet {
                        let entries = pet.weightEntries.sorted { $0.date < $1.date }

                        if !entries.isEmpty {
                            WeightChartView(entries: entries)
                                .padding(.horizontal)

                            VStack(alignment: .leading, spacing: 10) {
                                SectionHeader(title: "History", icon: "list.bullet", trailing: "\(entries.count) entries")

                                ForEach(entries.reversed()) { entry in
                                    WeightRow(entry: entry)
                                }
                            }
                        } else {
                            EmptyStateView(
                                icon: "scalemass",
                                title: "No Weight Records",
                                message: "Start tracking your pet's weight to monitor health trends.",
                                actionTitle: "Add Weight"
                            ) {
                                showingAddWeight = true
                            }
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Weight")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if let pet = selectedPet, !pet.weightEntries.isEmpty {
                        Button {
                            showingExport = true
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundStyle(PawSyncTheme.accent)
                        }
                    }
                    Button { showingAddWeight = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(PawSyncTheme.accent)
                    }
                }
            }
            .sheet(isPresented: $showingAddWeight) {
                if let pet = selectedPet {
                    AddWeightView(pet: pet)
                }
            }
            .confirmationDialog("Export", isPresented: $showingExport) {
                Button("Export as CSV") {
                    exportCSV()
                }
            }
        }
    }

    private func exportCSV() {
        guard let pet = selectedPet else { return }
        let csv = BackupService.exportCSV(weightEntries: pet.weightEntries, petName: pet.name)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(pet.name)_weight.csv")
        try? csv.write(to: tempURL, atomically: true, encoding: .utf8)
        let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

struct WeightChartView: View {
    let entries: [WeightEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Weight Trend", icon: "chart.line.uptrend.xychart")

            Chart(entries) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Weight", entry.weight)
                )
                .foregroundStyle(PawSyncTheme.accent.gradient)
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Date", entry.date),
                    y: .value("Weight", entry.weight)
                )
                .foregroundStyle(PawSyncTheme.accent.opacity(0.1).gradient)
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", entry.date),
                    y: .value("Weight", entry.weight)
                )
                .foregroundStyle(PawSyncTheme.accent)
                .symbolSize(30)
            }
            .chartYAxisLabel("kg")
            .frame(height: 200)
            .padding(.horizontal, 4)
        }
        .padding()
        .elevatedCard()
    }
}

struct WeightRow: View {
    let entry: WeightEntry

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(PawSyncTheme.accent.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: "scalemass.fill")
                    .font(.subheadline)
                    .foregroundStyle(PawSyncTheme.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(String(format: "%.1f kg", entry.weight))
                    .font(.subheadline.weight(.medium))
                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if !entry.notes.isEmpty {
                Text(entry.notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(12)
        .elevatedCard(cornerRadius: 12)
        .padding(.horizontal)
    }
}

struct AddWeightView: View {
    let pet: Pet
    @Environment(\.dismiss) private var dismiss
    @State private var weightString = ""
    @State private var date = Date()
    @State private var notes = ""
    @FocusState private var isWeightFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section("Weight") {
                    HStack {
                        TextField("Weight", text: $weightString)
                            .keyboardType(.decimalPad)
                            .focused($isWeightFocused)
                        Text("kg")
                            .foregroundStyle(.secondary)
                    }
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section("Notes") {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Weight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveWeight()
                        dismiss()
                    }
                    .disabled(weightString.isEmpty || Double(weightString) == nil)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isWeightFocused = false
                    }
                }
            }
            .onAppear {
                isWeightFocused = true
            }
        }
    }

    private func saveWeight() {
        guard let weight = Double(weightString), weight > 0 else { return }
        let entry = WeightEntry(date: date, weight: weight, notes: notes)
        entry.pet = pet
        pet.weightEntries.append(entry)
        pet.weight = weight
        Haptics.success()
    }
}
