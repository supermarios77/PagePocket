//
//  StoreKit2PurchaseService.swift
//  PagePocket
//

import Foundation
import OSLog
import StoreKit

/// Production StoreKit 2 implementation of PurchaseService
actor StoreKit2PurchaseService: PurchaseService {
    nonisolated(unsafe) private(set) var currentEntitlements: SubscriptionEntitlements
    private var products: [Product] = []
    private var updateListenerTask: Task<Void, Never>?
    private var observers: [UUID: AsyncStream<SubscriptionEntitlements>.Continuation] = [:]
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "PagePocket", category: "StoreKit2Purchase")
    
    init() {
        self.currentEntitlements = .free
        
        // Start listening for transaction updates
        updateListenerTask = Task {
            await listenForTransactionUpdates()
        }
        
        // Load current subscription status
        // Store task reference to prevent memory leak
        let initialLoadTask = Task {
            await updateEntitlements()
        }
        // Task will complete quickly, no need to store reference
        _ = initialLoadTask
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - PurchaseService
    
    func loadProducts() async throws -> [SubscriptionProduct] {
        logger.info("Loading products from App Store")
        
        do {
            let storeProducts = try await Product.products(for: ProductID.allCases.map(\.rawValue))
            products = storeProducts
            
            return storeProducts.compactMap { product -> SubscriptionProduct? in
                guard let productID = ProductID(rawValue: product.id) else {
                    logger.error("Unknown product ID: \(product.id)")
                    return nil
                }
                
                return SubscriptionProduct(
                    id: productID,
                    displayName: product.displayName,
                    price: product.price,
                    localizedPrice: product.displayPrice,
                    duration: productID.duration,
                    productInfo: SubscriptionProduct.ProductInfo(
                        description: product.description,
                        introOffer: product.subscription?.introductoryOffer?.displayPrice
                    )
                )
            }
        } catch {
            logger.error("Failed to load products: \(error.localizedDescription)")
            throw PurchaseError.networkError
        }
    }
    
    func purchase(_ productID: ProductID) async throws {
        guard let product = products.first(where: { $0.id == productID.rawValue }) else {
            logger.error("Product not found: \(productID.rawValue)")
            throw PurchaseError.productNotFound
        }
        
        logger.info("Purchasing product: \(productID.rawValue)")
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Verify transaction
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    logger.info("Purchase successful: \(productID.rawValue)")
                    await updateEntitlements()
                case .unverified(_, let error):
                    logger.error("Transaction unverified: \(error.localizedDescription)")
                    throw PurchaseError.receiptValidationFailed
                }
            case .userCancelled:
                logger.info("Purchase cancelled by user")
                throw PurchaseError.purchaseCancelled
            case .pending:
                logger.info("Purchase pending approval")
                // Could show UI for this case
                await updateEntitlements()
            @unknown default:
                logger.error("Unknown purchase result")
                throw PurchaseError.unknown(NSError(domain: "PurchaseService", code: -1))
            }
        } catch let error as PurchaseError {
            throw error
        } catch {
            logger.error("Purchase failed: \(error.localizedDescription)")
            throw PurchaseError.unknown(error)
        }
    }
    
    func restorePurchases() async throws {
        logger.info("Restoring purchases")
        
        try await AppStore.sync()
        await updateEntitlements()
    }
    
    func hasAccess(to feature: PremiumFeature) -> Bool {
        guard currentEntitlements.isPremium else { return false }
        
        switch feature {
        case .unlimitedPages:
            return true
        case .cloudSync:
            return currentEntitlements.cloudSyncEnabled
        }
    }
    
    func entitlementUpdates() -> AsyncStream<SubscriptionEntitlements> {
        AsyncStream { continuation in
            let token = UUID()
            observers[token] = continuation
            continuation.yield(currentEntitlements)
            
            continuation.onTermination = { _ in
                Task { await self.removeObserver(token) }
            }
        }
    }
    
    // MARK: - Private
    
    /// Listen for transaction updates from the system
    private func listenForTransactionUpdates() async {
        for await result in Transaction.updates {
            logger.info("Received transaction update")
            
            switch result {
            case .verified(let transaction):
                await transaction.finish()
                await updateEntitlements()
            case .unverified(_, let error):
                logger.error("Transaction unverified: \(error.localizedDescription)")
            }
        }
    }
    
    /// Update entitlements based on current subscription status
    private func updateEntitlements() async {
        let newEntitlements = await checkSubscriptionStatus()
        
        if newEntitlements != currentEntitlements {
            currentEntitlements = newEntitlements
            notifyObservers()
            logger.info("Entitlements updated: premium=\(newEntitlements.isPremium)")
        }
    }
    
    /// Check current subscription status from App Store
    private func checkSubscriptionStatus() async -> SubscriptionEntitlements {
        // Check for active subscriptions
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if let productID = ProductID(rawValue: transaction.productID),
                   let expirationDate = transaction.expirationDate {
                    logger.info("Found active subscription: \(productID.rawValue)")
                    return SubscriptionEntitlements.premium(
                        expiresAt: expirationDate,
                        productID: productID
                    )
                }
            case .unverified(_, let error):
                logger.error("Unverified entitlement: \(error.localizedDescription)")
            }
        }
        
        // No active subscription found
        return .free
    }
    
    private func notifyObservers() {
        observers.values.forEach { $0.yield(currentEntitlements) }
    }
    
    private func removeObserver(_ token: UUID) {
        observers.removeValue(forKey: token)
    }
}

