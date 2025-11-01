import SwiftUI
import SwiftData

struct RootView: View {
    @StateObject private var viewModel: RootViewModel

    init(viewModel: RootViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(viewModel: viewModel.makeHomeViewModel())
            }
            .tabItem {
                Label(String(localized: "home.tab.title"), systemImage: "house")
            }

            NavigationStack {
                BrowserView(viewModel: viewModel.makeBrowserViewModel())
            }
            .tabItem {
                Label(String(localized: "browser.tab.title"), systemImage: "safari")
            }

            NavigationStack {
                DownloadsView(viewModel: viewModel.makeDownloadsViewModel())
            }
            .tabItem {
                Label(String(localized: "downloads.tab.title"), systemImage: "arrow.down.circle")
            }
        }
    }
}

#Preview {
    RootView(viewModel: RootViewModel(appEnvironment: AppEnvironment()))
        .modelContainer(for: SavedPageEntity.self, inMemory: true)
}

