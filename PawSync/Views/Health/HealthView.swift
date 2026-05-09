import SwiftUI
import SwiftData

struct HealthView: View {
    @Binding var selectedPet: Pet?
    @Query private var pets: [Pet]
    @State private var showingAddRecord = false
    @State private var showingAddVetVisit = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    PetPickerView(selectedPet: $selectedPet)

                    if let pet = selectedPet {
                        let records = pet.healthRecords.sorted { $0.date > $1.date }
                        let visits = pet.vetVisits.sorted { $0.date > $1.date }

                        if !records.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                SectionHeader(title: "Health Records", icon: "heart.text.clipboard.fill", trailing: "\(records.count)")

                                ForEach(records) { record in
                                    HealthRecordRow(record: record)
                                }
                            }
                        }

                        if !visits.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                SectionHeader(title: "Vet Visits", icon: "stethoscope", trailing: "\(visits.count)")

                                ForEach(visits) { visit in
                                    VetVisitRow(visit: visit)
                                }
                            }
                        }

                        if records.isEmpty && visits.isEmpty {
                            EmptyStateView(
                                icon: "heart.text.clipboard",
                                title: "No Health Records",
                                message: "Track your pet's health history, vet visits, and more.",
                                actionTitle: "Add Record"
                            ) {
                                showingAddRecord = true
                            }
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Health")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button { showingAddVetVisit = true } label: {
                        Image(systemName: "stethoscope")
                            .foregroundStyle(PawSyncTheme.accent)
                    }
                    Button { showingAddRecord = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(PawSyncTheme.accent)
                    }
                }
            }
            .sheet(isPresented: $showingAddRecord) {
                if let pet = selectedPet {
                    AddHealthRecordView(pet: pet)
                }
            }
            .sheet(isPresented: $showingAddVetVisit) {
                if let pet = selectedPet {
                    AddVetVisitView(pet: pet)
                }
            }
        }
    }
}

struct HealthRecordRow: View {
    let record: HealthRecord

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(record.type.color).opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: record.type.icon)
                    .font(.subheadline)
                    .foregroundStyle(Color(record.type.color))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(record.title)
                    .font(.subheadline.weight(.medium))
                Text(record.type.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(record.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            if let cost = record.cost {
                Text(String(format: "$%.0f", cost))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .elevatedCard(cornerRadius: 12)
        .padding(.horizontal)
    }
}

struct VetVisitRow: View {
    let visit: VetVisit

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(PawSyncTheme.accent.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: "stethoscope")
                    .font(.subheadline)
                    .foregroundStyle(PawSyncTheme.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(visit.reason.isEmpty ? "Vet Visit" : visit.reason)
                    .font(.subheadline.weight(.medium))
                if !visit.clinic.isEmpty {
                    Text(visit.clinic)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(visit.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            if visit.hasFollowUp {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Follow-up")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.blue)
                    if let followUp = visit.followUpDate {
                        Text(followUp.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(12)
        .elevatedCard(cornerRadius: 12)
        .padding(.horizontal)
    }
}

struct AddHealthRecordView: View {
    let pet: Pet
    @Environment(\.dismiss) private var dismiss
    @State private var type: RecordType = .checkup
    @State private var title = ""
    @State private var details = ""
    @State private var date = Date()
    @State private var veterinarian = ""
    @State private var clinic = ""
    @State private var costString = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Record Details") {
                    Picker("Type", selection: $type) {
                        ForEach(RecordType.allCases, id: \.self) { t in
                            Label(t.rawValue, systemImage: t.icon).tag(t)
                        }
                    }
                    TextField("Title", text: $title)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Details", text: $details, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Veterinarian") {
                    TextField("Veterinarian", text: $veterinarian)
                    TextField("Clinic", text: $clinic)
                    HStack {
                        TextField("Cost", text: $costString)
                            .keyboardType(.decimalPad)
                        Text("$")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Add Health Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveRecord()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    private func saveRecord() {
        let record = HealthRecord(
            date: date,
            type: type,
            title: title,
            details: details,
            veterinarian: veterinarian,
            clinic: clinic,
            cost: Double(costString)
        )
        record.pet = pet
        pet.healthRecords.append(record)
        Haptics.success()
    }
}

struct AddVetVisitView: View {
    let pet: Pet
    @Environment(\.dismiss) private var dismiss
    @State private var date = Date()
    @State private var clinic = ""
    @State private var veterinarian = ""
    @State private var reason = ""
    @State private var diagnosis = ""
    @State private var treatment = ""
    @State private var hasFollowUp = false
    @State private var followUpDate = Date().addingTimeInterval(30 * 24 * 3600)
    @State private var costString = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Visit Details") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Reason", text: $reason)
                    TextField("Clinic", text: $clinic)
                    TextField("Veterinarian", text: $veterinarian)
                }

                Section("Outcome") {
                    TextField("Diagnosis", text: $diagnosis)
                    TextField("Treatment", text: $treatment)
                    Toggle("Schedule Follow-up", isOn: $hasFollowUp)
                    if hasFollowUp {
                        DatePicker("Follow-up Date", selection: $followUpDate, displayedComponents: .date)
                    }
                }

                Section("Cost") {
                    HStack {
                        TextField("Cost", text: $costString)
                            .keyboardType(.decimalPad)
                        Text("$")
                            .foregroundStyle(.secondary)
                    }
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Vet Visit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveVisit()
                        dismiss()
                    }
                    .disabled(reason.isEmpty)
                }
            }
        }
    }

    private func saveVisit() {
        let visit = VetVisit(
            date: date,
            clinic: clinic,
            veterinarian: veterinarian,
            reason: reason,
            diagnosis: diagnosis,
            treatment: treatment,
            followUpDate: hasFollowUp ? followUpDate : nil,
            cost: Double(costString),
            notes: notes
        )
        visit.pet = pet
        pet.vetVisits.append(visit)
        if hasFollowUp {
            NotificationService.shared.scheduleVetFollowUpReminder(for: visit, petName: pet.name)
        }
        Haptics.success()
    }
}
