import Foundation

final class ReaderViewModel: ObservableObject {
    let page: SavedPage

    init(page: SavedPage) {
        self.page = page
    }

    var indexFileURL: URL? {
        guard !page.folderPath.isEmpty else { return nil }
        return URL(fileURLWithPath: page.folderPath).appendingPathComponent("index.html")
    }
}


