//
//  Constants.swift
//  PagePocket
//
//  Production constants and configuration values
//

import Foundation

enum AppConstants {
    // Network
    enum Network {
        static let requestTimeout: TimeInterval = 30.0
        static let resourceTimeout: TimeInterval = 60.0
        static let maxConnectionsPerHost = 3
        static let maxURLLength = 8000 // RFC 7230 recommendation
    }
    
    // Content Limits
    enum Content {
        static let maxPageSizeBytes = 50 * 1024 * 1024 // 50MB
        static let freeTierPageLimit = 2
    }
    
    // UserDefaults Keys
    enum UserDefaultsKeys {
        static let appTheme = "appTheme"
        static let autoDownload = "autoDownload"
        static let downloadOverWiFi = "downloadOverWiFi"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let mockPremiumEntitlements = "mock_premium_entitlements"
    }
    
    // CloudKit
    enum CloudKit {
        static let recordType = "SavedPage"
        static let resultsLimit = 100
    }
}

