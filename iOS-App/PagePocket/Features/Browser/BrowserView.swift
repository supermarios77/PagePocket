//
//  BrowserView.swift
//  PagePocket


import SwiftUI

struct BrowserView: View {
    @StateObject private var viewModel: BrowserViewModel
    @State private var presentedFeedback: BrowserViewModel.CaptureFeedback?
    let makePaywallViewModel: () -> PaywallViewModel

    init(viewModel: BrowserViewModel, makePaywallViewModel: @escaping () -> PaywallViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.makePaywallViewModel = makePaywallViewModel
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
                        if viewModel.recentSessions.isEmpty {
                            Text(String(localized: "browser.recentSessions.empty"))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color(.secondarySystemBackground))
                                )
                        } else {
                            ForEach(viewModel.recentSessions) { session in
                                NavigationLink {
                                    OfflineReaderView(viewModel: viewModel.makeReaderViewModel(for: session.id))
                                } label: {
                                    PlaceholderListRow(
                                        title: session.title,
                                        subtitle: session.subtitle,
                                        status: session.status,
                                        systemImageName: session.systemImageName
                                    )
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(Color(.secondarySystemBackground))
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
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
        .sheet(isPresented: $viewModel.showPaywall) {
            PaywallView(viewModel: makePaywallViewModel())
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

}

#Preview {
    let previewOfflineService = StubOfflineReaderService()
    let previewDownloadService = PreviewDownloadService()
    BrowserView(
        viewModel: BrowserViewModel(
            offlineReaderService: previewOfflineService,
            downloadService: previewDownloadService
        ),
        makePaywallViewModel: { PaywallViewModel(purchaseService: MockPurchaseService()) }
    )
}

@MainActor
private final class PreviewDownloadService: DownloadService {
    func fetchActiveDownloads() async -> [DownloadRecord] { [] }
    func fetchCompletedDownloads() async -> [DownloadRecord] { [] }
    func cancelDownload(id: UUID) async {}
    func updates() -> AsyncStream<Void> { AsyncStream { $0.finish() } }
    func enqueueCapture(from url: URL) async throws -> SavedPage {
        SavedPage(title: url.absoluteString, url: url)
    }
}


