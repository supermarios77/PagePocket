//
//  SavedPage.swift
//  PagePocket
//


import Foundation

struct SavedPage: Identifiable, Hashable {
    enum Status: Hashable {
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

    enum ContentType: Hashable {
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

    init(
        id: UUID = UUID(),
        title: String,
        url: URL,
        source: String? = nil,
        createdAt: Date = Date(),
        status: Status = .new,
        contentType: ContentType = .article
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.source = source ?? url.host ?? url.absoluteString
        self.createdAt = createdAt
        self.status = status
        self.contentType = contentType
    }
}

