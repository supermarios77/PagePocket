import Foundation

struct BrowsingSession: Identifiable, Hashable {
    enum SyncState: Hashable {
        case synced
        case updated

        var localizedDescription: String {
            switch self {
            case .synced:
                String(localized: "browser.recentSessions.item.status.synced")
            case .updated:
                String(localized: "browser.recentSessions.item.status.updated")
            }
        }
    }

    let id: UUID
    let title: String
    let url: URL
    let lastViewedAt: Date
    let syncState: SyncState

    init(
        id: UUID = UUID(),
        title: String,
        url: URL,
        lastViewedAt: Date,
        syncState: SyncState
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.lastViewedAt = lastViewedAt
        self.syncState = syncState
    }
}

