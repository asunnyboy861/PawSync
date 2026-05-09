import SwiftUI
import SwiftData
import PhotosUI

struct DashboardView: View {
    @Binding var selectedPet: Pet?
    @Query private var pets: [Pet]
    @Environment(PurchaseManager.self) private var purchaseManager
    @State private var showingAddPet = false
    @State private var showingPaywall = false
    @State private var showingAIAssistant = false
    @State private var headerAppeared = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if purchaseManager.isTrialActive && !purchaseManager.isPremium {
                        TrialBannerView(daysRemaining: purchaseManager.trialDaysRemaining)
                            .onTapGesture { showingPaywall = true }
                            .staggeredAppear(index: 0)
                    }

                    PetPickerView(selectedPet: $selectedPet)

                    if let pet = selectedPet {
                        HealthScoreCard(pet: pet)
                            .staggeredAppear(index: 1)

                        PetHeroCard(pet: pet)
                            .staggeredAppear(index: 2)

                        QuickActionsGrid(pet: pet)
                            .staggeredAppear(index: 3)

                        AIAssistantCard(pet: pet)
                            .staggeredAppear(index: 4)
                            .onTapGesture { showingAIAssistant = true }

                        UpcomingSection(pet: pet)
                            .staggeredAppear(index: 5)

                        RecentWeightCard(pet: pet)
                            .staggeredAppear(index: 6)
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("PawSync")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAddPet = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(PawSyncTheme.accent)
                    }
                }
            }
            .sheet(isPresented: $showingAddPet) {
                AddPetView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingAIAssistant) {
                if let pet = selectedPet {
                    AIHealthAssistantView(pet: pet)
                }
            }
        }
    }
}

struct TrialBannerView: View {
    let daysRemaining: Int
    @State private var shimmer = false

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: "sparkles")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.orange)
                    .symbolEffect(.variableColor.iterative, options: .repeating.speed(0.5))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Free Trial Active")
                    .font(.subheadline.weight(.semibold))
                Text("\(daysRemaining) day\(daysRemaining == 1 ? "" : "s") remaining — all features unlocked")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("Upgrade")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(PawSyncTheme.goldGradient)
                .clipShape(Capsule())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.orange.opacity(0.15), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
}

struct HealthScoreCard: View {
    let pet: Pet
    @State private var score: HealthScore?

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                SectionHeader(title: "Health Score", icon: "heart.text.clipboard.fill")
            }

            if let score {
                HStack(spacing: 20) {
                    ZStack {
                        AnimatedProgressRing(
                            progress: Double(score.total) / 100.0,
                            lineWidth: 8,
                            size: 80,
                            gradient: PawSyncTheme.accentGradient
                        )

                        VStack(spacing: 2) {
                            Text("\(score.total)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(PawSyncTheme.accent)
                            Text(score.grade.rawValue)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        ScoreBar(label: "Vaccines", value: score.vaccination, color: .blue)
                        ScoreBar(label: "Vet Visits", value: score.preventiveCare, color: .teal)
                        ScoreBar(label: "Medication", value: score.medicationAdherence, color: .purple)
                        ScoreBar(label: "Weight", value: score.weightStability, color: .orange)
                    }

                    Spacer()
                }

                if !score.insights.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(score.insights.prefix(2), id: \.self) { insight in
                            HStack(alignment: .top, spacing: 6) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.orange)
                                Text(insight)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding()
        .elevatedCard()
        .padding(.horizontal)
        .onAppear {
            score = HealthScoreEngine.calculate(for: pet)
        }
        .onChange(of: pet.vaccinations.count) { _, _ in
            score = HealthScoreEngine.calculate(for: pet)
        }
        .onChange(of: pet.weightEntries.count) { _, _ in
            score = HealthScoreEngine.calculate(for: pet)
        }
    }
}

struct ScoreBar: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(width: 60, alignment: .trailing)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(.systemGray5))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: geo.size.width * value, height: 6)
                }
            }
            .frame(height: 6)
            Text("\(Int(value * 100))%")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(width: 30, alignment: .trailing)
        }
    }
}

struct PetHeroCard: View {
    let pet: Pet
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(PawSyncTheme.heroGradient)
                    .frame(height: 120)

                HStack(spacing: 16) {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        ZStack(alignment: .bottomTrailing) {
                            if let photoData = pet.photoData, let uiImage = UIImage(data: photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 76, height: 76)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(.white, lineWidth: 3))
                                    .shadow(color: .black.opacity(0.2), radius: 8, y: 2)
                            } else {
                                ZStack {
                                    Circle()
                                        .fill(.white.opacity(0.2))
                                        .frame(width: 76, height: 76)
                                    Image(systemName: pet.species.icon)
                                        .font(.system(size: 32))
                                        .foregroundStyle(.white)
                                }
                                .overlay(Circle().stroke(.white.opacity(0.4), lineWidth: 2))
                            }

                            ZStack {
                                Circle()
                                    .fill(Color(.systemBackground))
                                    .frame(width: 26, height: 26)
                                Circle()
                                    .fill(PawSyncTheme.accentGradient)
                                    .frame(width: 22, height: 22)
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.white)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(pet.name)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                        Text("\(pet.breed) · \(pet.ageString)")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.85))
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, -24)
            }

            HStack(spacing: 0) {
                StatPill(icon: "scalemass.fill", value: String(format: "%.1f", pet.weight), unit: "kg", color: PawSyncTheme.accent)
                Divider().frame(height: 24)
                StatPill(icon: "syringe.fill", value: "\(pet.vaccinations.count)", unit: "vaccines", color: .blue)
                Divider().frame(height: 24)
                StatPill(icon: "pills.fill", value: "\(pet.activeMedications.count)", unit: "meds", color: .purple)
            }
            .padding(.top, 36)
            .padding(.bottom, 12)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.08), radius: 16, y: 6)
        .padding(.horizontal)
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data),
                   let compressed = uiImage.jpegData(compressionQuality: 0.5) {
                    pet.photoData = compressed
                    Haptics.success()
                }
            }
        }
    }
}

