//
//  StorageProvider.swift
//  PagePocket
//


import Foundation

protocol StorageProvider {
    func store(page: SavedPage) async throws
    func remove(page: SavedPage) async throws
    func loadPages() async throws -> [SavedPage]
}

struct InMemoryStorageProvider: StorageProvider {
    func store(page: SavedPage) async throws {}

    func remove(page: SavedPage) async throws {}

    func loadPages() async throws -> [SavedPage] {
        []
    }
}

