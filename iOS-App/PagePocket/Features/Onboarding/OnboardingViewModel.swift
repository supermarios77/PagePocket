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
                iconName: "safari",
                title: String(localized: "onboarding.howto.title"),
                description: String(localized: "onboarding.howto.description")
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