struct StatPill: View {
    let icon: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundStyle(color)
                Text(value)
                    .font(.subheadline.weight(.bold))
            }
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct QuickActionsGrid: View {
    let pet: Pet
    @Environment(PurchaseManager.self) private var purchaseManager
    @State private var navigateToHealth = false
    @State private var navigateToVaccine = false
    @State private var navigateToMeds = false
    @State private var navigateToWeight = false

    private let actions: [(icon: String, label: String, colors: [Color])] = [
        ("heart.text.clipboard", "Health", [Color(hex: "EF4444"), Color(hex: "F87171")]),
        ("syringe.fill", "Vaccine", [Color(hex: "3B82F6"), Color(hex: "60A5FA")]),
        ("pills.fill", "Meds", [Color(hex: "8B5CF6"), Color(hex: "A78BFA")]),
        ("scalemass.fill", "Weight", [Color(hex: "F59E0B"), Color(hex: "FBBF24")])
    ]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(Array(actions.enumerated()), id: \.offset) { index, action in
                QuickActionButton(
                    icon: action.icon,
                    label: action.label,
                    gradient: LinearGradient(colors: action.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                ) {
                    switch index {
                    case 0: navigateToHealth = true
                    case 1: navigateToVaccine = true
                    case 2: navigateToMeds = true
                    case 3: navigateToWeight = true
                    default: break
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct QuickActionButton: View {
    let icon: String
    let label: String
    let gradient: LinearGradient
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)

                Text(label)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct UpcomingSection: View {
    let pet: Pet

    var body: some View {
        let dueVaccinations = pet.vaccinations.filter { $0.isDueSoon || $0.isDue }
        let activeMeds = pet.activeMedications.filter { $0.needsRefill }
        let followUps = pet.vetVisits.filter { $0.hasFollowUp }

        if !dueVaccinations.isEmpty || !activeMeds.isEmpty || !followUps.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                SectionHeader(title: "Upcoming", icon: "calendar.badge.clock")

                ForEach(dueVaccinations) { vax in
                    ReminderRow(
                        icon: "syringe.fill",
                        color: vax.isDue ? .red : .orange,
                        title: vax.name,
                        subtitle: vax.isDue ? "Overdue!" : "Due \(vax.nextDueDate?.formatted(date: .abbreviated, time: .omitted) ?? "")",
                        isUrgent: vax.isDue
                    )
                }

                ForEach(activeMeds) { med in
                    ReminderRow(
                        icon: "pills.fill",
                        color: .purple,
                        title: med.name,
                        subtitle: "Refill needed"
                    )
                }

                ForEach(followUps) { visit in
                    ReminderRow(
                        icon: "calendar",
                        color: .blue,
                        title: "Follow-up: \(visit.reason)",
                        subtitle: visit.followUpDate?.formatted(date: .abbreviated, time: .omitted) ?? ""
                    )
                }
            }
        }
    }
}

struct ReminderRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    var isUrgent: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(isUrgent ? .red : .secondary)
            }
            Spacer()

            if isUrgent {
                Text("URGENT")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.red)
                    .clipShape(Capsule())
            }
        }
        .padding(12)
        .elevatedCard(cornerRadius: 12)
        .padding(.horizontal)
    }
}

struct RecentWeightCard: View {
    let pet: Pet

    var body: some View {
        let entries = pet.weightEntries.sorted { $0.date > $1.date }
        if let latest = entries.first {
            VStack(alignment: .leading, spacing: 10) {
                SectionHeader(title: "Latest Weight", icon: "scalemass.fill")

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(format: "%.1f kg", latest.weight))
                            .font(.title2.weight(.bold))
                            .foregroundStyle(PawSyncTheme.accent)
                        Text(latest.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if entries.count >= 2 {
                        let prev = entries[1]
                        let diff = latest.weight - prev.weight
                        HStack(spacing: 4) {
                            Image(systemName: diff >= 0 ? "arrow.up.right" : "arrow.down.right")
                                .font(.caption2)
                            Text(String(format: "%+.1f kg", diff))
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundStyle(diff > 0.5 ? .orange : diff < -0.5 ? .red : PawSyncTheme.accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill((diff > 0.5 ? Color.orange : diff < -0.5 ? Color.red : PawSyncTheme.accent).opacity(0.1))
                        )
                    }
                }
            }
            .padding()
            .elevatedCard()
            .padding(.horizontal)
        }
    }
}

struct AIAssistantCard: View {
    let pet: Pet

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(PawSyncTheme.purpleGradient)
                    .frame(width: 48, height: 48)
                Image(systemName: "brain.head.profile.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("AI Health Assistant")
                    .font(.subheadline.weight(.semibold))
                Text("Ask about symptoms, nutrition, or care tips")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(PawSyncTheme.purpleGradient.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(PawSyncTheme.purpleGradient, lineWidth: 1)
                        .opacity(0.3)
                )
        )
        .padding(.horizontal)
    }
}
