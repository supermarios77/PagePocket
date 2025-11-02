import Combine

@MainActor
final class RootViewModel: ObservableObject {
    private let appEnvironment: AppEnvironment

    init(appEnvironment: AppEnvironment) {
        self.appEnvironment = appEnvironment
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(offlineReaderService: appEnvironment.offlineReaderService)
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
        SettingsViewModel()
    }
}

