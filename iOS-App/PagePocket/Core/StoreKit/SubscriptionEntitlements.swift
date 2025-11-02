//
//  SubscriptionEntitlements.swift
//  PagePocket
//

import Foundation

/// User's subscription status and entitlements
struct SubscriptionEntitlements: Codable, Equatable {
    /// Whether user has an active premium subscription
    let isPremium: Bool
    
    /// Number of pages user can save (nil = unlimited for premium)
    let maxPagesAllowed: Int?
    
    /// Whether cloud sync is enabled
    let cloudSyncEnabled: Bool
    
    /// Subscription expiration date (nil if not premium)
    let expiresAt: Date?
    
    /// Currently active product ID
    let activeProductID: ProductID?
    
    /// Whether subscription is in grace period
    let isInGracePeriod: Bool
    
    /// Grace period expiration date
    let gracePeriodExpiresAt: Date?
    
    init(
        isPremium: Bool = false,
        maxPagesAllowed: Int? = nil,
        cloudSyncEnabled: Bool = false,
        expiresAt: Date? = nil,
        activeProductID: ProductID? = nil,
        isInGracePeriod: Bool = false,
        gracePeriodExpiresAt: Date? = nil
    ) {
        self.isPremium = isPremium
        self.maxPagesAllowed = maxPagesAllowed
        self.cloudSyncEnabled = cloudSyncEnabled
        self.expiresAt = expiresAt
        self.activeProductID = activeProductID
        self.isInGracePeriod = isInGracePeriod
        self.gracePeriodExpiresAt = gracePeriodExpiresAt
    }
    
    /// Default entitlements for free tier
    static var free: SubscriptionEntitlements {
        SubscriptionEntitlements(
            isPremium: false,
            maxPagesAllowed: 2,
            cloudSyncEnabled: false,
            expiresAt: nil,
            activeProductID: nil,
            isInGracePeriod: false,
            gracePeriodExpiresAt: nil
        )
    }
    
    /// Premium entitlements with unlimited pages and cloud sync
    static func premium(
        expiresAt: Date,
        productID: ProductID,
        isInGracePeriod: Bool = false,
        gracePeriodExpiresAt: Date? = nil
    ) -> SubscriptionEntitlements {
        SubscriptionEntitlements(
            isPremium: true,
            maxPagesAllowed: nil,
            cloudSyncEnabled: true,
            expiresAt: expiresAt,
            activeProductID: productID,
            isInGracePeriod: isInGracePeriod,
            gracePeriodExpiresAt: gracePeriodExpiresAt
        )
    }
    
    /// Check if subscription is valid (active or in grace period)
    var isValid: Bool {
        guard isPremium else { return false }
        guard let expiresAt else { return true }
        
        let now = Date()
        if isInGracePeriod, let graceExpires = gracePeriodExpiresAt {
            return now <= graceExpires
        }
        return now <= expiresAt
    }
    
    /// Check if user can save more pages
    func canSavePage(currentPageCount: Int) -> Bool {
        guard !isValid else { return true } // Premium users can always save
        guard let maxPagesAllowed else { return true } // Shouldn't happen, but safety check
        return currentPageCount < maxPagesAllowed
    }
    
    /// Number of pages remaining (nil = unlimited)
    func remainingPages(currentPageCount: Int) -> Int? {
        guard !isValid else { return nil }
        guard let maxPagesAllowed else { return nil }
        let remaining = maxPagesAllowed - currentPageCount
        return max(0, remaining)
    }
}

/// Subscription status for UI presentation
enum SubscriptionStatus: Equatable {
    case free
    case active
    case expired
    case gracePeriod
    case cancelled
    case unknown
    
    init(entitlements: SubscriptionEntitlements) {
        guard entitlements.isPremium else {
            self = .free
            return
        }
        
        if entitlements.isValid {
            if entitlements.isInGracePeriod {
                self = .gracePeriod
            } else {
                self = .active
            }
        } else {
            self = .expired
        }
    }
}

