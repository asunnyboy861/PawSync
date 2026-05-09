import SwiftUI
import SwiftData
import PhotosUI

struct AddPetView: View {
    var isOnboarding: Bool = false
    @Environment(\.dismiss) private var dismiss
    @Environment(PurchaseManager.self) private var purchaseManager
    @State private var name = ""
    @State private var species: PetSpecies = .dog
    @State private var breed = ""
    @State private var dateOfBirth = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
    @State private var gender: PetGender = .male
    @State private var weightString = ""
    @State private var microchipID = ""
    @State private var allergies: [String] = []
    @State private var newAllergy = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @FocusState private var isNameFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        ZStack {
                            if let photoData, let uiImage = UIImage(data: photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(PawSyncTheme.accent, lineWidth: 3))
                            } else {
                                ZStack {
                                    Circle()
                                        .fill(PawSyncTheme.accent.opacity(0.1))
                                        .frame(width: 120, height: 120)
                                    Image(systemName: "camera.fill")
                                        .font(.title)
                                        .foregroundStyle(PawSyncTheme.accent)
                                }
                                .overlay(Circle().stroke(PawSyncTheme.accent.opacity(0.3), lineWidth: 2))
                            }

                            ZStack(alignment: .bottomTrailing) {
                                Color.clear
                                ZStack {
                                    Circle()
                                        .fill(PawSyncTheme.accent)
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "plus")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                    }
                    .padding(.top, 20)

                    VStack(spacing: 16) {
                        TextField("Pet's Name", text: $name)
                            .font(.title3.weight(.semibold))
                            .multilineTextAlignment(.center)
                            .focused($isNameFocused)

                        SpeciesPicker(selectedSpecies: $species)

                        VStack(spacing: 12) {
                            TextField("Breed", text: $breed)
                                .textFieldStyle(.roundedBorder)

                            HStack {
                                TextField("Weight", text: $weightString)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                                Text("kg")
                                    .foregroundStyle(.secondary)
                            }

                            DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)

                            Picker("Gender", selection: $gender) {
                                ForEach(PetGender.allCases, id: \.self) { g in
                                    Text(g.rawValue).tag(g)
                                }
                            }
                            .pickerStyle(.segmented)

                            TextField("Microchip ID (optional)", text: $microchipID)
                                .textFieldStyle(.roundedBorder)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Allergies")
                                .font(.subheadline.weight(.medium))

                            FlowLayout(spacing: 8) {
                                ForEach(allergies, id: \.self) { allergy in
                                    HStack(spacing: 4) {
                                        Text(allergy)
                                            .font(.caption)
                                        Button {
                                            allergies.removeAll { $0 == allergy }
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(PawSyncTheme.accent.opacity(0.1))
                                    .clipShape(Capsule())
                                }

                                HStack(spacing: 4) {
                                    TextField("Add allergy", text: $newAllergy)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: 120)
                                        .onSubmit {
                                            addAllergy()
                                        }
                                    Button("Add", action: addAllergy)
                                        .font(.caption)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
            .navigationTitle(isOnboarding ? "Add Your Pet" : "New Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !isOnboarding {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePet()
                        if !isOnboarding { dismiss() }
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data),
                       let compressed = uiImage.jpegData(compressionQuality: 0.5) {
                        photoData = compressed
                    }
                }
            }
            .onAppear {
                isNameFocused = true
            }
        }
    }

    private func addAllergy() {
        let trimmed = newAllergy.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty && !allergies.contains(trimmed) {
            allergies.append(trimmed)
            newAllergy = ""
        }
    }

    @Environment(\.modelContext) private var modelContext

    private func savePet() {
        let weight = Double(weightString) ?? 0
        let pet = Pet(
            name: name,
            species: species,
            breed: breed,
            dateOfBirth: dateOfBirth,
            gender: gender,
            weight: weight,
            photoData: photoData,
            microchipID: microchipID.isEmpty ? nil : microchipID,
            allergies: allergies
        )
        modelContext.insert(pet)
        try? modelContext.save()
        Haptics.success()
    }
}

struct SpeciesPicker: View {
    @Binding var selectedSpecies: PetSpecies

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(PetSpecies.allCases, id: \.self) { species in
                    SpeciesChip(
                        species: species,
                        isSelected: selectedSpecies == species
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedSpecies = species
                        }
                        Haptics.selection()
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct SpeciesChip: View {
    let species: PetSpecies
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: species.icon)
                    .font(.title3)
                    .foregroundStyle(isSelected ? .white : PawSyncTheme.accent)
                    .frame(width: 48, height: 48)
                    .background(isSelected ? PawSyncTheme.accent : PawSyncTheme.accent.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(species.rawValue)
                    .font(.caption2.weight(isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? PawSyncTheme.accent : .secondary)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX)
        }

        return (CGSize(width: maxX, height: currentY + rowHeight), positions)
    }
}
