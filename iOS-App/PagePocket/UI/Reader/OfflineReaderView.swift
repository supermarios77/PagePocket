import SwiftUI
import WebKit

struct OfflineReaderView: View {
    @StateObject private var viewModel: OfflineReaderViewModel

    init(viewModel: OfflineReaderViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if let html = viewModel.htmlContent, let baseURL = viewModel.shareURL {
                OfflineWebView(html: html, baseURL: baseURL)
                    .ignoresSafeArea(edges: .bottom)
            } else if viewModel.isLoading {
                ProgressView(String(localized: "reader.loading"))
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Text(error)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            } else {
                ProgressView(String(localized: "reader.loading"))
            }
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let shareURL = viewModel.shareURL {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: shareURL) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityLabel(String(localized: "reader.toolbar.share"))
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

private struct OfflineWebView: UIViewRepresentable {
    let html: String
    let baseURL: URL

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = false
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .systemBackground
        webView.scrollView.backgroundColor = .systemBackground
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url != baseURL || context.coordinator.currentHTML != html {
            context.coordinator.currentHTML = html
            webView.loadHTMLString(html, baseURL: baseURL)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        var currentHTML: String?
    }
}

#Preview {
    NavigationStack {
        OfflineReaderView(
            viewModel: OfflineReaderViewModel(pageID: UUID(), offlineReaderService: StubOfflineReaderService())
        )
    }
}

