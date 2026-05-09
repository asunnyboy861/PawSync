import SwiftUI
import SwiftData

@main
struct PawSyncApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([
                Pet.self,
                HealthRecord.self,
                Vaccination.self,
                Medication.self,
                WeightEntry.self,
                VetVisit.self
            ])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none
            )
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    @AppStorage("appColorScheme") private var appColorScheme: String = "system"

    private var preferredColorScheme: ColorScheme? {
        switch appColorScheme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(PurchaseManager.shared)
                .preferredColorScheme(preferredColorScheme)
        }
        .modelContainer(modelContainer)
    }
}
