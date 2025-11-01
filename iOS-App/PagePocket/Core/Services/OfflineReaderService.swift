//
//  OfflineReaderService.swift
//  PagePocket
//


import Foundation

protocol OfflineReaderService {
    func savePage(from url: URL) async throws -> SavedPage
    func deletePage(_ pageID: UUID) async throws
    func listSavedPages() async throws -> [SavedPage]
    func updateStatus(for pageID: UUID, status: SavedPage.Status) async throws
}

struct DefaultOfflineReaderService: OfflineReaderService {
    private let networkClient: NetworkClient
    private let storageProvider: StorageProvider

    init(networkClient: NetworkClient, storageProvider: StorageProvider) {
        self.networkClient = networkClient
        self.storageProvider = storageProvider
    }

    func savePage(from url: URL) async throws -> SavedPage {
        let data = try? await networkClient.fetchData(from: url)
        let title = try await deriveTitle(from: url, data: data)
        let page = SavedPage(
            title: title,
            url: url,
            createdAt: Date(),
            status: .new,
            contentType: .article
        )
        try await storageProvider.store(page: page)
        return page
    }

    func deletePage(_ pageID: UUID) async throws {
        try await storageProvider.remove(pageID: pageID)
    }

    func listSavedPages() async throws -> [SavedPage] {
        try await storageProvider.loadPages()
    }

    func updateStatus(for pageID: UUID, status: SavedPage.Status) async throws {
        try await storageProvider.updateStatus(for: pageID, status: status)
    }

    private func deriveTitle(from url: URL, data: Data?) async throws -> String {
        if let data,
           let html = String(data: data, encoding: .utf8),
           let title = extractHTMLTitle(from: html) {
            return title
        }
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
}

actor StubOfflineReaderService: OfflineReaderService {
    private var pages: [UUID: SavedPage]

    init(seedPages: [SavedPage] = []) {
        self.pages = Dictionary(uniqueKeysWithValues: seedPages.map { ($0.id, $0) })
    }

    func savePage(from url: URL) async throws -> SavedPage {
        let page = SavedPage(title: url.absoluteString, url: url)
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
}

