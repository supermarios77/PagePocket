import Foundation
import CoreData

enum PageSaveServiceError: Error {
    case invalidInput
}

struct PageSaveResult {
    let id: UUID
    let url: URL
    let title: String?
    let savedAt: Date
    let folderPath: String
    let isCleaned: Bool
    let approxSize: Int64
}

struct PageSaveService {
    private let fetcher: PageFetcher
    private let parser: AssetParser
    private let rewriter: AssetRewriter
    private let cleaner: HTMLCleaner
    private let storage: StorageManager
    private let persistence: PersistenceController
    private let repository: SavedPageRepositoryProtocol

    init(fetcher: PageFetcher = PageFetcher(),
         parser: AssetParser = AssetParser(),
         rewriter: AssetRewriter = AssetRewriter(),
         cleaner: HTMLCleaner = HTMLCleaner(),
         storage: StorageManager = StorageManager(),
         persistence: PersistenceController = .shared,
         repository: SavedPageRepositoryProtocol = SavedPageRepository()) {
        self.fetcher = fetcher
        self.parser = parser
        self.rewriter = rewriter
        self.cleaner = cleaner
        self.storage = storage
        self.persistence = persistence
        self.repository = repository
    }

    @discardableResult
    func savePage(from input: String, isCleaned: Bool = false) async throws -> PageSaveResult {
        guard let url = URLUtilities.normalizedURL(from: input) else {
            throw PageSaveServiceError.invalidInput
        }

        var htmlData = try await fetcher.fetchHTML(from: url)
        if isCleaned {
            htmlData = cleaner.clean(htmlData)
        }
        let assets = parser.extractAssets(from: htmlData, baseURL: url)
        let rewritten = rewriter.rewrite(htmlData: htmlData, baseURL: url, assets: assets)

        let id = UUID()
        let pageDir = try storage.pageDirectory(for: id)
        let indexURL = try storage.saveIndexHTML(rewritten.htmlData, for: id)

        let downloadedBytes = try await storage.downloadAssets(id: id, mapping: rewritten.assetURLToRelativePath)
        let indexBytes = (try? FileManager.default.attributesOfItem(atPath: indexURL.path)[.size] as? NSNumber)?.int64Value ?? 0
        let approxSize = downloadedBytes + indexBytes

        let title = extractTitle(from: rewritten.htmlData)
        let inputModel = SavedPageInput(
            id: id,
            url: url.absoluteString,
            title: title,
            savedAt: Date(),
            folderPath: pageDir.path,
            isCleaned: isCleaned,
            approxSize: approxSize
        )

        try repository.create(inputModel, in: persistence.viewContext)

        return PageSaveResult(
            id: id,
            url: url,
            title: title,
            savedAt: inputModel.savedAt,
            folderPath: inputModel.folderPath,
            isCleaned: isCleaned,
            approxSize: approxSize
        )
    }

    private func extractTitle(from htmlData: Data) -> String? {
        guard let html = String(data: htmlData, encoding: .utf8) ?? String(data: htmlData, encoding: .isoLatin1) else { return nil }
        // Simple <title> extractor
        if let rangeStart = html.range(of: "<title", options: .caseInsensitive),
           let tagClose = html.range(of: ">", range: rangeStart.upperBound..<html.endIndex),
           let endRange = html.range(of: "</title>", options: .caseInsensitive, range: tagClose.upperBound..<html.endIndex) {
            let titleContent = html[tagClose.upperBound..<endRange.lowerBound]
            return titleContent.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return nil
    }
}


