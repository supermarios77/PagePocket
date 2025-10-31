import SwiftUI
import WebKit

struct ReaderView: View {
    let page: SavedPage
    @StateObject private var viewModel: ReaderViewModel

    init(page: SavedPage) {
        self.page = page
        _viewModel = StateObject(wrappedValue: ReaderViewModel(page: page))
    }

    var body: some View {
        Group {
            if let url = viewModel.indexFileURL {
                LocalWebView(url: url)
            } else {
                ContentUnavailableView("File Missing", systemImage: "doc.questionmark", description: Text("Could not find saved page."))
            }
        }
        .navigationTitle(page.title ?? page.url)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LocalWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.suppressesIncrementalRendering = false
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let folderURL = url.deletingLastPathComponent()
        webView.loadFileURL(url, allowingReadAccessTo: folderURL)
    }
}


