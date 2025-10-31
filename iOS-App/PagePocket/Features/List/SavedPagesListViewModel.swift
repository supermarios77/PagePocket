import Foundation
import CoreData

final class SavedPagesListViewModel: ObservableObject {
    @Published var pages: [SavedPage] = []
    @Published var errorMessage: String?

    private let persistence: PersistenceController
    private let repository: SavedPageRepositoryProtocol

    init(persistence: PersistenceController = .shared, repository: SavedPageRepositoryProtocol = SavedPageRepository()) {
        self.persistence = persistence
        self.repository = repository
    }

    func load() {
        do {
            pages = try repository.fetchAll(in: persistence.viewContext)
        } catch {
            errorMessage = (error as NSError).localizedDescription
        }
    }

    func delete(at offsets: IndexSet) {
        for index in offsets {
            let page = pages[index]
            do {
                try repository.delete(page, in: persistence.viewContext)
                // Remove from array after successful deletion
                pages.remove(at: index)
                // Optionally remove folder on disk
                if !page.folderPath.isEmpty {
                    try? FileManager.default.removeItem(atPath: page.folderPath)
                }
            } catch {
                errorMessage = (error as NSError).localizedDescription
            }
        }
    }
}


