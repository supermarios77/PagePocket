import Combine
import Foundation
import OSLog
import SwiftData

@MainActor
final class AppEnvironment: ObservableObject {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "PagePocket", category: "AppEnvironment")
    
    enum ThemePreference: String, CaseIterable {
        case system
        case light
        case dark
    }

    @Published var theme: ThemePreference {
        didSet {
            UserDefaults.standard.set(theme.rawValue, forKey: "appTheme")
        }
    }

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
        // Load saved theme preference
        let savedTheme = UserDefaults.standard.string(forKey: "appTheme") ?? "system"
        self.theme = ThemePreference(rawValue: savedTheme) ?? .system

        self.networkClient = networkClient

        // Try to create SwiftData container, but create in-memory fallback if it fails
        let container: ModelContainer
        do {
            container = try ModelContainer(for: SavedPageEntity.self)
        } catch {
            // Log error in production, but provide fallback for development
            Self.logger.error("SwiftData initialization failed: \(error.localizedDescription)")
            // In production, you might want to show an error UI or use UserDefaults fallback
            container = try! ModelContainer(for: SavedPageEntity.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
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

