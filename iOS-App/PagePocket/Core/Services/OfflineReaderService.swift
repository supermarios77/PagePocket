//
//  OfflineReaderService.swift
//  PagePocket
//


import Foundation

extension Notification.Name {
    static let offlineReaderPageSaved = Notification.Name("OfflineReaderPageSavedNotification")
    static let offlineReaderPageDeleted = Notification.Name("OfflineReaderPageDeletedNotification")
    static let offlineReaderPageUpdated = Notification.Name("OfflineReaderPageUpdatedNotification")
}

enum OfflineReaderError: Error, LocalizedError {
    case contentTooLarge(size: Int, maxSize: Int)
    case freeLimitReached
    case invalidURL
    case emptyContent
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .contentTooLarge(let size, let maxSize):
            let sizeMB = size / (1024 * 1024)
            let maxMB = maxSize / (1024 * 1024)
            return "Content too large (\(sizeMB)MB). Maximum size is \(maxMB)MB."
        case .freeLimitReached:
            return String(localized: "premium.freeLimit.message")
        case .invalidURL:
            return "Invalid URL. Please provide a valid http or https URL."
        case .emptyContent:
            return "The page returned no content. Please try a different URL."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

protocol OfflineReaderService {
    func savePage(from url: URL) async throws -> SavedPage
    func deletePage(_ pageID: UUID) async throws
    func listSavedPages() async throws -> [SavedPage]
    func updateStatus(for pageID: UUID, status: SavedPage.Status) async throws
    func page(with id: UUID) async throws -> SavedPage?
}

struct DefaultOfflineReaderService: OfflineReaderService {
    private let networkClient: NetworkClient
    private let storageProvider: StorageProvider

    init(networkClient: NetworkClient, storageProvider: StorageProvider) {
        self.networkClient = networkClient
        self.storageProvider = storageProvider
    }

    func savePage(from url: URL) async throws -> SavedPage {
        // Validate URL before attempting fetch
        guard let scheme = url.scheme?.lowercased(), ["http", "https"].contains(scheme) else {
            throw OfflineReaderError.invalidURL
        }
        
        let data = try await networkClient.fetchData(from: url)
        
        // Validate data size to prevent memory issues
        guard data.count <= AppConstants.Content.maxPageSizeBytes else {
            throw OfflineReaderError.contentTooLarge(size: data.count, maxSize: AppConstants.Content.maxPageSizeBytes)
        }
        
        // Validate data is not empty
        guard !data.isEmpty else {
            throw OfflineReaderError.emptyContent
        }
        
        let html = decodeHTML(from: data) ?? Self.placeholderHTML(for: url)
        let sanitizedHTML = sanitizeHTML(html, baseURL: url)
        let title = extractHTMLTitle(from: sanitizedHTML) ?? deriveFallbackTitle(from: url)
        let readTime = SavedPage.estimateReadTime(for: sanitizedHTML)
        let page = SavedPage(
            title: title,
            url: url,
            createdAt: Date(),
            status: .new,
            contentType: .article,
            htmlContent: sanitizedHTML,
            lastAccessedAt: Date(),
            estimatedReadTime: readTime
        )
        try await storageProvider.store(page: page)
        NotificationCenter.default.post(name: .offlineReaderPageSaved, object: page.id)
        return page
    }

    func deletePage(_ pageID: UUID) async throws {
        try await storageProvider.remove(pageID: pageID)
        NotificationCenter.default.post(name: .offlineReaderPageDeleted, object: pageID)
    }

    func listSavedPages() async throws -> [SavedPage] {
        try await storageProvider.loadPages()
    }

    func updateStatus(for pageID: UUID, status: SavedPage.Status) async throws {
        try await storageProvider.updateStatus(for: pageID, status: status)
        NotificationCenter.default.post(name: .offlineReaderPageUpdated, object: pageID)
    }

    func page(with id: UUID) async throws -> SavedPage? {
        try await storageProvider.page(with: id)
    }

