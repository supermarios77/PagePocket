//
//  DownloadsViewModel.swift
//  PagePocket


import Combine
import Foundation

@MainActor
final class DownloadsViewModel: ObservableObject {
    struct DownloadRow: Identifiable, Equatable {
        let id: UUID
        let title: String
        let subtitle: String
        let status: String
        let systemImageName: String
        let progress: Double?
        let failureReason: String?
        let savedPageID: UUID?

        init(record: DownloadRecord) {
            id = record.id
            title = record.title
            subtitle = record.detail
            status = record.status.localizedDescription
            systemImageName = record.status.systemImageName
            progress = record.progressValue
            savedPageID = record.savedPageID
            if case let .failed(reason) = record.status {
                failureReason = reason
            } else {
                failureReason = nil
            }
        }
    }

    @Published private(set) var activeDownloads: [DownloadRow] = []
    @Published private(set) var completedDownloads: [DownloadRow] = []
    @Published private(set) var isLoading = false

    private let downloadService: DownloadService
    private let offlineReaderService: OfflineReaderService
    private var hasLoaded = false
    private var updatesTask: Task<Void, Never>?

    init(downloadService: DownloadService, offlineReaderService: OfflineReaderService) {
        self.downloadService = downloadService
        self.offlineReaderService = offlineReaderService
        updatesTask = Task { [weak self] in
            guard let self else { return }
            for await _ in downloadService.updates() {
                await self.loadSnapshots()
            }
        }
    }

    func loadContentIfNeeded() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        await refresh()
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        await loadSnapshots()
    }

    func cancelDownload(id: UUID) async {
        await downloadService.cancelDownload(id: id)
    }

    func makeReaderViewModel(for pageID: UUID) -> OfflineReaderViewModel {
        OfflineReaderViewModel(pageID: pageID, offlineReaderService: offlineReaderService)
    }

    private func loadSnapshots() async {
        async let active = downloadService.fetchActiveDownloads()
        async let completed = downloadService.fetchCompletedDownloads()

        let results = await (active, completed)
        activeDownloads = results.0.map(DownloadRow.init)
        completedDownloads = results.1.map(DownloadRow.init)
    }

    deinit {
        updatesTask?.cancel()
    }
}

