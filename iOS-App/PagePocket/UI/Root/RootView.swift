import SwiftUI

struct RootView: View {
    @StateObject private var viewModel: RootViewModel

    init(viewModel: RootViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(viewModel: viewModel.makeHomeViewModel())
                    .navigationTitle("placeholder.root.title")
            }
            .tabItem {
                Label("placeholder.home.tab", systemImage: "house")
            }

            NavigationStack {
                BrowserView(viewModel: viewModel.makeBrowserViewModel())
                    .navigationTitle("placeholder.browser.message")
            }
            .tabItem {
                Label("placeholder.browser.tab", systemImage: "safari")
            }

            NavigationStack {
                DownloadsView(viewModel: viewModel.makeDownloadsViewModel())
                    .navigationTitle("placeholder.downloads.message")
            }
            .tabItem {
                Label("placeholder.downloads.tab", systemImage: "arrow.down.circle")
            }
        }
    }
}

#Preview {
    RootView(viewModel: RootViewModel(appEnvironment: AppEnvironment()))
}

