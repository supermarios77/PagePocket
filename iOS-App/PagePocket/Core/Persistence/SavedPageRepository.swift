import CoreData
import Foundation

struct SavedPageInput {
    let id: UUID
    let url: String
    let title: String?
    let savedAt: Date
    let folderPath: String
    let isCleaned: Bool
    let approxSize: Int64?
}

protocol SavedPageRepositoryProtocol {
    func create(_ input: SavedPageInput, in context: NSManagedObjectContext) throws
    func fetchAll(in context: NSManagedObjectContext) throws -> [SavedPage]
    func delete(_ page: SavedPage, in context: NSManagedObjectContext) throws
    func delete(by id: UUID, in context: NSManagedObjectContext) throws
}

struct SavedPageRepository: SavedPageRepositoryProtocol {
    func create(_ input: SavedPageInput, in context: NSManagedObjectContext) throws {
        let entity = SavedPage(context: context)
        entity.id = input.id
        entity.url = input.url
        entity.title = input.title
        entity.savedAt = input.savedAt
        entity.folderPath = input.folderPath
        entity.isCleaned = input.isCleaned
        if let approxSize = input.approxSize { entity.approxSize = approxSize }
        try context.save()
    }

    func fetchAll(in context: NSManagedObjectContext) throws -> [SavedPage] {
        let request: NSFetchRequest<SavedPage> = SavedPage.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(SavedPage.savedAt), ascending: false)]
        return try context.fetch(request)
    }

    func delete(_ page: SavedPage, in context: NSManagedObjectContext) throws {
        context.delete(page)
        try context.save()
    }

    func delete(by id: UUID, in context: NSManagedObjectContext) throws {
        let request: NSFetchRequest<SavedPage> = SavedPage.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        if let page = try context.fetch(request).first {
            try delete(page, in: context)
        }
    }
}

