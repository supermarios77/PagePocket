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

        init(record: DownloadRecord) {
            id = record.id
            title = record.title
            subtitle = record.detail
            status = record.status.localizedDescription
            systemImageName = record.status.systemImageName
            progress = record.progressValue
        }
    }

    @Published private(set) var activeDownloads: [DownloadRow] = []
    @Published private(set) var completedDownloads: [DownloadRow] = []
    @Published private(set) var isLoading = false

    private let downloadService: DownloadService
    private var hasLoaded = false

    init(downloadService: DownloadService) {
        self.downloadService = downloadService
    }

    func loadContentIfNeeded() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        await refresh()
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }

        async let active = downloadService.fetchActiveDownloads()
        async let completed = downloadService.fetchCompletedDownloads()

        let results = await (active, completed)
        activeDownloads = results.0.map(DownloadRow.init)
        completedDownloads = results.1.map(DownloadRow.init)
    }

    func cancelDownload(id: UUID) async {
        await downloadService.cancelDownload(id: id)
        await refresh()
    }
}

