import SwiftUI

struct DownloadsView: View {
    @StateObject private var viewModel: DownloadsViewModel

    init(viewModel: DownloadsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Text("placeholder.downloads.message")
    }
}

#Preview {
    DownloadsView(viewModel: DownloadsViewModel())
}

