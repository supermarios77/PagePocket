//
//  BrowserViewModel.swift
//  PagePocket


import Combine
import Foundation

@MainActor
final class BrowserViewModel: ObservableObject {
    struct RecentSessionViewData: Identifiable, Equatable {
        let id: UUID
        let title: String
        let subtitle: String
        let status: String
        let systemImageName: String

        init(session: BrowsingSession) {
            id = session.id
            title = session.title
            subtitle = session.url.host ?? session.url.absoluteString
            status = session.syncState.localizedDescription
            systemImageName = RecentSessionViewData.icon(for: session)
        }

        private static func icon(for session: BrowsingSession) -> String {
            let host = session.url.host ?? ""
            if host.contains("design") || host.contains("dribbble") {
                return "newspaper"
            }
            return "doc.text.magnifyingglass"
        }
    }

    struct SuggestedActionViewData: Identifiable, Equatable {
        let id: UUID
        let title: String
        let subtitle: String
        let systemImageName: String

        init(action: SuggestedBrowserAction) {
            id = action.id
            title = action.title
            subtitle = action.detail
            systemImageName = action.systemImageName
        }
    }

    struct OfflinePreviewCard: Equatable {
        let title: String
        let description: String
        let systemImageName: String
    }

    struct CaptureFeedback: Identifiable, Equatable {
        enum Kind: Equatable {
            case success(message: String)
            case failure(message: String)
        }

        let id = UUID()
        let kind: Kind
    }

    @Published var query: String = ""
    @Published private(set) var recentSessions: [RecentSessionViewData] = []
    @Published private(set) var suggestedActions: [SuggestedActionViewData] = []
    @Published private(set) var offlinePreview: OfflinePreviewCard = .init(
        title: String(localized: "browser.offlinePreview.card.title"),
        description: String(localized: "browser.offlinePreview.card.subtitle"),
        systemImageName: "arrow.down.doc"
    )
    @Published private(set) var isLoading = false
    @Published private(set) var isCapturing = false
    @Published var captureFeedback: CaptureFeedback?

    private let offlineReaderService: OfflineReaderService
    private let browsingExperienceService: BrowsingExperienceService
    private var hasLoaded = false

    init(
        offlineReaderService: OfflineReaderService,
        browsingExperienceService: BrowsingExperienceService
    ) {
        self.offlineReaderService = offlineReaderService
        self.browsingExperienceService = browsingExperienceService
    }

    func loadContentIfNeeded() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        await loadContent()
    }

    func loadContent() async {
        isLoading = true
        defer { isLoading = false }

        async let sessions = browsingExperienceService.loadRecentSessions()
        async let actions = browsingExperienceService.loadSuggestedActions()

        let results = await (sessions, actions)
        recentSessions = results.0.map(RecentSessionViewData.init)
        suggestedActions = results.1.map(SuggestedActionViewData.init)
    }

    func captureCurrentQuery() async {
        guard !isCapturing else { return }
        guard let url = normalizeURL(from: query) else {
            captureFeedback = CaptureFeedback(
                kind: .failure(message: String(localized: "browser.capture.error.invalidURL"))
            )
            return
        }

        isCapturing = true
        defer { isCapturing = false }

        do {
            let page = try await offlineReaderService.savePage(from: url)
            captureFeedback = CaptureFeedback(
                kind: .success(
                    message: String(
                        localized: "browser.capture.success",
                        comment: "Success message after capturing a page",
                        arguments: page.title
                    )
                )
            )
            query = ""
        } catch {
            captureFeedback = CaptureFeedback(
                kind: .failure(message: String(localized: "browser.capture.error.generic"))
            )
        }
    }

    private func normalizeURL(from text: String) -> URL? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if let url = URL(string: trimmed), url.scheme != nil {
            return url
        }

        let prefixed = "https://" + trimmed
        return URL(string: prefixed)
    }
}

