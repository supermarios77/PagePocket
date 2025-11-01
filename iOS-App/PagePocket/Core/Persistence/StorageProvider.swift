//
//  StorageProvider.swift
//  PagePocket
//


import Foundation
import SwiftData

protocol StorageProvider {
    func store(page: SavedPage) async throws
    func remove(pageID: UUID) async throws
    func loadPages() async throws -> [SavedPage]
    func updateStatus(for pageID: UUID, status: SavedPage.Status) async throws
    func page(with id: UUID) async throws -> SavedPage?
}

enum StorageProviderError: Error {
    case pageNotFound
}

@MainActor
final class SwiftDataStorageProvider: StorageProvider {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func store(page: SavedPage) async throws {
        if let entity = try fetchEntity(with: page.id) {
            update(entity: entity, with: page)
        } else {
            let entity = SavedPageEntity(page: page)
            context.insert(entity)
        }
        try context.save()
    }

    func remove(pageID: UUID) async throws {
        guard let entity = try fetchEntity(with: pageID) else {
            throw StorageProviderError.pageNotFound
        }
        context.delete(entity)
        try context.save()
    }

    func loadPages() async throws -> [SavedPage] {
        let descriptor = FetchDescriptor<SavedPageEntity>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return try context.fetch(descriptor).map(SavedPage.init(entity:))
    }

    func updateStatus(for pageID: UUID, status: SavedPage.Status) async throws {
        guard let entity = try fetchEntity(with: pageID) else {
            throw StorageProviderError.pageNotFound
        }
        entity.statusRawValue = status.rawValue
        try context.save()
    }

    func page(with id: UUID) async throws -> SavedPage? {
        try fetchEntity(with: id).map(SavedPage.init(entity:))
    }

    private func fetchEntity(with id: UUID) throws -> SavedPageEntity? {
        let predicate = #Predicate<SavedPageEntity> { $0.id == id }
        var descriptor = FetchDescriptor<SavedPageEntity>(predicate: predicate)
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    private func update(entity: SavedPageEntity, with page: SavedPage) {
        entity.title = page.title
        entity.urlString = page.url.absoluteString
        entity.source = page.source
        entity.createdAt = page.createdAt
        entity.statusRawValue = page.status.rawValue
        entity.contentTypeRawValue = page.contentType.rawValue
        entity.htmlContent = page.htmlContent
        entity.lastAccessedAt = page.lastAccessedAt
        entity.estimatedReadTime = page.estimatedReadTime
    }
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

    func page(with id: UUID) async throws -> SavedPage? {
        pages[id]
    }
}

