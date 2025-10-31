import Foundation
import CoreData

extension SavedPage {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedPage> {
        NSFetchRequest<SavedPage>(entityName: "SavedPage")
    }

    @NSManaged public var id: UUID
    @NSManaged public var url: String
    @NSManaged public var title: String?
    @NSManaged public var savedAt: Date
    @NSManaged public var folderPath: String
    @NSManaged public var isCleaned: Bool
    @NSManaged public var approxSize: Int64
}

extension SavedPage: Identifiable {}


