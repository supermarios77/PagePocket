import Combine

import SwiftUI

@MainActor
final class RootViewModel: ObservableObject {
    private let appEnvironment: AppEnvironment

    var theme: AppEnvironment.ThemePreference {
        appEnvironment.theme
    }

    init(appEnvironment: AppEnvironment) {
        self.appEnvironment = appEnvironment
    }

    func makeThemeBinding() -> Binding<AppEnvironment.ThemePreference> {
        Binding(
            get: { self.appEnvironment.theme },
            set: { self.appEnvironment.theme = $0 }
        )
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(offlineReaderService: appEnvironment.offlineReaderService, purchaseService: appEnvironment.purchaseService)
    }

    func makeBrowserViewModel() -> BrowserViewModel {
        BrowserViewModel(
            offlineReaderService: appEnvironment.offlineReaderService,
            downloadService: appEnvironment.downloadService
        )
    }

    func makeDownloadsViewModel() -> DownloadsViewModel {
        DownloadsViewModel(
            downloadService: appEnvironment.downloadService,
            offlineReaderService: appEnvironment.offlineReaderService
        )
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(theme: makeThemeBinding(), purchaseService: appEnvironment.purchaseService)
    }
    
    func makePaywallViewModel() -> PaywallViewModel {
        PaywallViewModel(purchaseService: appEnvironment.purchaseService)
    }
}

