//
//  OfflineReaderService.swift
//  PagePocket
//


import Foundation

protocol OfflineReaderService {
    func savePage(from url: URL) async throws -> SavedPage
    func deletePage(_ page: SavedPage) async throws
    func listSavedPages() async throws -> [SavedPage]
}

struct StubOfflineReaderService: OfflineReaderService {
    func savePage(from url: URL) async throws -> SavedPage {
        SavedPage(url: url)
    }

    func deletePage(_ page: SavedPage) async throws {}

    func listSavedPages() async throws -> [SavedPage] {
        []
    }
}

