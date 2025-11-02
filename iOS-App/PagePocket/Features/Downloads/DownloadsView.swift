import SwiftUI

struct DownloadsView: View {
    @StateObject private var viewModel: DownloadsViewModel
    init(viewModel: DownloadsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            List {
                Section(
                    header: SectionHeader(
                        title: String(localized: "downloads.active.title"),
                        subtitle: String(localized: "downloads.active.subtitle")
                    )
                ) {
                    ForEach(viewModel.activeDownloads) { item in
                        DownloadRowView(row: item)
                            .accessibilityIdentifier("downloads-active-row-\(item.id.uuidString)")
                        .swipeActions(edge: .trailing) {
                            Button(String(localized: "downloads.actions.cancel"), role: .destructive) {
                                Task {
                                    await viewModel.cancelDownload(id: item.id)
                                }
                            }
                            .accessibilityLabel(String(localized: "downloads.actions.cancel"))
                        }
                    }
                }

                Section(
                    header: SectionHeader(
                        title: String(localized: "downloads.completed.title"),
                        subtitle: String(localized: "downloads.completed.subtitle")
                    )
                ) {
                    ForEach(viewModel.completedDownloads) { item in
                        if let savedPageID = item.savedPageID {
                            NavigationLink {
                                OfflineReaderView(viewModel: viewModel.makeReaderViewModel(for: savedPageID))
                            } label: {
                                DownloadRowView(row: item)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("downloads-completed-row-\(item.id.uuidString)")
                        } else {
                            DownloadRowView(row: item)
                                .accessibilityIdentifier("downloads-completed-row-\(item.id.uuidString)")
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(String(localized: "downloads.navigation.title"))
        .overlay(alignment: .top) {
            if viewModel.isLoading {
                ProgressView()
                    .padding(.top, 12)
            }
        }
        .task {
            await viewModel.loadContentIfNeeded()
        }
    }
}

#Preview {
    DownloadsView(viewModel: DownloadsViewModel(downloadService: PreviewDownloadsService(), offlineReaderService: StubOfflineReaderService()))
}

private struct DownloadRowView: View {
    let row: DownloadsViewModel.DownloadRow

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 16) {
                Image(systemName: row.systemImageName)
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(row.title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(row.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(row.status)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            if let progress = row.progress {
                ProgressView(value: progress)
                    .progressViewStyle(.linear)
            }

            if let reason = row.failureReason {
                Text(reason)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

@MainActor
private final class PreviewDownloadsService: DownloadService {
    private var active: [DownloadRecord]
    private var completed: [DownloadRecord]

    init() {
        active = [
            DownloadRecord(
                title: "SwiftUI Offline Best Practices",
                detail: "developer.apple.com • 12 MB",
                status: .inProgress(progress: 0.45)
            ),
            DownloadRecord(
                title: "Designing Reader Experiences",
                detail: "medium.com • 8 MB",
                status: .pending
            )
        ]
        completed = [
            DownloadRecord(
                title: "Caching Strategies for iOS",
                detail: "kodeco.com • 9 MB",
                createdAt: Date().addingTimeInterval(-3600),
                status: .available
            ),
            DownloadRecord(
                title: "Offline Interview Prep",
                detail: "example.com",
                createdAt: Date().addingTimeInterval(-7200),
                status: .failed(reason: "Network timeout")
            )
        ]
    }

    func fetchActiveDownloads() async -> [DownloadRecord] { active }
    func fetchCompletedDownloads() async -> [DownloadRecord] { completed }
    func cancelDownload(id: UUID) async {}
    func updates() -> AsyncStream<Void> { AsyncStream { $0.finish() } }
    func enqueueCapture(from url: URL) async throws -> SavedPage {
        SavedPage(title: url.absoluteString, url: url)
    }
}

