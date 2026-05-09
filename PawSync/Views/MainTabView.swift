import SwiftUI
import SwiftData

struct MainTabView: View {
    @Query private var pets: [Pet]
    @State private var selectedTab = 0
    @State private var selectedPet: Pet?
    @Namespace private var tabAnimation

    private let tabs: [(icon: String, filledIcon: String, label: String)] = [
        ("house", "house.fill", "Home"),
        ("heart.text.clipboard", "heart.text.clipboard.fill", "Health"),
        ("syringe", "syringe.fill", "Vaccines"),
        ("pills", "pills.fill", "Meds"),
        ("chart.line.uptrend.xychart", "chart.line.uptrend.xychart.fill", "Weight"),
        ("gearshape", "gearshape.fill", "Settings")
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case 0: DashboardView(selectedPet: $selectedPet)
                case 1: HealthView(selectedPet: $selectedPet)
                case 2: VaccinationView(selectedPet: $selectedPet)
                case 3: MedicationView(selectedPet: $selectedPet)
                case 4: WeightView(selectedPet: $selectedPet)
                case 5: SettingsView()
                default: DashboardView(selectedPet: $selectedPet)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 70)

            customTabBar
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            if selectedPet == nil {
                selectedPet = pets.first
            }
        }
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                    Haptics.selection()
                } label: {
                    VStack(spacing: 4) {
                        ZStack {
                            if selectedTab == index {
                                Capsule()
                                    .fill(PawSyncTheme.accent.opacity(0.15))
                                    .frame(width: 48, height: 28)
                                    .matchedGeometryEffect(id: "tabHighlight", in: tabAnimation)
                            }

                            Image(systemName: selectedTab == index ? tab.filledIcon : tab.icon)
                                .font(.system(size: 17, weight: selectedTab == index ? .semibold : .regular))
                                .foregroundStyle(selectedTab == index ? PawSyncTheme.accent : .secondary)
                                .symbolEffect(.bounce, value: selectedTab == index)
                        }
                        .frame(height: 28)

                        Text(tab.label)
                            .font(.system(size: 10, weight: selectedTab == index ? .semibold : .regular))
                            .foregroundStyle(selectedTab == index ? PawSyncTheme.accent : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.label)
                .accessibilityAddTraits(selectedTab == index ? .isSelected : [])
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 2)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tab bar")
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.06), radius: 12, y: -4)
                .ignoresSafeArea()
        )
    }
}
