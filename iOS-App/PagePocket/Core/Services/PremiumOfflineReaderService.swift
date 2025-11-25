//
//  PremiumOfflineReaderService.swift
//  PagePocket
//

import Foundation

/// Wraps OfflineReaderService to enforce premium limits
struct PremiumOfflineReaderService: OfflineReaderService {
    private let wrapped: OfflineReaderService
    private let purchaseService: PurchaseService
    
    init(wrapping: OfflineReaderService, purchaseService: PurchaseService) {
        self.wrapped = wrapping
        self.purchaseService = purchaseService
    }
    
    func savePage(from url: URL) async throws -> SavedPage {
        // Check premium status and page count
        // Note: There's a small race condition window here - if two saves happen
        // simultaneously, both might pass the check. However, this is acceptable
        // as the free tier limit is a soft limit for UX purposes.
        // For strict enforcement, we'd need a transactional check-and-save operation.
        let entitlements = purchaseService.currentEntitlements
        
        // Premium users can always save
        guard !entitlements.isPremium else {
            return try await wrapped.savePage(from: url)
        }
        
        // For free users, check page count
        let existingPages = try await wrapped.listSavedPages()
        
        // Check if user can save more pages
        guard entitlements.canSavePage(currentPageCount: existingPages.count) else {
            throw OfflineReaderError.freeLimitReached
        }
        
        // Proceed with save
        return try await wrapped.savePage(from: url)
    }
    
    func deletePage(_ pageID: UUID) async throws {
        try await wrapped.deletePage(pageID)
    }
    
    func listSavedPages() async throws -> [SavedPage] {
        try await wrapped.listSavedPages()
    }
    
    func updateStatus(for pageID: UUID, status: SavedPage.Status) async throws {
        try await wrapped.updateStatus(for: pageID, status: status)
    }
    
    func page(with id: UUID) async throws -> SavedPage? {
        try await wrapped.page(with: id)
    }
}

