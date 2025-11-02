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
                iconName: "book.closed.fill",
                title: String(localized: "onboarding.welcome.title"),
                description: String(localized: "onboarding.welcome.description")
            ),
            Page(
                iconName: "wifi.slash",
                title: String(localized: "onboarding.feature.offline.title"),
                description: String(localized: "onboarding.feature.offline.description")
            ),
            Page(
                iconName: "arrow.triangle.2.circlepath",
                title: String(localized: "onboarding.feature.sync.title"),
                description: String(localized: "onboarding.feature.sync.description")
            ),
            Page(
                iconName: "tray.fill",
                title: String(localized: "onboarding.feature.organize.title"),
                description: String(localized: "onboarding.feature.organize.description")
            )
        ]
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        onComplete?()
    }
    
    static var hasCompletedOnboarding: Bool {
        UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
}

