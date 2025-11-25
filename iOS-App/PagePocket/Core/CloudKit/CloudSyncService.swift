//
//  CloudSyncService.swift
//  PagePocket
//

import CloudKit
import Foundation

/// Service for syncing saved pages with iCloud using CloudKit
protocol CloudSyncService: Sendable {
    /// Sync all local pages with iCloud
    func syncPages() async throws
    
    /// Upload a single page to iCloud
    func uploadPage(_ page: SavedPage) async throws
    
    /// Download all pages from iCloud
    func downloadPages() async throws -> [SavedPage]
    
    /// Get sync status
    var isSyncing: Bool { get }
    
    /// Get last sync date
    var lastSyncDate: Date? { get }
}

enum CloudSyncError: LocalizedError {
    case notAuthenticated
    case quotaExceeded
    case networkError(Error)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Please sign in to iCloud to enable cloud sync."
        case .quotaExceeded:
            return "iCloud storage quota exceeded. Please free up space."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknown(let error):
            return "Sync error: \(error.localizedDescription)"
        }
    }
}

/// CloudKit implementation of CloudSyncService
actor CloudKitSyncService: CloudSyncService {
    private let container: CKContainer
    private let privateDatabase: CKDatabase
    private var isSyncInProgress = false
    private var _lastSyncDate: Date?
    
    var isSyncing: Bool { isSyncInProgress }
    var lastSyncDate: Date? { _lastSyncDate }
    
    init(container: CKContainer = .default()) {
        self.container = container
        self.privateDatabase = container.privateCloudDatabase
    }
    
    // MARK: - CloudSyncService
    
    func syncPages() async throws {
        guard !isSyncInProgress else { return }
        isSyncInProgress = true
        defer { isSyncInProgress = false }
        
        // Check iCloud account status
        try await verifyAccountStatus()
        
        // Get last sync date to only fetch changes
        let lastSync = _lastSyncDate ?? Date(timeIntervalSince1970: 0)
        
        // Fetch changes from CloudKit
        let cloudPages = try await fetchRecentChanges(since: lastSync)
        
        // Update last sync date
        _lastSyncDate = Date()
        
        // Note: Actual merging should happen in the storage layer
        // This service just provides the CloudKit interface
        _ = cloudPages
    }
    
    func uploadPage(_ page: SavedPage) async throws {
        try await verifyAccountStatus()
        
        let record = try createRecord(from: page)
        
        do {
            _ = try await privateDatabase.save(record)
        } catch {
            if (error as NSError).code == CKError.quotaExceeded.rawValue {
                throw CloudSyncError.quotaExceeded
            }
            throw CloudSyncError.networkError(error)
        }
    }
    
    func downloadPages() async throws -> [SavedPage] {
        try await verifyAccountStatus()
        
        let query = CKQuery(recordType: AppConstants.CloudKit.recordType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        do {
            let result = try await privateDatabase.records(matching: query)
            return try result.matchResults.compactMap { _, result -> SavedPage? in
                switch result {
                case .success(let record):
                    return try self.createPage(from: record)
                case .failure:
                    return nil
                }
            }
        } catch {
            throw CloudSyncError.networkError(error)
        }
    }
    
    // MARK: - Private Helpers
    
    private func verifyAccountStatus() async throws {
        do {
            let status = try await container.accountStatus()
            guard status == .available else {
                throw CloudSyncError.notAuthenticated
            }
        } catch let error as CloudSyncError {
            throw error
        } catch {
            throw CloudSyncError.unknown(error)
        }
    }
    
    private func fetchRecentChanges(since date: Date) async throws -> [SavedPage] {
        // Simplify: just get all records for now
        // Can optimize with change tokens later if needed
        let query = CKQuery(
            recordType: AppConstants.CloudKit.recordType,
            predicate: NSPredicate(value: true) // Get all records
        )
        query.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: false)]
        
        do {
            let result = try await privateDatabase.records(matching: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: AppConstants.CloudKit.resultsLimit)
            return try result.matchResults.compactMap { _, recordResult -> SavedPage? in
                switch recordResult {
                case .success(let record):
                    return try self.createPage(from: record)
                case .failure:
                    return nil
                }
            }
        } catch {
            throw CloudSyncError.networkError(error)
        }
    }
    
    private func createRecord(from page: SavedPage) throws -> CKRecord {
        let recordID = CKRecord.ID(recordName: page.id.uuidString)
        let record = CKRecord(recordType: AppConstants.CloudKit.recordType, recordID: recordID)
        
        record["title"] = page.title
        record["urlString"] = page.url.absoluteString
        record["source"] = page.source
        record["createdAt"] = page.createdAt
        record["statusRawValue"] = page.status.rawValue
        record["contentTypeRawValue"] = page.contentType.rawValue
        record["htmlContent"] = page.htmlContent
        record["lastAccessedAt"] = page.lastAccessedAt
        record["estimatedReadTime"] = page.estimatedReadTime
        
        return record
    }
    
    private func createPage(from record: CKRecord) throws -> SavedPage {
        guard let title = record["title"] as? String,
              let urlString = record["urlString"] as? String,
              let source = record["source"] as? String,
              let createdAt = record["createdAt"] as? Date,
              let statusRawValue = record["statusRawValue"] as? String,
              let contentTypeRawValue = record["contentTypeRawValue"] as? String,
              let estimatedReadTime = record["estimatedReadTime"] as? Double else {
            throw CloudSyncError.unknown(NSError(domain: "CloudSyncService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid record data"]))
        }
        
        guard let url = URL(string: urlString),
              let status = SavedPage.Status(rawValue: statusRawValue),
              let contentType = SavedPage.ContentType(rawValue: contentTypeRawValue) else {
            throw CloudSyncError.unknown(NSError(domain: "CloudSyncService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid record values"]))
        }
        
        // Validate URL scheme for security
        guard let scheme = url.scheme?.lowercased(), ["http", "https"].contains(scheme) else {
            throw CloudSyncError.unknown(NSError(domain: "CloudSyncService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL scheme in record"]))
        }
        
        let htmlContent = record["htmlContent"] as? String
        let lastAccessedAt = record["lastAccessedAt"] as? Date
        
        // Extract ID from record name - create new UUID if invalid
        let id: UUID
        if let parsedID = UUID(uuidString: record.recordID.recordName) {
            id = parsedID
        } else {
            // Log warning but don't fail - create new ID for corrupted record
            id = UUID()
        }
        
        return SavedPage(
            id: id,
            title: title,
            url: url,
            source: source,
            createdAt: createdAt,
            status: status,
            contentType: contentType,
            htmlContent: htmlContent,
            lastAccessedAt: lastAccessedAt,
            estimatedReadTime: estimatedReadTime
        )
    }
}

/// Mock implementation for testing
actor MockCloudSyncService: CloudSyncService {
    var isSyncing: Bool = false
    var lastSyncDate: Date? = nil
    private var cloudPages: [SavedPage] = []
    
    func syncPages() async throws {
        isSyncing = true
        defer { isSyncing = false }
        try await Task.sleep(for: .seconds(1))
        lastSyncDate = Date()
    }
    
    func uploadPage(_ page: SavedPage) async throws {
        // Simulate network delay
        try await Task.sleep(for: .seconds(0.5))
        cloudPages.append(page)
    }
    
    func downloadPages() async throws -> [SavedPage] {
        try await Task.sleep(for: .seconds(1))
        return cloudPages
    }
}

