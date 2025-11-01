import Foundation

struct DownloadRecord: Identifiable, Hashable {
    enum Status: Hashable {
        case pending
        case inProgress(progress: Double)
        case available
        case archived
        case failed(reason: String)

        var localizedDescription: String {
            switch self {
            case .pending:
                String(localized: "downloads.active.item.status.pending")
            case .inProgress:
                String(localized: "downloads.active.item.status.inProgress")
            case .available:
                String(localized: "downloads.completed.item.status.available")
            case .archived:
                String(localized: "downloads.completed.item.status.archived")
            case .failed:
                String(localized: "downloads.completed.item.status.failed", defaultValue: "Failed")
            }
        }

        var systemImageName: String {
            switch self {
            case .pending, .inProgress:
                "arrow.down.circle"
            case .available:
                "checkmark.circle"
            case .archived:
                "archivebox"
            case .failed:
                "exclamationmark.triangle"
            }
        }
    }

    let id: UUID
    let title: String
    let detail: String
    let createdAt: Date
    let status: Status

    var progressValue: Double? {
        if case let .inProgress(progress) = status {
            return progress
        }
        return nil
    }

    init(
        id: UUID = UUID(),
        title: String,
        detail: String,
        createdAt: Date = Date(),
        status: Status
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.createdAt = createdAt
        self.status = status
    }
}

