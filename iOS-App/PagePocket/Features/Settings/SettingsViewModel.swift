import Combine
import Foundation

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

    enum ThemePreference: String, CaseIterable {
        case system
        case light
        case dark
    }

    @Published var theme: ThemePreference {
        didSet {
            UserDefaults.standard.set(theme.rawValue, forKey: "appTheme")
        }
    }

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

    init() {
        // Load saved preferences
        let savedTheme = UserDefaults.standard.string(forKey: "appTheme") ?? "system"
        self.theme = ThemePreference(rawValue: savedTheme) ?? .system
        self.autoDownload = UserDefaults.standard.bool(forKey: "autoDownload")
        self.downloadOverWiFi = UserDefaults.standard.bool(forKey: "downloadOverWiFi")
    }

    func clearCache() async {
        // For now, this is just a placeholder
        // In a production app, this would clear any cached data
        try? await Task.sleep(nanoseconds: 500_000_000) // Simulate async work
        
        // In a real implementation, you would:
        // 1. Clear WKWebView cache
        // 2. Clear any image caches
        // 3. Clear any other cached data
        
        cacheFeedback = CacheFeedback(kind: .success)
    }
}

