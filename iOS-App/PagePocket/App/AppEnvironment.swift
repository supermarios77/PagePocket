import Combine
import Foundation

@MainActor
final class AppEnvironment: ObservableObject {
    let networkClient: NetworkClient
    let storageProvider: StorageProvider
    let offlineReaderService: OfflineReaderService
    let downloadService: DownloadService
    let browsingExperienceService: BrowsingExperienceService

    init(
        networkClient: NetworkClient = URLSessionNetworkClient(),
        storageProvider: StorageProvider? = nil,
        offlineReaderService: OfflineReaderService? = nil,
        downloadService: DownloadService? = nil,
        browsingExperienceService: BrowsingExperienceService? = nil
    ) {
        self.networkClient = networkClient

        let seededStorage = storageProvider ?? InMemoryStorageProvider(seedPages: AppEnvironment.seedPages)
        self.storageProvider = seededStorage

        self.offlineReaderService = offlineReaderService
            ?? DefaultOfflineReaderService(networkClient: networkClient, storageProvider: seededStorage)

        self.downloadService = downloadService
            ?? InMemoryDownloadService(
                active: AppEnvironment.seedActiveDownloads,
                completed: AppEnvironment.seedCompletedDownloads
            )

        self.browsingExperienceService = browsingExperienceService
            ?? InMemoryBrowsingExperienceService(
                sessions: AppEnvironment.seedBrowsingSessions,
                actions: AppEnvironment.seedSuggestedActions
            )
    }
}

private extension AppEnvironment {
    static let seedPages: [SavedPage] = [
        SavedPage(
            title: "SwiftUI Offline Best Practices",
            url: makeURL("https://developer.apple.com/documentation/swiftui"),
            source: "developer.apple.com",
            createdAt: Date().addingTimeInterval(-3_600),
            status: .new,
            contentType: .article
        ),
        SavedPage(
            title: "Designing Seamless Reader Experiences",
            url: makeURL("https://medium.com/design/seamless-reader"),
            source: "medium.com",
            createdAt: Date().addingTimeInterval(-21_600),
            status: .inProgress,
            contentType: .article
        ),
        SavedPage(
            title: "Caching Strategies for iOS",
            url: makeURL("https://www.kodeco.com/collections/cache-strategies"),
            source: "kodeco.com",
            createdAt: Date().addingTimeInterval(-48_600),
            status: .completed,
            contentType: .document
        )
    ]

    static let seedActiveDownloads: [DownloadRecord] = [
        DownloadRecord(
            title: "Offline-first API Guidelines",
            detail: "Reading list • 12 MB",
            createdAt: Date().addingTimeInterval(-1_800),
            status: .pending
        ),
        DownloadRecord(
            title: "Curated UI Inspirations",
            detail: "Collection • 37 MB",
            createdAt: Date().addingTimeInterval(-600),
            status: .inProgress(progress: 0.42)
        )
    ]

    static let seedCompletedDownloads: [DownloadRecord] = [
        DownloadRecord(
            title: "SwiftData Essentials",
            detail: "Guide • 9 MB",
            createdAt: Date().addingTimeInterval(-86_400),
            status: .available
        ),
        DownloadRecord(
            title: "Accessibility Checklist",
            detail: "Document • 5 MB",
            createdAt: Date().addingTimeInterval(-172_800),
            status: .archived
        )
    ]

    static let seedBrowsingSessions: [BrowsingSession] = [
        BrowsingSession(
            title: "Offline architecture patterns",
            url: makeURL("https://appleinsider.com/offline-architecture"),
            lastViewedAt: Date().addingTimeInterval(-3_000),
            syncState: .synced
        ),
        BrowsingSession(
            title: "Minimal browser UI inspirations",
            url: makeURL("https://dribbble.com/shots/offline-browser"),
            lastViewedAt: Date().addingTimeInterval(-7_200),
            syncState: .updated
        )
    ]

    static let seedSuggestedActions: [SuggestedBrowserAction] = [
        SuggestedBrowserAction(
            title: "Bookmark for later",
            detail: "Add to a curated list",
            systemImageName: "bookmark.circle"
        ),
        SuggestedBrowserAction(
            title: "Resume last tab",
            detail: "Reopen your previous session",
            systemImageName: "clock.arrow.circlepath"
        ),
        SuggestedBrowserAction(
            title: "Explore offline catalog",
            detail: "See community favorites",
            systemImageName: "globe.europe.africa"
        ),
        SuggestedBrowserAction(
            title: "Archive for travel",
            detail: "Keep content lightweight",
            systemImageName: "arrow.down.doc"
        )
    ]

    static func makeURL(_ value: String) -> URL {
        guard let url = URL(string: value) else {
            preconditionFailure("Invalid seed URL: \(value)")
        }
        return url
    }
}

