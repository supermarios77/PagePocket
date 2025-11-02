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

        init(page: SavedPage) {
            id = page.id
            title = page.title
            subtitle = page.source
            status = page.status.localizedDescription
            systemImageName = RecentSessionViewData.icon(for: page)
        }

        private static func icon(for page: SavedPage) -> String {
            switch page.contentType {
            case .article:
                return "doc.text.magnifyingglass"
            case .collection:
                return "rectangle.3.group.bubble.left"
            case .document:
                return "doc.richtext"
            }
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
    private let downloadService: DownloadService
    private var hasLoaded = false
    private var notificationTasks: [Task<Void, Never>] = []

    init(
        offlineReaderService: OfflineReaderService,
        browsingExperienceService: BrowsingExperienceService,
        downloadService: DownloadService
    ) {
        self.offlineReaderService = offlineReaderService
        self.browsingExperienceService = browsingExperienceService
        self.downloadService = downloadService

        let notificationNames: [Notification.Name] = [
            .offlineReaderPageSaved,
            .offlineReaderPageDeleted,
            .offlineReaderPageUpdated
        ]

        notificationTasks = notificationNames.map { name in
            Task { [weak self] in
                guard let self else { return }
                for await _ in NotificationCenter.default.notifications(named: name) {
                    await self.loadContent()
                }
            }
        }
    }

    func loadContentIfNeeded() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        await loadContent()
    }

    func loadContent() async {
        isLoading = true
        defer { isLoading = false }

        async let pagesTask = offlineReaderService.listSavedPages()
        async let actionsTask = browsingExperienceService.loadSuggestedActions()

        do {
            let savedPages = try await pagesTask
            let suggested = await actionsTask
            recentSessions = savedPages.prefix(5).map(RecentSessionViewData.init)
            suggestedActions = suggested.map(SuggestedActionViewData.init)
        } catch {
            let suggested = await actionsTask
            suggestedActions = suggested.map(SuggestedActionViewData.init)
            captureFeedback = CaptureFeedback(kind: .failure(message: error.localizedDescription))
        }
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
            let page = try await downloadService.enqueueCapture(from: url)
            captureFeedback = CaptureFeedback(
                kind: .success(
                    message: String.localizedStringWithFormat(
                        String(
                            localized: "browser.capture.success",
                            comment: "Success message after capturing a page"
                        ),
                        page.title
                    )
                )
            )
            query = ""
        } catch {
            if (error as NSError).code == NSUserCancelledError {
                captureFeedback = CaptureFeedback(
                    kind: .failure(message: String(localized: "downloads.actions.cancelled"))
                )
            } else {
                captureFeedback = CaptureFeedback(
                    kind: .failure(message: String(localized: "browser.capture.error.generic"))
                )
            }
        }
    }

    func makeReaderViewModel(for pageID: UUID) -> OfflineReaderViewModel {
        OfflineReaderViewModel(pageID: pageID, offlineReaderService: offlineReaderService)
    }

    private func normalizeURL(from text: String) -> URL? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        // Validate and normalize URL
        if let url = URL(string: trimmed), url.scheme != nil {
            // Additional validation: only allow http/https schemes
            guard ["http", "https"].contains(url.scheme?.lowercased()) else {
                return nil
            }
            return url
        }

        let prefixed = "https://" + trimmed
        if let url = URL(string: prefixed) {
            return url
        }
        
        return nil
    }

    deinit {
        notificationTasks.forEach { $0.cancel() }
    }
}

