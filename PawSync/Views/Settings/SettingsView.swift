import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(PurchaseManager.self) private var purchaseManager
    @Query private var pets: [Pet]
    @AppStorage("appColorScheme") private var appColorScheme: String = "system"
    @State private var showingPaywall = false
    @State private var showingContactSupport = false
    @State private var showingBackupAlert = false

    private let githubUser = "asunnyboy861"
    private var supportURL: URL { URL(string: "https://\(githubUser).github.io/PawSync/support.html")! }
    private var privacyURL: URL { URL(string: "https://\(githubUser).github.io/PawSync/privacy.html")! }
    private var termsURL: URL { URL(string: "https://\(githubUser).github.io/PawSync/terms.html")! }

    var body: some View {
        NavigationStack {
            List {
                subscriptionSection

                Section("Appearance") {
                    Picker("Theme", selection: $appColorScheme) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                }

                Section("Notifications") {
                    Button {
                        Task {
                            _ = await NotificationService.shared.requestPermission()
                        }
                        Haptics.tap()
                    } label: {
                        Label("Enable Notifications", systemImage: "bell.badge.fill")
                    }
                }

                Section("Data") {
                    Button {
                        Task { await purchaseManager.restorePurchases() }
                    } label: {
                        Label("Restore Purchases", systemImage: "arrow.clockwise")
                    }

                    Button {
                        backupData()
                    } label: {
                        Label("Backup Data", systemImage: "externaldrive.badge.timemachine")
                    }

                    Button {
                        sharePDFReport()
                    } label: {
                        Label("Export Health Report (PDF)", systemImage: "doc.richtext")
                    }
                    .disabled(pets.isEmpty)
                }

                Section("Support") {
                    NavigationLink {
                        ContactSupportView()
                    } label: {
                        Label("Contact Support", systemImage: "envelope.fill")
                    }

                    Link(destination: supportURL) {
                        Label("Support Page", systemImage: "safari")
                    }

                    Link(destination: privacyURL) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }

                    Link(destination: termsURL) {
                        Label("Terms of Use", systemImage: "doc.text.fill")
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Built with")
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "swift")
                                .foregroundStyle(.orange)
                            Text("SwiftUI & SwiftData")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }

    private var subscriptionSection: some View {
        Section {
            if purchaseManager.isPremium {
                HStack(spacing: 14) {
                    GradientIconBadge(icon: "crown.fill", gradient: PawSyncTheme.goldGradient, size: 40)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Pro Active")
                            .font(.subheadline.weight(.semibold))
                        Text("All features unlocked")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } else if purchaseManager.isTrialActive {
                Button {
                    showingPaywall = true
                } label: {
                    HStack(spacing: 14) {
                        GradientIconBadge(icon: "sparkles", gradient: PawSyncTheme.goldGradient, size: 40)
                        VStack(alignment: .leading) {
                            Text("Free Trial — \(purchaseManager.trialDaysRemaining) days left")
                                .font(.subheadline.weight(.semibold))
                            Text("Tap to upgrade to Pro")
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
                }
            } else {
                Button {
                    showingPaywall = true
                } label: {
                    HStack(spacing: 14) {
                        GradientIconBadge(icon: "crown.fill", gradient: PawSyncTheme.goldGradient, size: 40)
                        VStack(alignment: .leading) {
                            Text("Upgrade to Pro")
                                .font(.subheadline.weight(.semibold))
                            Text("Unlock all features")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    private func backupData() {
        guard let data = BackupService.exportData(pets: pets, modelContext: PawSyncApp().modelContainer) else { return }
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("PawSync_backup.json")
        try? data.write(to: tempURL)
        let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }

    private func sharePDFReport() {
        guard let pet = pets.first,
              let imageData = PDFExportService.generateHealthReport(for: pet) else { return }
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(pet.name)_HealthReport.png")
        try? imageData.write(to: tempURL)
        let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}
