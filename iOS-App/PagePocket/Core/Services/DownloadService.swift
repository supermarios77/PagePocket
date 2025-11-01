import Foundation

protocol DownloadService {
    func fetchActiveDownloads() async -> [DownloadRecord]
    func fetchCompletedDownloads() async -> [DownloadRecord]
    func cancelDownload(id: UUID) async
}

actor InMemoryDownloadService: DownloadService {
    private var activeDownloads: [UUID: DownloadRecord]
    private var completedDownloads: [UUID: DownloadRecord]

    init(
        active: [DownloadRecord] = [],
        completed: [DownloadRecord] = []
    ) {
        self.activeDownloads = Dictionary(uniqueKeysWithValues: active.map { ($0.id, $0) })
        self.completedDownloads = Dictionary(uniqueKeysWithValues: completed.map { ($0.id, $0) })
    }

    func fetchActiveDownloads() async -> [DownloadRecord] {
        activeDownloads.values.sorted(by: { $0.createdAt < $1.createdAt })
    }

    func fetchCompletedDownloads() async -> [DownloadRecord] {
        completedDownloads.values.sorted(by: { $0.createdAt > $1.createdAt })
    }

    func cancelDownload(id: UUID) async {
        activeDownloads.removeValue(forKey: id)
    }
}

