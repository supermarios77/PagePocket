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
                        PlaceholderListRow(
                            title: item.title,
                            subtitle: item.subtitle,
                            status: item.status,
                            systemImageName: item.systemImageName
                        )
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
                        PlaceholderListRow(
                            title: item.title,
                            subtitle: item.subtitle,
                            status: item.status,
                            systemImageName: item.systemImageName
                        )
                        .accessibilityIdentifier("downloads-completed-row-\(item.id.uuidString)")
                    }
                }
            }
            .listStyle(.insetGrouped)

            VStack(alignment: .leading, spacing: 12) {
                Text(String(localized: "downloads.actions.title"))
                    .font(.headline)

                VStack(spacing: 12) {
                    Button(action: {}) {
                        Label(String(localized: "downloads.actions.import"), systemImage: "folder.badge.plus")
                            .labelStyle(.titleAndIcon)
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button(action: {}) {
                        Label(String(localized: "downloads.actions.manage"), systemImage: "slider.horizontal.3")
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
        .navigationTitle(String(localized: "downloads.navigation.title"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel(String(localized: "downloads.navigation.menu"))
            }
        }
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
    DownloadsView(viewModel: DownloadsViewModel(downloadService: InMemoryDownloadService()))
}

