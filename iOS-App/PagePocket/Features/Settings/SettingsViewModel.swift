import Combine
import Foundation
import SwiftUI
import WebKit

@MainActor
final class SettingsViewModel: ObservableObject {
    struct CacheFeedback: Identifiable, Equatable {
        enum Kind: Equatable {
            case success
            case failure
        }

        let id = UUID()
        let kind: Kind
    }

    var theme: Binding<AppEnvironment.ThemePreference>
    let purchaseService: PurchaseService

    @Published private(set) var isPremium: Bool = false
    
    @Published var autoDownload: Bool {
        didSet {
            UserDefaults.standard.set(autoDownload, forKey: "autoDownload")
        }
    }

    @Published var downloadOverWiFi: Bool {
        didSet {
            UserDefaults.standard.set(downloadOverWiFi, forKey: "downloadOverWiFi")
        }
    }

    @Published var cacheFeedback: CacheFeedback?

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var feedbackURL: URL {
        URL(string: "https://github.com/supermarios77/PagePocket/issues")!
    }

    init(theme: Binding<AppEnvironment.ThemePreference>, purchaseService: PurchaseService) {
        self.theme = theme
        self.purchaseService = purchaseService
        self.autoDownload = UserDefaults.standard.bool(forKey: "autoDownload")
        self.downloadOverWiFi = UserDefaults.standard.bool(forKey: "downloadOverWiFi")
        self.isPremium = purchaseService.currentEntitlements.isPremium
        
        // Subscribe to entitlement updates
        Task { [weak self] in
            guard let self else { return }
            for await _ in purchaseService.entitlementUpdates() {
                await MainActor.run {
                    self.isPremium = self.purchaseService.currentEntitlements.isPremium
                }
            }
        }
    }
    
    func refreshPremiumStatus() {
        isPremium = purchaseService.currentEntitlements.isPremium
    }

    func clearCache() async {
        do {
            // Clear WKWebView cache
            let dataStore = WKWebsiteDataStore.default()
            let types = WKWebsiteDataStore.allWebsiteDataTypes()
            try await dataStore.removeData(ofTypes: types, modifiedSince: Date(timeIntervalSince1970: 0))
            
            // Clear URLCache
            URLCache.shared.removeAllCachedResponses()
            
            cacheFeedback = CacheFeedback(kind: .success)
        } catch {
            cacheFeedback = CacheFeedback(kind: .failure)
        }
    }
}

