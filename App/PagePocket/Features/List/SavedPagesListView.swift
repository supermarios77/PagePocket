import SwiftUI

struct SavedPagesListView: View {
    @StateObject private var viewModel = SavedPagesListViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.pages) { page in
                    NavigationLink(destination: ReaderView(page: page)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(page.title ?? page.url)
                                .font(.headline)
                                .lineLimit(2)
                            Text(page.url)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Saved page: \(page.title ?? page.url)")
                    }
                }
                .onDelete(perform: viewModel.delete)
            }
            .navigationTitle("Saved Pages")
            .onAppear { viewModel.load() }
            .overlay(alignment: .bottom) {
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.orange)
                        .padding(.bottom, 8)
                }
            }
        }
    }
}

#Preview {
    SavedPagesListView()
}


