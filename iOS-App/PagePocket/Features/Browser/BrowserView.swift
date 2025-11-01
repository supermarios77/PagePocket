//
//  BrowserView.swift
//  PagePocket


import SwiftUI

struct BrowserView: View {
    @StateObject private var viewModel: BrowserViewModel
    @State private var query: String = ""

    init(viewModel: BrowserViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                searchField

                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(
                        titleKey: "browser.recentSessions.title",
                        subtitleKey: "browser.recentSessions.subtitle"
                    )

                    VStack(spacing: 16) {
                        ForEach(BrowserViewData.recentSessions) { session in
                            PlaceholderListRow(
                                titleKey: session.titleKey,
                                subtitleKey: session.subtitleKey,
                                statusKey: session.statusKey,
                                systemImageName: session.systemImageName
                            )
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color(.secondarySystemBackground))
                            )
                        }
                    }
                }

                SectionHeader(
                    titleKey: "browser.suggestedActions.title",
                    subtitleKey: "browser.suggestedActions.subtitle"
                )

                LazyVGrid(columns: BrowserViewData.gridColumns, spacing: 16) {
                    ForEach(BrowserViewData.suggestedActions) { action in
                        VStack(alignment: .leading, spacing: 12) {
                            Image(systemName: action.systemImageName)
                                .font(.title2)
                                .foregroundStyle(Color.accentColor)
                                .padding(12)
                                .background(Color.accentColor.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            VStack(alignment: .leading, spacing: 6) {
                                Text(action.titleKey)
                                    .font(.headline)

                                Text(action.subtitleKey)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(Color.accentColor.opacity(0.15), lineWidth: 1)
                        )
                    }
                }

                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(
                        titleKey: "browser.offlinePreview.title",
                        subtitleKey: "browser.offlinePreview.subtitle"
                    )

                    PlaceholderCard(
                        titleKey: "browser.offlinePreview.card.title",
                        descriptionKey: "browser.offlinePreview.card.subtitle",
                        systemImageName: "arrow.down.doc"
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("browser.navigation.title")
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button("browser.keyboard.dismiss", role: .cancel) {
                    query = ""
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel("browser.navigation.menu")
            }
        }
    }

    private var searchField: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("browser.search.title")
                .font(.title3.bold())

            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("browser.search.placeholder", text: $query)
                    .textFieldStyle(.plain)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
            )

            Button(action: {}) {
                Label("browser.search.action", systemImage: "safari")
                    .labelStyle(.titleAndIcon)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .tint(Color.accentColor.opacity(0.85))
            .accessibilityIdentifier("browser-search-go-button")
        }
    }
}

private enum BrowserViewData {
    struct RecentSession: Identifiable, Equatable {
        let id = UUID()
        let titleKey: LocalizedStringKey
        let subtitleKey: LocalizedStringKey
        let statusKey: LocalizedStringKey?
        let systemImageName: String
    }

    struct SuggestedAction: Identifiable, Equatable {
        let id = UUID()
        let titleKey: LocalizedStringKey
        let subtitleKey: LocalizedStringKey
        let systemImageName: String
    }

    static let gridColumns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)

    static let recentSessions: [RecentSession] = [
        RecentSession(
            titleKey: "browser.recentSessions.item1.title",
            subtitleKey: "browser.recentSessions.item1.subtitle",
            statusKey: "browser.recentSessions.item.status.synced",
            systemImageName: "doc.text.magnifyingglass"
        ),
        RecentSession(
            titleKey: "browser.recentSessions.item2.title",
            subtitleKey: "browser.recentSessions.item2.subtitle",
            statusKey: "browser.recentSessions.item.status.updated",
            systemImageName: "newspaper"
        )
    ]

    static let suggestedActions: [SuggestedAction] = [
        SuggestedAction(
            titleKey: "browser.suggestedActions.item1.title",
            subtitleKey: "browser.suggestedActions.item1.subtitle",
            systemImageName: "bookmark.circle"
        ),
        SuggestedAction(
            titleKey: "browser.suggestedActions.item2.title",
            subtitleKey: "browser.suggestedActions.item2.subtitle",
            systemImageName: "clock.arrow.circlepath"
        ),
        SuggestedAction(
            titleKey: "browser.suggestedActions.item3.title",
            subtitleKey: "browser.suggestedActions.item3.subtitle",
            systemImageName: "globe.europe.africa"
        ),
        SuggestedAction(
            titleKey: "browser.suggestedActions.item4.title",
            subtitleKey: "browser.suggestedActions.item4.subtitle",
            systemImageName: "arrow.down.doc"
        )
    ]
}

#Preview {
    BrowserView(viewModel: BrowserViewModel())
}