    private func decodeHTML(from data: Data) -> String? {
        if let utf8String = String(data: data, encoding: .utf8), !utf8String.isEmpty {
            return utf8String
        }
        return String(decoding: data, as: UTF8.self)
    }

    private func deriveFallbackTitle(from url: URL) -> String {
        if let host = url.host?.replacingOccurrences(of: "www.", with: "") {
            return host.capitalized
        }
        return url.absoluteString
    }

    private func extractHTMLTitle(from html: String) -> String? {
        guard let range = html.range(of: #"<title>(.*?)</title>"#, options: [.regularExpression, .caseInsensitive]) else {
            return nil
        }
        let title = String(html[range])
            .replacingOccurrences(of: "<title>", with: "")
            .replacingOccurrences(of: "</title>", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return title.isEmpty ? nil : title
    }

    private func sanitizeHTML(_ html: String, baseURL: URL) -> String {
        var sanitized = removeScriptTags(from: html)
        
        // Also remove potentially dangerous tags
        sanitized = removeDangerousTags(from: sanitized)

        // Escape baseURL to prevent XSS
        let escapedBaseURL = baseURL.absoluteString
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#x27;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
        
        if let headRange = sanitized.range(of: "<head>", options: [.caseInsensitive]) {
            let baseTag = "<base href=\"\(escapedBaseURL)\">"
            sanitized.replaceSubrange(headRange, with: "<head>\n\(baseTag)")
        }

        return sanitized
    }
    
    private func removeDangerousTags(from html: String) -> String {
        var cleaned = html
        // Remove iframe, object, embed, form tags that could be security risks
        let dangerousPatterns = [
            "<iframe[\\s\\S]*?</iframe>",
            "<object[\\s\\S]*?</object>",
            "<embed[\\s\\S]*?>",
            "<form[\\s\\S]*?</form>",
            "<input[\\s\\S]*?>",
            "<meta[^>]*http-equiv[^>]*>"
        ]
        
        for pattern in dangerousPatterns {
            cleaned = cleaned.replacingOccurrences(
                of: pattern,
                with: "",
                options: [.regularExpression, .caseInsensitive]
            )
        }
        
        return cleaned
    }

    private func removeScriptTags(from html: String) -> String {
        html.replacingOccurrences(
            of: "<script[\\s\\S]*?</script>",
            with: "",
            options: [.regularExpression, .caseInsensitive]
        )
    }

    private static func placeholderHTML(for url: URL) -> String {
        """
        <html><head><meta charset=\"utf-8\"></head><body>
        <article>
        <h1>\(url.absoluteString)</h1>
        <p>This page was saved for offline viewing, but the network response did not include readable content.</p>
        </article>
        </body></html>
        """
    }
}

actor StubOfflineReaderService: OfflineReaderService {
    private var pages: [UUID: SavedPage]

    init(seedPages: [SavedPage] = []) {
        self.pages = Dictionary(uniqueKeysWithValues: seedPages.map { ($0.id, $0) })
    }

    func savePage(from url: URL) async throws -> SavedPage {
        let html = "<html><body><h1>\(url.absoluteString)</h1><p>Offline preview content.</p></body></html>"
        let page = SavedPage(
            title: url.absoluteString,
            url: url,
            htmlContent: html,
            estimatedReadTime: SavedPage.estimateReadTime(for: html)
        )
        pages[page.id] = page
        return page
    }

    func deletePage(_ pageID: UUID) async throws {
        pages.removeValue(forKey: pageID)
    }

    func listSavedPages() async throws -> [SavedPage] {
        pages.values.sorted(by: { $0.createdAt > $1.createdAt })
    }

    func updateStatus(for pageID: UUID, status: SavedPage.Status) async throws {
        guard var page = pages[pageID] else { return }
        page.status = status
        pages[pageID] = page
    }

    func page(with id: UUID) async throws -> SavedPage? {
        pages[id]
    }
}

