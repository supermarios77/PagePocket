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
            ?? DefaultDownloadService(
                offlineReaderService: self.offlineReaderService
            )

        self.browsingExperienceService = browsingExperienceService
            ?? InMemoryBrowsingExperienceService()
    }
}

