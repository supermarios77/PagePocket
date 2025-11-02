//
//  PurchaseService.swift
//  PagePocket
//

import Foundation

/// Service for managing in-app purchases and subscription entitlements
protocol PurchaseService: Sendable {
    /// Current user subscription entitlements
    var currentEntitlements: SubscriptionEntitlements { get }
    
    /// Load available subscription products from App Store
    func loadProducts() async throws -> [SubscriptionProduct]
    
    /// Purchase a subscription product
    func purchase(_ productID: ProductID) async throws
    
    /// Restore previous purchases
    func restorePurchases() async throws
    
    /// Check if user has access to a feature
    func hasAccess(to feature: PremiumFeature) -> Bool
    
    /// Stream of entitlement updates
    func entitlementUpdates() -> AsyncStream<SubscriptionEntitlements>
}

/// Subscription product information
struct SubscriptionProduct: Identifiable, Hashable {
    let id: ProductID
    let displayName: String
    let price: Decimal
    let localizedPrice: String
    let duration: SubscriptionDuration
    let productInfo: ProductInfo?
    
    /// Additional product metadata
    struct ProductInfo: Hashable {
        let description: String
        let introOffer: String?
    }
}

/// Premium features that require subscription
enum PremiumFeature: String, CaseIterable {
    case unlimitedPages = "unlimited_pages"
    case cloudSync = "cloud_sync"
    
    var displayName: String {
        switch self {
        case .unlimitedPages: "Unlimited Pages"
        case .cloudSync: "Cloud Sync"
        }
    }
}

/// Errors that can occur during purchase flow
enum PurchaseError: LocalizedError {
    case productNotFound
    case purchaseCancelled
    case purchaseFailed(String)
    case receiptValidationFailed
    case networkError
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .productNotFound:
            "The requested product is not available."
        case .purchaseCancelled:
            "Purchase was cancelled."
        case .purchaseFailed(let reason):
            "Purchase failed: \(reason)"
        case .receiptValidationFailed:
            "Unable to verify purchase. Please try again."
        case .networkError:
            "Network error. Please check your connection."
        case .unknown(let error):
            "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}

