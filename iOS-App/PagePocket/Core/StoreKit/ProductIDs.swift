//
//  ProductIDs.swift
//  PagePocket
//

import Foundation

/// App Store Connect product identifiers for in-app purchases
enum ProductID: String, CaseIterable, Identifiable, Codable {
    case weekly = "com.pagepocket.premium.weekly"
    case monthly = "com.pagepocket.premium.monthly"
    case yearly = "com.pagepocket.premium.yearly"
    
    var id: String { rawValue }
    
    /// Human-readable product name
    var displayName: String {
        switch self {
        case .weekly: "Weekly"
        case .monthly: "Monthly"
        case .yearly: "Yearly"
        }
    }
    
    /// Locale-specific price (fetched from StoreKit)
    var localizedPrice: String? { nil }
    
    /// Product purchase duration
    var duration: SubscriptionDuration {
        switch self {
        case .weekly: .weekly
        case .monthly: .monthly
        case .yearly: .yearly
        }
    }
    
    /// Optimal tier based on best value (yearly)
    static var recommended: ProductID { .yearly }
}

/// Subscription duration types
enum SubscriptionDuration: String, Codable, Identifiable {
    case weekly
    case monthly
    case yearly
    
    var id: String { rawValue }
    
    /// Duration in days
    var days: Int {
        switch self {
        case .weekly: 7
        case .monthly: 30
        case .yearly: 365
        }
    }
    
    /// Display name for duration
    var displayName: String {
        switch self {
        case .weekly: "per week"
        case .monthly: "per month"
        case .yearly: "per year"
        }
    }
    
    /// Best value badge (for yearly)
    var isBestValue: Bool {
        self == .yearly
    }
}

