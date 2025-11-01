//
//  SavedPage.swift
//  PagePocket
//


import Foundation

struct SavedPage: Identifiable, Hashable {
    let id: UUID
    let url: URL
    let createdAt: Date

    init(id: UUID = UUID(), url: URL, createdAt: Date = Date()) {
        self.id = id
        self.url = url
        self.createdAt = createdAt
    }
}

