import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @Binding var selectedTab: RootView.Tab
    @State private var presentedError: String?

    init(viewModel: HomeViewModel, selectedTab: Binding<RootView.Tab>) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _selectedTab = selectedTab
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                heroSection

                SectionHeader(
                    title: String(localized: "home.quickActions.title"),
                    subtitle: String(localized: "home.quickActions.subtitle")
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.quickActions) { action in
                            Button(action: {
                                handleQuickAction(action)
                            }) {
                                PlaceholderCard(
                                    title: action.title,
                                    description: action.subtitle,
                                    systemImageName: action.systemImageName
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 2)
                }

                SectionHeader(
                    title: String(localized: "home.readingList.title"),
                    subtitle: String(localized: "home.readingList.subtitle")
                )

                VStack(spacing: 0) {
                    ForEach(viewModel.readingList) { item in
                        NavigationLink {
                            OfflineReaderView(viewModel: viewModel.makeReaderViewModel(for: item.id))
                        } label: {
                            PlaceholderListRow(
                                title: item.title,
                                subtitle: item.subtitle,
                                status: item.status,
                                systemImageName: item.systemImageName
                            )
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(String(localized: "home.readingList.item.delete"), role: .destructive) {
                                Task {
                                    await viewModel.deletePage(item.id)
                                }
                            }
                            .accessibilityLabel(String(localized: "home.readingList.item.delete"))
                        }

                        if item.id != viewModel.readingList.last?.id {
                            Divider()
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(.secondarySystemBackground))
                )

            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(String(localized: "home.navigation.title"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel(String(localized: "home.navigation.settings"))
            }
        }
        .overlay(alignment: .top) {
            if viewModel.isLoading {
                ProgressView()
                    .padding(.top, 12)
            }
        }
        .task {
            await viewModel.loadContentIfNeeded()
        }
        .onChange(of: viewModel.errorMessage) { newValue in
            presentedError = newValue
        }
        .alert(String(localized: "home.error.title"), isPresented: Binding(get: {
            presentedError != nil
        }, set: { newValue in
            if !newValue {
                presentedError = nil
            }
        })) {
            Button(String(localized: "common.ok"), role: .cancel) {
                presentedError = nil
            }
        } message: {
            Text(presentedError ?? "")
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text(String(localized: "home.hero.title"))
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)

                Text(String(localized: "home.hero.subtitle"))
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                Button(action: {
                    Task {
                        await viewModel.createSamplePage()
                    }
                }) {
                    Label(String(localized: "home.hero.primaryAction"), systemImage: "plus")
                        .labelStyle(.titleAndIcon)
                }
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityIdentifier("home-hero-primary-button")

                Button(action: {
                    Task {
                        await viewModel.markFirstItemInProgress()
                    }
                }) {
                    Label(String(localized: "home.hero.secondaryAction"), systemImage: "bookmark")
                        .labelStyle(.titleAndIcon)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .tint(Color(.systemGray5))
                .foregroundStyle(.primary)
                .accessibilityIdentifier("home-hero-secondary-button")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func handleQuickAction(_ action: HomeViewModel.QuickAction) {
        switch action.action {
        case .navigateToBrowser:
            selectedTab = RootView.Tab.browser
        case .navigateToDownloads:
            selectedTab = RootView.Tab.downloads
        }
    }
}

#Preview {
    HomeView(
        viewModel: HomeViewModel(offlineReaderService: StubOfflineReaderService()),
        selectedTab: .constant(.home)
    )
}

