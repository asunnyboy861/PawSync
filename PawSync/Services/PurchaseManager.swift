import Foundation
import StoreKit
import Observation

@Observable
final class PurchaseManager {
    static let shared = PurchaseManager()

    private(set) var isPremium = false
    private(set) var isTrialActive = false
    private(set) var trialEndDate: Date?
    private(set) var products: [Product] = []

    private let trialStartKey = "PawSync_trialStartDate"
    private let trialDurationDays = 7

    static let monthlyProductID = "com.zzoutuo.PawSync.pro.monthly"
    static let yearlyProductID = "com.zzoutuo.PawSync.pro.yearly"
    static let lifetimeProductID = "com.zzoutuo.PawSync.pro.lifetime"

    var hasFullAccess: Bool {
        isPremium || isTrialActive
    }

    var trialDaysRemaining: Int {
        guard let endDate = trialEndDate else { return 0 }
        let remaining = Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0
        return max(0, remaining)
    }

    private init() {}

    func checkTrialStatus() async {
        await updateSubscriptionStatus()

        if isPremium { return }

        if let startDateData = UserDefaults.standard.object(forKey: trialStartKey) as? Date {
            let endDate = Calendar.current.date(byAdding: .day, value: trialDurationDays, to: startDateData) ?? startDateData
            trialEndDate = endDate
            isTrialActive = Date() < endDate
        } else {
            let now = Date()
            UserDefaults.standard.set(now, forKey: trialStartKey)
            trialEndDate = Calendar.current.date(byAdding: .day, value: trialDurationDays, to: now)
            isTrialActive = true
        }
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: [
                Self.monthlyProductID,
                Self.yearlyProductID,
                Self.lifetimeProductID
            ])
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await updateSubscriptionStatus()
            return true
        case .userCancelled:
            return false
        case .pending:
            return false
        @unknown default:
            return false
        }
    }

    func restorePurchases() async {
        try? await AppStore.sync()
        await updateSubscriptionStatus()
    }

    private func updateSubscriptionStatus() async {
        var hasActive = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == Self.monthlyProductID ||
                   transaction.productID == Self.yearlyProductID ||
                   transaction.productID == Self.lifetimeProductID {
                    hasActive = true
                }
            }
        }
        isPremium = hasActive
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    var monthlyProduct: Product? {
        products.first { $0.id == Self.monthlyProductID }
    }

    var yearlyProduct: Product? {
        products.first { $0.id == Self.yearlyProductID }
    }

    var lifetimeProduct: Product? {
        products.first { $0.id == Self.lifetimeProductID }
    }
}

enum StoreError: Error {
    case failedVerification
}
