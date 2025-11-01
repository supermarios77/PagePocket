import Combine

@MainActor
final class RootViewModel: ObservableObject {
    private let appEnvironment: AppEnvironment

    init(appEnvironment: AppEnvironment) {
        self.appEnvironment = appEnvironment
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel()
    }

    func makeBrowserViewModel() -> BrowserViewModel {
        BrowserViewModel()
    }

    func makeDownloadsViewModel() -> DownloadsViewModel {
        DownloadsViewModel()
    }
}

