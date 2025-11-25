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
    @Published private(set) var isLoading = false
    @Published private(set) var isCapturing = false
    @Published var captureFeedback: CaptureFeedback?
    @Published var showPaywall = false

    private let offlineReaderService: OfflineReaderService
    private let downloadService: DownloadService
    private var hasLoaded = false
    private var notificationTasks: [Task<Void, Never>] = []

    init(
        offlineReaderService: OfflineReaderService,
        downloadService: DownloadService
    ) {
        self.offlineReaderService = offlineReaderService
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

        do {
            let savedPages = try await offlineReaderService.listSavedPages()
            recentSessions = savedPages.prefix(5).map(RecentSessionViewData.init)
        } catch {
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
            if let readerError = error as? OfflineReaderError,
               case .freeLimitReached = readerError {
                showPaywall = true
            } else if (error as NSError).code == NSUserCancelledError {
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
        
        // Validate URL length to prevent abuse
        guard trimmed.count <= AppConstants.Network.maxURLLength else { return nil }

        // Validate and normalize URL
        if let url = URL(string: trimmed), url.scheme != nil {
            // Additional validation: only allow http/https schemes
            guard let scheme = url.scheme?.lowercased(),
                  ["http", "https"].contains(scheme) else {
                return nil
            }
            // Validate host exists for proper URLs
            guard url.host != nil || url.scheme == "file" else {
                return nil
            }
            return url
        }

        // Try adding https:// prefix for URLs without scheme
        let prefixed = "https://" + trimmed
        if let url = URL(string: prefixed),
           let scheme = url.scheme?.lowercased(),
           ["http", "https"].contains(scheme),
           url.host != nil {
            return url
        }
        
        return nil
    }

    deinit {
        notificationTasks.forEach { $0.cancel() }
    }
}

