import SwiftUI
import SwiftData

struct VaccinationView: View {
    @Binding var selectedPet: Pet?
    @Query private var pets: [Pet]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddVaccination = false
    @State private var showingTemplates = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    PetPickerView(selectedPet: $selectedPet)

                    if let pet = selectedPet {
                        let dueVaccinations = pet.vaccinations.filter { $0.isDue }
                        let upcomingVaccinations = pet.vaccinations.filter { $0.isDueSoon }
                        let currentVaccinations = pet.vaccinations.filter { !$0.isDue && !$0.isDueSoon }

                        if !dueVaccinations.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                SectionHeader(title: "Overdue", icon: "exclamationmark.triangle.fill", trailing: "\(dueVaccinations.count)")

                                ForEach(dueVaccinations) { vax in
                                    VaccinationRow(vaccination: vax, petName: pet.name, isOverdue: true)
                                }
                            }
                        }

                        if !upcomingVaccinations.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                SectionHeader(title: "Due Soon", icon: "clock.fill", trailing: "\(upcomingVaccinations.count)")

                                ForEach(upcomingVaccinations) { vax in
                                    VaccinationRow(vaccination: vax, petName: pet.name)
                                }
                            }
                        }

                        if !currentVaccinations.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                SectionHeader(title: "Up to Date", icon: "checkmark.shield.fill", trailing: "\(currentVaccinations.count)")

                                ForEach(currentVaccinations.sorted { $0.dateAdministered > $1.dateAdministered }) { vax in
                                    VaccinationRow(vaccination: vax, petName: pet.name)
                                }
                            }
                        }

                        if pet.vaccinations.isEmpty {
                            EmptyStateView(
                                icon: "syringe",
                                title: "No Vaccinations Yet",
                                message: "Add your pet's vaccination records or use templates for common vaccines.",
                                actionTitle: "Add from Templates"
                            ) {
                                showingTemplates = true
                            }
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Vaccinations")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button { showingTemplates = true } label: {
                        Image(systemName: "list.bullet.clipboard")
                            .foregroundStyle(PawSyncTheme.accent)
                    }
                    Button { showingAddVaccination = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(PawSyncTheme.accent)
                    }
                }
            }
            .sheet(isPresented: $showingAddVaccination) {
                if let pet = selectedPet {
                    AddVaccinationView(pet: pet)
                }
            }
            .sheet(isPresented: $showingTemplates) {
                if let pet = selectedPet {
                    VaccinationTemplateView(pet: pet)
                }
            }
        }
    }
}

struct VaccinationRow: View {
    let vaccination: Vaccination
    let petName: String
    var isOverdue: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isOverdue ? Color.red.opacity(0.12) : PawSyncTheme.accent.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: isOverdue ? "exclamationmark.triangle.fill" : "syringe.fill")
                    .font(.subheadline)
                    .foregroundStyle(isOverdue ? .red : PawSyncTheme.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(vaccination.name)
                    .font(.subheadline.weight(.medium))
                Text("Given: \(vaccination.dateAdministered.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let nextDue = vaccination.nextDueDate {
                    Text("Next: \(nextDue.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(isOverdue ? .red : .secondary)
                }
            }

            Spacer()

            if isOverdue {
                Text("OVERDUE")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.red)
                    .clipShape(Capsule())
            } else if vaccination.isDueSoon {
                Text("SOON")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.orange)
                    .clipShape(Capsule())
            }
        }
        .padding(12)
        .elevatedCard(cornerRadius: 12)
        .padding(.horizontal)
    }
}

struct AddVaccinationView: View {
    let pet: Pet
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var dateAdministered = Date()
    @State private var nextDueDate = Date().addingTimeInterval(365 * 24 * 3600)
    @State private var hasNextDue = true
    @State private var veterinarian = ""
    @State private var clinic = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Vaccine Details") {
                    TextField("Vaccine Name", text: $name)
                    DatePicker("Date Administered", selection: $dateAdministered, displayedComponents: .date)
                    Toggle("Set Next Due Date", isOn: $hasNextDue)
                    if hasNextDue {
                        DatePicker("Next Due Date", selection: $nextDueDate, displayedComponents: .date)
                    }
                }

                Section("Veterinarian") {
                    TextField("Veterinarian Name", text: $veterinarian)
                    TextField("Clinic", text: $clinic)
                }

                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Vaccination")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveVaccination()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private func saveVaccination() {
        let vax = Vaccination(
            name: name,
            dateAdministered: dateAdministered,
            nextDueDate: hasNextDue ? nextDueDate : nil,
            veterinarian: veterinarian,
            clinic: clinic,
            notes: notes
        )
        vax.pet = pet
        pet.vaccinations.append(vax)
        NotificationService.shared.scheduleVaccinationReminder(for: vax, petName: pet.name)
        Haptics.success()
    }
}

struct VaccinationTemplateView: View {
    let pet: Pet
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTemplates: Set<String> = []

    private var templates: [VaccinationTemplate] {
        VaccinationTemplate.templates(for: pet.species)
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(templates, id: \.name) { template in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            if template.isCore {
                                Text("CORE")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(PawSyncTheme.accent)
                                    .clipShape(Capsule())
                            }
                            Text(template.name)
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                            if selectedTemplates.contains(template.name) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(PawSyncTheme.accent)
                            }
                        }
                        Text(template.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selectedTemplates.contains(template.name) {
                            selectedTemplates.remove(template.name)
                        } else {
                            selectedTemplates.insert(template.name)
                        }
                        Haptics.selection()
                    }
                }
            }
            .navigationTitle("Vaccine Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add Selected") {
                        addSelectedTemplates()
                        dismiss()
                    }
                    .disabled(selectedTemplates.isEmpty)
                }
            }
        }
    }

    private func addSelectedTemplates() {
        for template in templates where selectedTemplates.contains(template.name) {
            let vax = Vaccination(
                name: template.name,
                dateAdministered: Date(),
                nextDueDate: template.boosterIntervalMonths.flatMap {
                    Calendar.current.date(byAdding: .month, value: $0, to: Date())
                },
                notes: template.description
            )
            vax.pet = pet
            pet.vaccinations.append(vax)
            NotificationService.shared.scheduleVaccinationReminder(for: vax, petName: pet.name)
        }
        Haptics.success()
    }
}
