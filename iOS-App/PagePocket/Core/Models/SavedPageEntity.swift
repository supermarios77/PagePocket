import Foundation
import SwiftData

@Model
final class SavedPageEntity {
    @Attribute(.unique) var id: UUID
    var title: String
    var urlString: String
    var source: String
    var createdAt: Date
    var statusRawValue: String
    var contentTypeRawValue: String
    var htmlContent: String?
    var lastAccessedAt: Date?
    var estimatedReadTime: Double

    init(
        id: UUID,
        title: String,
        urlString: String,
        source: String,
        createdAt: Date,
        statusRawValue: String,
        contentTypeRawValue: String,
        htmlContent: String?,
        lastAccessedAt: Date?,
        estimatedReadTime: Double
    ) {
        self.id = id
        self.title = title
        self.urlString = urlString
        self.source = source
        self.createdAt = createdAt
        self.statusRawValue = statusRawValue
        self.contentTypeRawValue = contentTypeRawValue
        self.htmlContent = htmlContent
        self.lastAccessedAt = lastAccessedAt
        self.estimatedReadTime = estimatedReadTime
    }

    convenience init(page: SavedPage) {
        self.init(
            id: page.id,
            title: page.title,
            urlString: page.url.absoluteString,
            source: page.source,
            createdAt: page.createdAt,
            statusRawValue: page.status.rawValue,
            contentTypeRawValue: page.contentType.rawValue,
            htmlContent: page.htmlContent,
            lastAccessedAt: page.lastAccessedAt,
            estimatedReadTime: page.estimatedReadTime
        )
    }
}

extension SavedPage {
    init(entity: SavedPageEntity) {
        // Safely create URL with fallback - never force unwrap
        let url: URL
        if let validURL = URL(string: entity.urlString) {
            url = validURL
        } else if let fallbackURL = URL(string: "about:blank") {
            url = fallbackURL
        } else {
            // Last resort: create a file URL to prevent crash
            url = URL(fileURLWithPath: "/")
        }
        
        self.init(
            id: entity.id,
            title: entity.title,
            url: url,
            source: entity.source,
            createdAt: entity.createdAt,
            status: Status(rawValue: entity.statusRawValue) ?? .new,
            contentType: ContentType(rawValue: entity.contentTypeRawValue) ?? .article,
            htmlContent: entity.htmlContent,
            lastAccessedAt: entity.lastAccessedAt,
            estimatedReadTime: entity.estimatedReadTime
        )
    }
}

