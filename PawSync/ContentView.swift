import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var pets: [Pet]
    @Environment(PurchaseManager.self) private var purchaseManager
    @State private var hasAppeared = false

    var body: some View {
        Group {
            if pets.isEmpty {
                AddPetView(isOnboarding: true)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                MainTabView()
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: pets.isEmpty)
        .opacity(hasAppeared ? 1 : 0)
        .scaleEffect(hasAppeared ? 1 : 0.96)
        .task {
            await purchaseManager.checkTrialStatus()
            if !pets.isEmpty {
                _ = await NotificationService.shared.requestPermission()
                NotificationService.shared.rescheduleAllReminders(pets: pets)
            }
            withAnimation(.easeOut(duration: 0.4)) {
                hasAppeared = true
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Pet.self, inMemory: true)
        .environment(PurchaseManager.shared)
}
