//
//  MockPurchaseService.swift
//  PagePocket
//

import Foundation

/// Mock implementation of PurchaseService for testing and development
/// This simulates StoreKit behavior without requiring App Store Connect setup
actor MockPurchaseService: PurchaseService {
    private(set) var currentEntitlements: SubscriptionEntitlements
    private var observers: [UUID: AsyncStream<SubscriptionEntitlements>.Continuation] = [:]
    private var isPremiumOverride: Bool = false // Allow manual override in testing
    
    init(initialEntitlements: SubscriptionEntitlements = .free) {
        self.currentEntitlements = initialEntitlements
    }
    
    func loadProducts() async throws -> [SubscriptionProduct] {
        // Simulate network delay
        try await Task.sleep(for: .seconds(0.5))
        
        return ProductID.allCases.map { productID in
            SubscriptionProduct(
                id: productID,
                displayName: productID.displayName,
                price: mockPrice(for: productID),
                localizedPrice: mockLocalizedPrice(for: productID),
                duration: productID.duration,
                productInfo: SubscriptionProduct.ProductInfo(
                    description: "Access to all premium features including unlimited page storage and cloud sync.",
                    introOffer: nil
                )
            )
        }
    }
    
    func purchase(_ productID: ProductID) async throws {
        // Simulate purchase flow
        try await Task.sleep(for: .seconds(1.5))
        
        // Simulate 10% failure rate for testing
        if Int.random(in: 1...10) == 1 {
            throw PurchaseError.purchaseFailed("Payment was declined")
        }
        
        // Update entitlements
        let expiration = Calendar.current.date(
            byAdding: DateComponents(day: productID.duration.days),
            to: Date()
        ) ?? Date()
        
        currentEntitlements = SubscriptionEntitlements.premium(
            expiresAt: expiration,
            productID: productID
        )
        
        notifyObservers()
        
        // Persist to UserDefaults for testing persistence
        await saveEntitlements(currentEntitlements)
    }
    
    func restorePurchases() async throws {
        try await Task.sleep(for: .seconds(1))
        
        // Load from UserDefaults
        if let loaded = await loadEntitlements(), loaded.isPremium {
            currentEntitlements = loaded
            notifyObservers()
        }
    }
    
    func hasAccess(to feature: PremiumFeature) -> Bool {
        guard currentEntitlements.isPremium else { return false }
        
        switch feature {
        case .unlimitedPages:
            return true
        case .cloudSync:
            return currentEntitlements.cloudSyncEnabled
        }
    }
    
    func entitlementUpdates() -> AsyncStream<SubscriptionEntitlements> {
        AsyncStream { continuation in
            let token = UUID()
            observers[token] = continuation
            continuation.yield(currentEntitlements)
            
            continuation.onTermination = { _ in
                Task { await self.removeObserver(token) }
            }
        }
    }
    
    // MARK: - Mock Helpers
    
    /// Manually set premium status (for testing)
    func setPremium(_ isPremium: Bool) {
        if isPremium {
            let expiration = Calendar.current.date(
                byAdding: DateComponents(year: 1),
                to: Date()
            ) ?? Date()
            currentEntitlements = SubscriptionEntitlements.premium(
                expiresAt: expiration,
                productID: .yearly
            )
        } else {
            currentEntitlements = .free
        }
        Task { await notifyObservers() }
        Task { await saveEntitlements(currentEntitlements) }
    }
    
    // MARK: - Private
    
    private func notifyObservers() {
        observers.values.forEach { $0.yield(currentEntitlements) }
    }
    
    private func removeObserver(_ token: UUID) {
        observers.removeValue(forKey: token)
    }
    
    private func mockPrice(for productID: ProductID) -> Decimal {
        switch productID {
        case .weekly: 2.99
        case .monthly: 4.99
        case .yearly: 39.99
        }
    }
    
    private func mockLocalizedPrice(for productID: ProductID) -> String {
        let price = mockPrice(for: productID)
        return String(format: "$%.2f", Double(truncating: price as NSDecimalNumber))
    }
    
    private func saveEntitlements(_ entitlements: SubscriptionEntitlements) async {
        if let encoded = try? JSONEncoder().encode(entitlements) {
            UserDefaults.standard.set(encoded, forKey: "mock_premium_entitlements")
        }
    }
    
    private func loadEntitlements() async -> SubscriptionEntitlements? {
        guard let data = UserDefaults.standard.data(forKey: "mock_premium_entitlements") else {
            return nil
        }
        return try? JSONDecoder().decode(SubscriptionEntitlements.self, from: data)
    }
}

