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
    let purchaseService: PurchaseService
    let cloudSyncService: CloudSyncService

    init(
        networkClient: NetworkClient = URLSessionNetworkClient(),
        storageProvider: StorageProvider? = nil,
        offlineReaderService: OfflineReaderService? = nil,
        downloadService: DownloadService? = nil,
        browsingExperienceService: BrowsingExperienceService? = nil,
        purchaseService: PurchaseService? = nil,
        cloudSyncService: CloudSyncService? = nil
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
        
        // Use MockPurchaseService for development, StoreKit2PurchaseService for production
        #if DEBUG
        self.purchaseService = purchaseService ?? MockPurchaseService()
        #else
        self.purchaseService = purchaseService ?? StoreKit2PurchaseService()
        #endif

        // CloudKit sync service - use mock in DEBUG, real service in production
        #if DEBUG
        self.cloudSyncService = cloudSyncService ?? MockCloudSyncService()
        #else
        self.cloudSyncService = cloudSyncService ?? CloudKitSyncService()
        #endif
        
        let baseOfflineReaderService = offlineReaderService
            ?? DefaultOfflineReaderService(networkClient: networkClient, storageProvider: activeStorageProvider)
        
        // Wrap with premium checks
        let premiumWrappedService = PremiumOfflineReaderService(
            wrapping: baseOfflineReaderService,
            purchaseService: self.purchaseService
        )
        
        // Wrap with CloudKit sync for premium users
        self.offlineReaderService = CloudSyncOfflineReaderService(
            wrapping: premiumWrappedService,
            purchaseService: self.purchaseService,
            cloudSyncService: self.cloudSyncService
        )

        self.downloadService = downloadService
            ?? DefaultDownloadService(
                offlineReaderService: self.offlineReaderService
            )

        self.browsingExperienceService = browsingExperienceService
            ?? InMemoryBrowsingExperienceService()
    }
}

