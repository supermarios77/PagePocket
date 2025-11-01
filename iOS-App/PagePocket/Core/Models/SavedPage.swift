//
//  SavedPage.swift
//  PagePocket
//


import Foundation

struct SavedPage: Identifiable, Hashable {
    enum Status: String, Codable, Hashable {
        case new
        case inProgress
        case completed

        var localizedDescription: String {
            switch self {
            case .new:
                String(localized: "home.readingList.item.status.new")
            case .inProgress:
                String(localized: "home.readingList.item.status.progress")
            case .completed:
                String(localized: "home.readingList.item.status.completed")
            }
        }
    }

    enum ContentType: String, Codable, Hashable {
        case article
        case collection
        case document

        var systemImageName: String {
            switch self {
            case .article:
                "globe"
            case .collection:
                "rectangle.3.group.bubble.left"
            case .document:
                "doc.richtext"
            }
        }
    }

    let id: UUID
    let title: String
    let url: URL
    let source: String
    let createdAt: Date
    var status: Status
    var contentType: ContentType
    var htmlContent: String?
    var lastAccessedAt: Date?
    var estimatedReadTime: TimeInterval

    init(
        id: UUID = UUID(),
        title: String,
        url: URL,
        source: String? = nil,
        createdAt: Date = Date(),
        status: Status = .new,
        contentType: ContentType = .article,
        htmlContent: String? = nil,
        lastAccessedAt: Date? = nil,
        estimatedReadTime: TimeInterval = 0
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.source = source ?? url.host ?? url.absoluteString
        self.createdAt = createdAt
        self.status = status
        self.contentType = contentType
        self.htmlContent = htmlContent
        self.lastAccessedAt = lastAccessedAt
        self.estimatedReadTime = estimatedReadTime
    }

    static func estimateReadTime(for html: String?) -> TimeInterval {
        guard let html, !html.isEmpty else { return 0 }
        let plainText = stripHTML(html)
        let words = Double(plainText.split { !$0.isLetter && !$0.isNumber }.count)
        let minutes = words / 230.0
        return max(minutes * 60, 30)
    }

    private static func stripHTML(_ html: String) -> String {
        if let data = html.data(using: .utf8),
           let attributed = try? NSAttributedString(
               data: data,
               options: [
                   .documentType: NSAttributedString.DocumentType.html,
                   .characterEncoding: String.Encoding.utf8.rawValue
               ],
               documentAttributes: nil
           ) {
            return attributed.string
        }

        return html.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

