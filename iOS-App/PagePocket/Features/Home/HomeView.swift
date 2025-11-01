import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                heroSection

                SectionHeader(
                    titleKey: "home.quickActions.title",
                    subtitleKey: "home.quickActions.subtitle"
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(HomeViewData.quickActions) { action in
                            PlaceholderCard(
                                titleKey: action.titleKey,
                                descriptionKey: action.subtitleKey,
                                systemImageName: action.systemImageName
                            )
                        }
                    }
                    .padding(.horizontal, 2)
                }

                SectionHeader(
                    titleKey: "home.readingList.title",
                    subtitleKey: "home.readingList.subtitle"
                )

                VStack(spacing: 0) {
                    ForEach(HomeViewData.readingList) { item in
                        PlaceholderListRow(
                            titleKey: item.titleKey,
                            subtitleKey: item.subtitleKey,
                            statusKey: item.statusKey,
                            systemImageName: item.systemImageName
                        )

                        if item.id != HomeViewData.readingList.last?.id {
                            Divider()
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(.secondarySystemBackground))
                )

                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(
                        titleKey: "home.offlineTips.title",
                        subtitleKey: "home.offlineTips.subtitle"
                    )

                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(HomeViewData.offlineTips) { tip in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: tip.systemImageName)
                                    .font(.headline)
                                    .foregroundStyle(Color.accentColor)
                                    .padding(8)
                                    .background(Color.accentColor.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))

                                VStack(alignment: .leading, spacing: 6) {
                                    Text(tip.titleKey)
                                        .font(.subheadline.bold())
                                        .foregroundStyle(.primary)

                                    Text(tip.subtitleKey)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Color.accentColor.opacity(0.2), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("home.navigation.title")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel("home.navigation.settings")
            }
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("home.hero.title")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)

                Text("home.hero.subtitle")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                Button(action: {}) {
                    Label("home.hero.primaryAction", systemImage: "plus")
                        .labelStyle(.titleAndIcon)
                }
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityIdentifier("home-hero-primary-button")

                Button(action: {}) {
                    Label("home.hero.secondaryAction", systemImage: "bookmark")
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
}

private enum HomeViewData {
    struct QuickAction: Identifiable, Equatable {
        let id = UUID()
        let titleKey: LocalizedStringKey
        let subtitleKey: LocalizedStringKey
        let systemImageName: String
    }

    struct ReadingItem: Identifiable, Equatable {
        let id = UUID()
        let titleKey: LocalizedStringKey
        let subtitleKey: LocalizedStringKey
        let statusKey: LocalizedStringKey?
        let systemImageName: String
    }

    struct OfflineTip: Identifiable, Equatable {
        let id = UUID()
        let titleKey: LocalizedStringKey
        let subtitleKey: LocalizedStringKey
        let systemImageName: String
    }

    static let quickActions: [QuickAction] = [
        QuickAction(
            titleKey: "home.quickActions.capture.title",
            subtitleKey: "home.quickActions.capture.subtitle",
            systemImageName: "tray.and.arrow.down"
        ),
        QuickAction(
            titleKey: "home.quickActions.collections.title",
            subtitleKey: "home.quickActions.collections.subtitle",
            systemImageName: "rectangle.3.group.bubble.left"
        ),
        QuickAction(
            titleKey: "home.quickActions.sync.title",
            subtitleKey: "home.quickActions.sync.subtitle",
            systemImageName: "icloud.and.arrow.down"
        )
    ]

    static let readingList: [ReadingItem] = [
        ReadingItem(
            titleKey: "home.readingList.item1.title",
            subtitleKey: "home.readingList.item1.subtitle",
            statusKey: "home.readingList.item.status.new",
            systemImageName: "globe"
        ),
        ReadingItem(
            titleKey: "home.readingList.item2.title",
            subtitleKey: "home.readingList.item2.subtitle",
            statusKey: "home.readingList.item.status.progress",
            systemImageName: "doc.richtext"
        ),
        ReadingItem(
            titleKey: "home.readingList.item3.title",
            subtitleKey: "home.readingList.item3.subtitle",
            statusKey: "home.readingList.item.status.completed",
            systemImageName: "bookmark"
        )
    ]

    static let offlineTips: [OfflineTip] = [
        OfflineTip(
            titleKey: "home.offlineTips.item1.title",
            subtitleKey: "home.offlineTips.item1.subtitle",
            systemImageName: "wifi.slash"
        ),
        OfflineTip(
            titleKey: "home.offlineTips.item2.title",
            subtitleKey: "home.offlineTips.item2.subtitle",
            systemImageName: "square.and.arrow.down.on.square"
        ),
        OfflineTip(
            titleKey: "home.offlineTips.item3.title",
            subtitleKey: "home.offlineTips.item3.subtitle",
            systemImageName: "bell.badge"
        )
    ]
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}

