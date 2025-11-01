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
        var capturedError: Error?
        context.performAndWait {
            let entity = SavedPage(context: context)
            entity.id = input.id
            entity.url = input.url
            entity.title = input.title
            entity.savedAt = input.savedAt
            entity.folderPath = input.folderPath
            entity.isCleaned = input.isCleaned
            if let approxSize = input.approxSize { entity.approxSize = approxSize }
            do {
                try context.save()
            } catch {
                capturedError = error
            }
        }
        if let error = capturedError {
            throw error
        }
    }

    func fetchAll(in context: NSManagedObjectContext) throws -> [SavedPage] {
        var results: [SavedPage] = []
        var capturedError: Error?
        context.performAndWait {
            let request: NSFetchRequest<SavedPage> = SavedPage.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: #keyPath(SavedPage.savedAt), ascending: false)]
            do {
                results = try context.fetch(request)
            } catch {
                capturedError = error
            }
        }
        if let error = capturedError {
            throw error
        }
        return results
    }

    func delete(_ page: SavedPage, in context: NSManagedObjectContext) throws {
        var capturedError: Error?
        context.performAndWait {
            context.delete(page)
            do {
                try context.save()
            } catch {
                capturedError = error
            }
        }
        if let error = capturedError {
            throw error
        }
    }

    func delete(by id: UUID, in context: NSManagedObjectContext) throws {
        var capturedError: Error?
        context.performAndWait {
            let request: NSFetchRequest<SavedPage> = SavedPage.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            do {
                if let page = try context.fetch(request).first {
                    context.delete(page)
                    try context.save()
                }
            } catch {
                capturedError = error
            }
        }
        if let error = capturedError {
            throw error
        }
    }
}

