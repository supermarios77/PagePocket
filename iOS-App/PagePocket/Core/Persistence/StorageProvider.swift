//
//  StorageProvider.swift
//  PagePocket
//


import Foundation

protocol StorageProvider {
    func store(page: SavedPage) async throws
    func remove(pageID: UUID) async throws
    func loadPages() async throws -> [SavedPage]
    func updateStatus(for pageID: UUID, status: SavedPage.Status) async throws
}

enum StorageProviderError: Error {
    case pageNotFound
}

actor InMemoryStorageProvider: StorageProvider {
    private var pages: [UUID: SavedPage]

    init(seedPages: [SavedPage] = []) {
        self.pages = Dictionary(uniqueKeysWithValues: seedPages.map { ($0.id, $0) })
    }

    func store(page: SavedPage) async throws {
        pages[page.id] = page
    }

    func remove(pageID: UUID) async throws {
        guard pages.removeValue(forKey: pageID) != nil else {
            throw StorageProviderError.pageNotFound
        }
    }

    func loadPages() async throws -> [SavedPage] {
        pages.values.sorted(by: { $0.createdAt > $1.createdAt })
    }

    func updateStatus(for pageID: UUID, status: SavedPage.Status) async throws {
        guard var page = pages[pageID] else {
            throw StorageProviderError.pageNotFound
        }
        page.status = status
        pages[pageID] = page
    }
}

