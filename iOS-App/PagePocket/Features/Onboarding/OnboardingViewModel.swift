import Combine
import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    struct Page: Identifiable {
        let id = UUID()
        let iconName: String
        let title: String
        let description: String
    }
    
    let pages: [Page]
    var onComplete: (() -> Void)?
    
    init() {
        self.pages = [
            Page(
                iconName: "sparkles",
                title: String(localized: "onboarding.congrats.title"),
                description: String(localized: "onboarding.congrats.description")
            ),
            Page(
                iconName: "wifi.slash",
                title: String(localized: "onboarding.feature.offline.title"),
                description: String(localized: "onboarding.feature.offline.description")
            ),
            Page(
                iconName: "bolt.fill",
                title: String(localized: "onboarding.feature.fast.title"),
                description: String(localized: "onboarding.feature.fast.description")
            ),
            Page(
                iconName: "tray.fill",
                title: String(localized: "onboarding.feature.organized.title"),
                description: String(localized: "onboarding.feature.organized.description")
            )
        ]
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: AppConstants.UserDefaultsKeys.hasCompletedOnboarding)
        onComplete?()
    }
    
    static var hasCompletedOnboarding: Bool {
        UserDefaults.standard.bool(forKey: AppConstants.UserDefaultsKeys.hasCompletedOnboarding)
    }
}

