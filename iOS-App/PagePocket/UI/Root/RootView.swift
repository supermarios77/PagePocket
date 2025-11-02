import SwiftUI
import SwiftData

struct RootView: View {
    @StateObject private var viewModel: RootViewModel
    @State private var selectedTab: Tab = .home

    enum Tab: Int {
        case home = 0
        case browser = 1
        case downloads = 2
    }

    init(viewModel: RootViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView(
                    viewModel: viewModel.makeHomeViewModel(),
                    selectedTab: $selectedTab
                )
            }
            .tabItem {
                Label(String(localized: "home.tab.title"), systemImage: "house")
            }
            .tag(Tab.home)

            NavigationStack {
                BrowserView(viewModel: viewModel.makeBrowserViewModel())
            }
            .tabItem {
                Label(String(localized: "browser.tab.title"), systemImage: "safari")
            }
            .tag(Tab.browser)

            NavigationStack {
                DownloadsView(viewModel: viewModel.makeDownloadsViewModel())
            }
            .tabItem {
                Label(String(localized: "downloads.tab.title"), systemImage: "arrow.down.circle")
            }
            .tag(Tab.downloads)
        }
    }
}

#Preview {
    RootView(viewModel: RootViewModel(appEnvironment: AppEnvironment()))
        .modelContainer(for: SavedPageEntity.self, inMemory: true)
}

// Extension to make Tab available to HomeView
extension RootView.Tab: @retroactive Equatable {}

