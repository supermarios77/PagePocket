//
//  BrowserView.swift
//  PagePocket


import SwiftUI

struct BrowserView: View {
    @StateObject private var viewModel: BrowserViewModel
    @State private var presentedFeedback: BrowserViewModel.CaptureFeedback?

    init(viewModel: BrowserViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                searchField

                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(
                        title: String(localized: "browser.recentSessions.title"),
                        subtitle: String(localized: "browser.recentSessions.subtitle")
                    )

                    VStack(spacing: 16) {
                        ForEach(viewModel.recentSessions) { session in
                            PlaceholderListRow(
                                title: session.title,
                                subtitle: session.subtitle,
                                status: session.status,
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
                    title: String(localized: "browser.suggestedActions.title"),
                    subtitle: String(localized: "browser.suggestedActions.subtitle")
                )

                LazyVGrid(columns: gridColumns, spacing: 16) {
                    ForEach(viewModel.suggestedActions) { action in
                        VStack(alignment: .leading, spacing: 12) {
                            Image(systemName: action.systemImageName)
                                .font(.title2)
                                .foregroundStyle(Color.accentColor)
                                .padding(12)
                                .background(Color.accentColor.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            VStack(alignment: .leading, spacing: 6) {
                                Text(action.title)
                                    .font(.headline)

                                Text(action.subtitle)
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
                        title: String(localized: "browser.offlinePreview.title"),
                        subtitle: String(localized: "browser.offlinePreview.subtitle")
                    )

                    PlaceholderCard(
                        title: viewModel.offlinePreview.title,
                        description: viewModel.offlinePreview.description,
                        systemImageName: viewModel.offlinePreview.systemImageName
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(String(localized: "browser.navigation.title"))
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button(String(localized: "browser.keyboard.dismiss"), role: .cancel) {
                    viewModel.query = ""
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel(String(localized: "browser.navigation.menu"))
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
        .onChange(of: viewModel.captureFeedback) { newValue in
            presentedFeedback = newValue
        }
        .alert(item: Binding(
            get: { presentedFeedback },
            set: { presentedFeedback = $0 }
        )) { feedback in
            switch feedback.kind {
            case let .success(message):
                return Alert(
                    title: Text(String(localized: "browser.capture.success.title")),
                    message: Text(message),
                    dismissButton: .default(Text(String(localized: "common.ok"))) {
                        presentedFeedback = nil
                    }
                )
            case let .failure(message):
                return Alert(
                    title: Text(String(localized: "browser.capture.error.title")),
                    message: Text(message),
                    dismissButton: .default(Text(String(localized: "common.ok"))) {
                        presentedFeedback = nil
                    }
                )
            }
        }
    }

    private var searchField: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "browser.search.title"))
                .font(.title3.bold())

            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField(String(localized: "browser.search.placeholder"), text: $viewModel.query)
                    .textFieldStyle(.plain)
                    .textInputAutocapitalization(.none)
                    .autocorrectionDisabled(true)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
            )

            Button(action: {
                Task {
                    await viewModel.captureCurrentQuery()
                }
            }) {
                Label(String(localized: "browser.search.action"), systemImage: "safari")
                    .labelStyle(.titleAndIcon)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .tint(Color.accentColor.opacity(0.85))
            .accessibilityIdentifier("browser-search-go-button")
            .disabled(viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isCapturing)
        }
    }

    private let gridColumns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
}

#Preview {
    BrowserView(
        viewModel: BrowserViewModel(
            offlineReaderService: StubOfflineReaderService(),
            browsingExperienceService: InMemoryBrowsingExperienceService()
        )
    )
}


