import SwiftUI
import SwiftData

struct MedicationView: View {
    @Binding var selectedPet: Pet?
    @Query private var pets: [Pet]
    @State private var showingAddMedication = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    PetPickerView(selectedPet: $selectedPet)

                    if let pet = selectedPet {
                        let activeMeds = pet.activeMedications
                        let inactiveMeds = pet.medications.filter { !$0.isActive }

                        if !activeMeds.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                SectionHeader(title: "Active Medications", icon: "pills.fill", trailing: "\(activeMeds.count)")

                                ForEach(activeMeds) { med in
                                    MedicationRow(medication: med, petName: pet.name)
                                }
                            }
                        }

                        if !inactiveMeds.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                SectionHeader(title: "Past Medications", icon: "pills", trailing: "\(inactiveMeds.count)")

                                ForEach(inactiveMeds) { med in
                                    MedicationRow(medication: med, petName: pet.name)
                                }
                            }
                        }

                        if pet.medications.isEmpty {
                            EmptyStateView(
                                icon: "pills",
                                title: "No Medications Yet",
                                message: "Track your pet's medications and get timely reminders.",
                                actionTitle: "Add Medication"
                            ) {
                                showingAddMedication = true
                            }
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Medications")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAddMedication = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(PawSyncTheme.accent)
                    }
                }
            }
            .sheet(isPresented: $showingAddMedication) {
                if let pet = selectedPet {
                    AddMedicationView(pet: pet)
                }
            }
        }
    }
}

struct MedicationRow: View {
    let medication: Medication
    let petName: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(medication.isActive ? PawSyncTheme.accent.opacity(0.12) : Color(.systemGray5))
                    .frame(width: 40, height: 40)
                Image(systemName: medication.isActive ? "pills.fill" : "pills")
                    .font(.subheadline)
                    .foregroundStyle(medication.isActive ? PawSyncTheme.accent : .secondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(medication.name)
                        .font(.subheadline.weight(.medium))
                    if medication.needsRefill {
                        Text("REFILL")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .clipShape(Capsule())
                    }
                }
                Text("\(medication.dosage) · \(medication.frequency.rawValue)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if medication.withFood {
                    Label("Take with food", systemImage: "fork.knife")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }

            Spacer()

            if medication.isActive {
                Image(systemName: "bell.fill")
                    .font(.caption)
                    .foregroundStyle(PawSyncTheme.accent)
            }
        }
        .padding(12)
        .elevatedCard(cornerRadius: 12)
        .padding(.horizontal)
    }
}

struct AddMedicationView: View {
    let pet: Pet
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var dosage = ""
    @State private var frequency: MedicationFrequency = .daily
    @State private var startDate = Date()
    @State private var hasEndDate = false
    @State private var endDate = Date().addingTimeInterval(30 * 24 * 3600)
    @State private var withFood = false
    @State private var prescribedBy = ""
    @State private var purpose = ""
    @State private var notes = ""
    @State private var hasRefillDate = false
    @State private var refillDate = Date().addingTimeInterval(30 * 24 * 3600)
    @State private var reminderTimes: [Date] = [Date()]

    var body: some View {
        NavigationStack {
            Form {
                Section("Medication Details") {
                    TextField("Name", text: $name)
                    TextField("Dosage (e.g., 10mg)", text: $dosage)
                    Picker("Frequency", selection: $frequency) {
                        ForEach(MedicationFrequency.allCases, id: \.self) { freq in
                            Text(freq.rawValue).tag(freq)
                        }
                    }
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    Toggle("Set End Date", isOn: $hasEndDate)
                    if hasEndDate {
                        DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    }
                    Toggle("Take with Food", isOn: $withFood)
                }

                Section("Reminders") {
                    ForEach(Array($reminderTimes.enumerated()), id: \.offset) { index, $time in
                        DatePicker("Reminder Time", selection: $time, displayedComponents: .hourAndMinute)
                    }
                    Button("Add Another Reminder") {
                        reminderTimes.append(Date())
                    }
                }

                Section("Details") {
                    TextField("Prescribed By", text: $prescribedBy)
                    TextField("Purpose", text: $purpose)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                    Toggle("Set Refill Date", isOn: $hasRefillDate)
                    if hasRefillDate {
                        DatePicker("Refill Date", selection: $refillDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Add Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveMedication()
                        dismiss()
                    }
                    .disabled(name.isEmpty || dosage.isEmpty)
                }
            }
        }
    }

    private func saveMedication() {
        let med = Medication(
            name: name,
            dosage: dosage,
            frequency: frequency,
            startDate: startDate,
            endDate: hasEndDate ? endDate : nil,
            timeOfDay: reminderTimes,
            withFood: withFood,
            prescribedBy: prescribedBy,
            purpose: purpose,
            notes: notes,
            refillDate: hasRefillDate ? refillDate : nil
        )
        med.pet = pet
        pet.medications.append(med)
        NotificationService.shared.scheduleMedicationReminder(for: med, petName: pet.name)
        Haptics.success()
    }
}
