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
                        titleKey: "downloads.active.title",
                        subtitleKey: "downloads.active.subtitle"
                    )
                ) {
                    ForEach(DownloadsViewData.activeDownloads) { item in
                        PlaceholderListRow(
                            titleKey: item.titleKey,
                            subtitleKey: item.subtitleKey,
                            statusKey: item.statusKey,
                            systemImageName: item.systemImageName
                        )
                        .accessibilityIdentifier("downloads-active-row-\(item.id.uuidString)")
                    }
                }

                Section(
                    header: SectionHeader(
                        titleKey: "downloads.completed.title",
                        subtitleKey: "downloads.completed.subtitle"
                    )
                ) {
                    ForEach(DownloadsViewData.completedDownloads) { item in
                        PlaceholderListRow(
                            titleKey: item.titleKey,
                            subtitleKey: item.subtitleKey,
                            statusKey: item.statusKey,
                            systemImageName: item.systemImageName
                        )
                        .accessibilityIdentifier("downloads-completed-row-\(item.id.uuidString)")
                    }
                }
            }
            .listStyle(.insetGrouped)

            VStack(alignment: .leading, spacing: 12) {
                Text("downloads.actions.title")
                    .font(.headline)

                VStack(spacing: 12) {
                    Button(action: {}) {
                        Label("downloads.actions.import", systemImage: "folder.badge.plus")
                            .labelStyle(.titleAndIcon)
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button(action: {}) {
                        Label("downloads.actions.manage", systemImage: "slider.horizontal.3")
                            .labelStyle(.titleAndIcon)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .overlay(
                Rectangle()
                    .fill(Color(.separator))
                    .frame(height: 1),
                alignment: .top
            )
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("downloads.navigation.title")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel("downloads.navigation.menu")
            }
        }
    }
}

private enum DownloadsViewData {
    struct DownloadItem: Identifiable, Equatable {
        let id = UUID()
        let titleKey: LocalizedStringKey
        let subtitleKey: LocalizedStringKey
        let statusKey: LocalizedStringKey
        let systemImageName: String
    }

    static let activeDownloads: [DownloadItem] = [
        DownloadItem(
            titleKey: "downloads.active.item1.title",
            subtitleKey: "downloads.active.item1.subtitle",
            statusKey: "downloads.active.item.status.pending",
            systemImageName: "arrow.down.circle"
        ),
        DownloadItem(
            titleKey: "downloads.active.item2.title",
            subtitleKey: "downloads.active.item2.subtitle",
            statusKey: "downloads.active.item.status.inProgress",
            systemImageName: "arrow.down.circle"
        )
    ]

    static let completedDownloads: [DownloadItem] = [
        DownloadItem(
            titleKey: "downloads.completed.item1.title",
            subtitleKey: "downloads.completed.item1.subtitle",
            statusKey: "downloads.completed.item.status.available",
            systemImageName: "checkmark.circle"
        ),
        DownloadItem(
            titleKey: "downloads.completed.item2.title",
            subtitleKey: "downloads.completed.item2.subtitle",
            statusKey: "downloads.completed.item.status.archived",
            systemImageName: "archivebox"
        )
    ]
}

#Preview {
    DownloadsView(viewModel: DownloadsViewModel())
}

