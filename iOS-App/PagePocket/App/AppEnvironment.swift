import Combine
import Foundation
import SwiftData

@MainActor
final class AppEnvironment: ObservableObject {
    let modelContainer: ModelContainer
    let modelContext: ModelContext
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

        let container: ModelContainer
        do {
            container = try ModelContainer(for: SavedPageEntity.self)
        } catch {
            fatalError("Failed to initialize SwiftData container: \(error.localizedDescription)")
        }
        self.modelContainer = container
        self.modelContext = ModelContext(container)

        let activeStorageProvider = storageProvider ?? SwiftDataStorageProvider(context: modelContext)
        self.storageProvider = activeStorageProvider

        self.offlineReaderService = offlineReaderService
            ?? DefaultOfflineReaderService(networkClient: networkClient, storageProvider: activeStorageProvider)

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

        Task { @MainActor [weak self] in
            guard let self else { return }
            await self.seedInitialContentIfNeeded()
        }
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
            contentType: .article,
            htmlContent: SeedHTML.swiftUIPractices,
            estimatedReadTime: SavedPage.estimateReadTime(for: SeedHTML.swiftUIPractices)
        ),
        SavedPage(
            title: "Designing Seamless Reader Experiences",
            url: makeURL("https://medium.com/design/seamless-reader"),
            source: "medium.com",
            createdAt: Date().addingTimeInterval(-21_600),
            status: .inProgress,
            contentType: .article,
            htmlContent: SeedHTML.readerExperiences,
            estimatedReadTime: SavedPage.estimateReadTime(for: SeedHTML.readerExperiences)
        ),
        SavedPage(
            title: "Caching Strategies for iOS",
            url: makeURL("https://www.kodeco.com/collections/cache-strategies"),
            source: "kodeco.com",
            createdAt: Date().addingTimeInterval(-48_600),
            status: .completed,
            contentType: .document,
            htmlContent: SeedHTML.cachingStrategies,
            estimatedReadTime: SavedPage.estimateReadTime(for: SeedHTML.cachingStrategies)
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
    func seedInitialContentIfNeeded() async {
        guard (try? await storageProvider.loadPages().isEmpty) == true else { return }
        for page in AppEnvironment.seedPages {
            try? await storageProvider.store(page: page)
        }
    }
}

private enum SeedHTML {
    static let swiftUIPractices = """
    <html><body><h1>SwiftUI Offline Best Practices</h1><p>Learn how to structure offline-first experiences using SwiftUI's modern data APIs...</p></body></html>
    """

    static let readerExperiences = """
    <html><body><h1>Designing Seamless Reader Experiences</h1><p>Delight your readers with typography, layout, and offline-ready design systems.</p></body></html>
    """

    static let cachingStrategies = """
    <html><body><h1>Caching Strategies for iOS</h1><p>Balance freshness and performance with layered caching, background refresh, and heuristics.</p></body></html>
    """
}

