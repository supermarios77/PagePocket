import Foundation

protocol DownloadService {
    func fetchActiveDownloads() async -> [DownloadRecord]
    func fetchCompletedDownloads() async -> [DownloadRecord]
    func cancelDownload(id: UUID) async
    func updates() -> AsyncStream<Void>
    @discardableResult
    func enqueueCapture(from url: URL) async throws -> SavedPage
}

actor DefaultDownloadService: DownloadService {
    private let offlineReaderService: OfflineReaderService
    private var activeDownloads: [UUID: DownloadRecord]
    private var completedDownloads: [UUID: DownloadRecord]
    private var tasks: [UUID: Task<SavedPage, Error>]
    private var observers: [UUID: AsyncStream<Void>.Continuation]
    
    // Limit concurrent downloads to prevent resource exhaustion
    private static let maxConcurrentDownloads = AppConstants.Downloads.maxConcurrentDownloads

    init(
        offlineReaderService: OfflineReaderService,
        active: [DownloadRecord] = [],
        completed: [DownloadRecord] = []
    ) {
        self.offlineReaderService = offlineReaderService
        self.activeDownloads = Dictionary(uniqueKeysWithValues: active.map { ($0.id, $0) })
        self.completedDownloads = Dictionary(uniqueKeysWithValues: completed.map { ($0.id, $0) })
        self.tasks = [:]
        self.observers = [:]
    }

    func fetchActiveDownloads() async -> [DownloadRecord] {
        activeDownloads.values.sorted(by: { $0.createdAt < $1.createdAt })
    }

    func fetchCompletedDownloads() async -> [DownloadRecord] {
        completedDownloads.values.sorted(by: { $0.createdAt > $1.createdAt })
    }

    func updates() -> AsyncStream<Void> {
        AsyncStream { continuation in
            let token = UUID()
            Task { await self.addObserver(token: token, continuation: continuation) }
            continuation.onTermination = { _ in
                Task { await self.removeObserver(token: token) }
            }
        }
    }

    @discardableResult
    func enqueueCapture(from url: URL) async throws -> SavedPage {
        // Wait if we're at the concurrent download limit
        while tasks.count >= Self.maxConcurrentDownloads {
            // Wait a bit before checking again
            try? await Task.sleep(for: .milliseconds(100))
        }
        
        let downloadID = UUID()
        let createdAt = Date()
        let title = url.host?.replacingOccurrences(of: "www.", with: "").capitalized ?? url.absoluteString
        let pendingRecord = DownloadRecord(
            id: downloadID,
            title: title,
            detail: url.absoluteString,
            createdAt: createdAt,
            status: .pending
        )
        activeDownloads[downloadID] = pendingRecord
        notifyObservers()

        let task = Task { () -> SavedPage in
            await self.updateRecord(id: downloadID, status: .inProgress(progress: 0.1))
            do {
                let savedPage = try await self.offlineReaderService.savePage(from: url)
                await self.updateRecord(id: downloadID, status: .inProgress(progress: 0.95))
                await self.markDownloadComplete(id: downloadID, page: savedPage)
                return savedPage
            } catch {
                await self.markDownloadFailed(id: downloadID, error: error)
                throw error
            }
        }

        tasks[downloadID] = task

        do {
            let page = try await task.value
            tasks.removeValue(forKey: downloadID)
            return page
        } catch {
            tasks.removeValue(forKey: downloadID)
            throw error
        }
    }

    func cancelDownload(id: UUID) async {
        tasks[id]?.cancel()
        tasks.removeValue(forKey: id)
        let cancellationError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        markDownloadFailed(id: id, error: cancellationError)
    }

    private func updateRecord(id: UUID, status: DownloadRecord.Status) {
        guard var record = activeDownloads[id] else { return }
        activeDownloads[id] = DownloadRecord(
            id: record.id,
            title: record.title,
            detail: record.detail,
            createdAt: record.createdAt,
            status: status,
            savedPageID: record.savedPageID
        )
        notifyObservers()
    }

    private func markDownloadComplete(id: UUID, page: SavedPage) {
        activeDownloads.removeValue(forKey: id)
        completedDownloads[id] = DownloadRecord(
            id: id,
            title: page.title,
            detail: page.source,
            createdAt: Date(),
            status: .available,
            savedPageID: page.id
        )
        notifyObservers()
    }

    private func markDownloadFailed(id: UUID, error: Error) {
        let message: String
        if (error as NSError).code == NSUserCancelledError {
            message = String(localized: "downloads.actions.cancelled")
        } else {
            message = error.localizedDescription
        }
        let record = activeDownloads.removeValue(forKey: id) ?? DownloadRecord(
            id: id,
            title: "",
            detail: "",
            createdAt: Date(),
            status: .failed(reason: message)
        )
        completedDownloads[id] = DownloadRecord(
            id: record.id,
            title: record.title,
            detail: record.detail.isEmpty ? message : record.detail,
            createdAt: record.createdAt,
            status: .failed(reason: message)
        )
        notifyObservers()
    }

    private func notifyObservers() {
        observers.values.forEach { $0.yield(()) }
    }

    private func addObserver(token: UUID, continuation: AsyncStream<Void>.Continuation) {
        observers[token] = continuation
        continuation.yield(())
    }

    private func removeObserver(token: UUID) {
        observers.removeValue(forKey: token)
    }
}

