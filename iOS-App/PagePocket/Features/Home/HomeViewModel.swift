import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    struct QuickAction: Identifiable, Equatable {
        let id = UUID()
        let title: String
        let subtitle: String
        let systemImageName: String
        let action: ActionType
        
        enum ActionType {
            case navigateToBrowser
            case navigateToCollections
            case navigateToSync
        }

        static let defaults: [QuickAction] = [
            QuickAction(
                title: String(localized: "home.quickActions.capture.title"),
                subtitle: String(localized: "home.quickActions.capture.subtitle"),
                systemImageName: "tray.and.arrow.down",
                action: .navigateToBrowser
            ),
            QuickAction(
                title: String(localized: "home.quickActions.collections.title"),
                subtitle: String(localized: "home.quickActions.collections.subtitle"),
                systemImageName: "rectangle.3.group.bubble.left",
                action: .navigateToCollections
            ),
            QuickAction(
                title: String(localized: "home.quickActions.sync.title"),
                subtitle: String(localized: "home.quickActions.sync.subtitle"),
                systemImageName: "icloud.and.arrow.down",
                action: .navigateToSync
            )
        ]
    }

    struct ReadingListItem: Identifiable, Equatable {
        let id: UUID
        let title: String
        let subtitle: String
        let status: String
        let systemImageName: String
        let estimatedReadMinutes: Int

        init(page: SavedPage) {
            self.id = page.id
            self.title = page.title
            let minutes = max(Int(round(page.estimatedReadTime / 60)), 1)
            self.estimatedReadMinutes = minutes
            let readTime = HomeViewModel.readTimeDescription(for: minutes)
            self.subtitle = "\(page.source) • \(readTime)"
            self.status = page.status.localizedDescription
            self.systemImageName = page.contentType.systemImageName
        }
    }

    struct OfflineTip: Identifiable, Equatable {
        let id = UUID()
        let title: String
        let subtitle: String
        let systemImageName: String

        static let defaults: [OfflineTip] = [
            OfflineTip(
                title: String(localized: "home.offlineTips.item1.title"),
                subtitle: String(localized: "home.offlineTips.item1.subtitle"),
                systemImageName: "wifi.slash"
            ),
            OfflineTip(
                title: String(localized: "home.offlineTips.item2.title"),
                subtitle: String(localized: "home.offlineTips.item2.subtitle"),
                systemImageName: "square.and.arrow.down.on.square"
            ),
            OfflineTip(
                title: String(localized: "home.offlineTips.item3.title"),
                subtitle: String(localized: "home.offlineTips.item3.subtitle"),
                systemImageName: "bell.badge"
            )
        ]
    }

    @Published private(set) var quickActions: [QuickAction]
    @Published private(set) var readingList: [ReadingListItem] = []
    @Published private(set) var offlineTips: [OfflineTip]
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let offlineReaderService: OfflineReaderService
    private var hasLoadedContent = false
    private var cancellables: Set<AnyCancellable> = []

    init(offlineReaderService: OfflineReaderService) {
        self.offlineReaderService = offlineReaderService
        self.quickActions = QuickAction.defaults
        self.offlineTips = OfflineTip.defaults

        let notificationNames: [Notification.Name] = [
            .offlineReaderPageSaved,
            .offlineReaderPageDeleted,
            .offlineReaderPageUpdated
        ]

        for name in notificationNames {
            NotificationCenter.default.publisher(for: name)
                .sink { [weak self] _ in
                    guard let self else { return }
                    Task { await self.refreshReadingList() }
                }
                .store(in: &cancellables)
        }
    }

    func loadContentIfNeeded() async {
        guard !hasLoadedContent else { return }
        hasLoadedContent = true
        await refreshReadingList()
    }

    func refreshReadingList() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let pages = try await offlineReaderService.listSavedPages()
            readingList = pages.map(ReadingListItem.init)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createSamplePage() async {
        guard let url = URL(string: "https://developer.apple.com/tutorials/offline") else { return }
        do {
            _ = try await offlineReaderService.savePage(from: url)
            errorMessage = nil
            await refreshReadingList()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markFirstItemInProgress() async {
        guard let first = readingList.first else { return }
        await updateStatus(for: first.id, status: .inProgress)
    }

    func makeReaderViewModel(for pageID: UUID) -> OfflineReaderViewModel {
        OfflineReaderViewModel(pageID: pageID, offlineReaderService: offlineReaderService)
    }

    func deletePage(_ pageID: UUID) async {
        do {
            try await offlineReaderService.deletePage(pageID)
            await refreshReadingList()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func updateStatus(for pageID: UUID, status: SavedPage.Status) async {
        do {
            try await offlineReaderService.updateStatus(for: pageID, status: status)
            await refreshReadingList()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private static func readTimeDescription(for minutes: Int) -> String {
        if minutes == 1 {
            return String(localized: "home.readingList.readTime.one")
        }
        return String.localizedStringWithFormat(
            String(localized: "home.readingList.readTime.many"),
            minutes
        )
    }
}

