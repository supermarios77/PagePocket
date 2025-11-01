import Combine
import Foundation

@MainActor
final class OfflineReaderViewModel: ObservableObject {
    @Published private(set) var title: String = ""
    @Published private(set) var htmlContent: String?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    var shareURL: URL? { currentPage?.url }

    private let pageID: UUID
    private let offlineReaderService: OfflineReaderService
    private var currentPage: SavedPage?

    init(pageID: UUID, offlineReaderService: OfflineReaderService) {
        self.pageID = pageID
        self.offlineReaderService = offlineReaderService
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            guard let page = try await offlineReaderService.page(with: pageID) else {
                errorMessage = String(localized: "reader.error.unavailable")
                return
            }

            currentPage = page
            title = page.title
            htmlContent = page.htmlContent ?? OfflineReaderViewModel.fallbackHTML(for: page)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private static func fallbackHTML(for page: SavedPage) -> String {
        """
        <html><head><meta charset=\"utf-8\"></head><body>
        <article>
        <h1>\(page.title)</h1>
        <p>Offline content is not available for this page yet. Try refreshing while online.</p>
        <p><a href=\"\(page.url.absoluteString)\">Open original article</a></p>
        </article>
        </body></html>
        """
    }
}

