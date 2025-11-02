//
//  CloudSyncOfflineReaderService.swift
//  PagePocket
//

import Foundation

/// Wraps OfflineReaderService to add CloudKit sync for premium users
struct CloudSyncOfflineReaderService: OfflineReaderService {
    private let wrapped: OfflineReaderService
    private let purchaseService: PurchaseService
    private let cloudSyncService: CloudSyncService
    
    init(
        wrapping: OfflineReaderService,
        purchaseService: PurchaseService,
        cloudSyncService: CloudSyncService
    ) {
        self.wrapped = wrapping
        self.purchaseService = purchaseService
        self.cloudSyncService = cloudSyncService
    }
    
    func savePage(from url: URL) async throws -> SavedPage {
        let page = try await wrapped.savePage(from: url)
        
        // Upload to iCloud if user is premium with cloud sync enabled
        await uploadIfPremium(page: page)
        
        return page
    }
    
    func deletePage(_ pageID: UUID) async throws {
        try await wrapped.deletePage(pageID)
        // Note: CloudKit deletion can be added if needed
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
    
    // MARK: - Private Helpers
    
    private func uploadIfPremium(page: SavedPage) async {
        let entitlements = purchaseService.currentEntitlements
        
        // Only upload if user is premium with cloud sync enabled
        guard entitlements.isPremium && entitlements.cloudSyncEnabled else {
            return
        }
        
        // Upload in background without blocking the UI
        Task {
            do {
                try await cloudSyncService.uploadPage(page)
            } catch {
                // Log error but don't fail the save operation
                // User can retry sync later if needed
                print("Failed to upload page to iCloud: \(error.localizedDescription)")
            }
        }
    }
}

