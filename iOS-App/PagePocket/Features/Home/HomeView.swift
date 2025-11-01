import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("placeholder.home.message")
        }
        .padding()
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}

