import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(PurchaseManager.self) private var purchaseManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: PlanType = .yearly
    @State private var isPurchasing = false
    @State private var errorMessage: String?
    @State private var appeared = false

    enum PlanType {
        case monthly, yearly, lifetime
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [PawSyncTheme.accent.opacity(0.2), .clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 200, height: 200)
                            .blur(radius: 20)

                        VStack(spacing: 14) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 56))
                                .foregroundStyle(PawSyncTheme.goldGradient)

                            Text("Unlock PawSync Pro")
                                .font(.title2.weight(.bold))

                            Text("Everything your pet needs in one app")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 20)

                    VStack(spacing: 14) {
                        FeatureRow(icon: "doc.richtext", gradient: PawSyncTheme.accentGradient, text: "PDF veterinary reports")
                        FeatureRow(icon: "person.2.fill", gradient: PawSyncTheme.warmGradient, text: "Family sharing")
                        FeatureRow(icon: "brain.head.profile.fill", gradient: PawSyncTheme.purpleGradient, text: "AI health suggestions & symptom analysis")
                        FeatureRow(icon: "barcode.viewfinder", gradient: LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing), text: "Medication barcode scanner")
                        FeatureRow(icon: "square.grid.2x2.fill", gradient: LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing), text: "Home screen widget")
                        FeatureRow(icon: "square.and.arrow.up", gradient: LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing), text: "CSV data export")
                    }
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)

                    VStack(spacing: 12) {
                        PlanCard(
                            title: "Yearly",
                            price: purchaseManager.yearlyProduct?.displayPrice ?? "$19.99/year",
                            subtitle: "Save 44% — just $1.67/month",
                            isSelected: selectedPlan == .yearly,
                            badge: "Most Popular"
                        ) {
                            selectedPlan = .yearly
                            Haptics.selection()
                        }

                        PlanCard(
                            title: "Monthly",
                            price: purchaseManager.monthlyProduct?.displayPrice ?? "$2.99/month",
                            subtitle: "7-day free trial, cancel anytime",
                            isSelected: selectedPlan == .monthly,
                            badge: nil
                        ) {
                            selectedPlan = .monthly
                            Haptics.selection()
                        }

                        PlanCard(
                            title: "Lifetime",
                            price: purchaseManager.lifetimeProduct?.displayPrice ?? "$49.99 one-time",
                            subtitle: "Pay once, own forever",
                            isSelected: selectedPlan == .lifetime,
                            badge: "Best Value"
                        ) {
                            selectedPlan = .lifetime
                            Haptics.selection()
                        }
                    }
                    .padding(.horizontal)

                    Button {
                        Task { await purchase() }
                    } label: {
                        if isPurchasing {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        } else {
                            Text("Subscribe Now")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                    }
                    .background(PawSyncTheme.accentGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: PawSyncTheme.accent.opacity(0.3), radius: 8, y: 4)
                    .padding(.horizontal)
                    .disabled(isPurchasing)
                    .buttonStyle(BounceButtonStyle())

                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    Button("Restore Purchases") {
                        Task {
                            await purchaseManager.restorePurchases()
                            if purchaseManager.isPremium { dismiss() }
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    Text("Payment will be charged to your Apple ID account. Subscription automatically renews unless cancelled at least 24 hours before the end of the current period.")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .task {
                await purchaseManager.loadProducts()
            }
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3)) {
                    appeared = true
                }
            }
        }
    }

    private func purchase() async {
        isPurchasing = true
        errorMessage = nil

        let product: StoreKit.Product?
        switch selectedPlan {
        case .monthly: product = purchaseManager.monthlyProduct
        case .yearly: product = purchaseManager.yearlyProduct
        case .lifetime: product = purchaseManager.lifetimeProduct
        }

        guard let product else {
            errorMessage = "Product not available. Please try again later."
            isPurchasing = false
            return
        }

        do {
            let success = try await purchaseManager.purchase(product)
            if success {
                Haptics.success()
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isPurchasing = false
    }
}

struct FeatureRow: View {
    let icon: String
    let gradient: LinearGradient
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            GradientIconBadge(icon: icon, gradient: gradient, size: 32, iconFont: .caption)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }
}

struct PlanCard: View {
    let title: String
    let price: String
    let subtitle: String
    let isSelected: Bool
    let badge: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.subheadline.weight(.semibold))
                        if let badge {
                            Text(badge)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(PawSyncTheme.goldGradient)
                                .clipShape(Capsule())
                        }
                    }
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(price)
                    .font(.subheadline.weight(.semibold))

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? PawSyncTheme.accent : .secondary)
                    .font(.title3)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? PawSyncTheme.accent.opacity(0.06) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? PawSyncTheme.accent : .clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
