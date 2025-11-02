//
//  PaywallViewModel.swift
//  PagePocket
//

import Combine
import Foundation

@MainActor
final class PaywallViewModel: ObservableObject {
    struct ProductCard: Identifiable, Equatable {
        let id: ProductID
        let displayName: String
        let localizedPrice: String
        let duration: SubscriptionDuration
        let isRecommended: Bool
    }
    
    struct PurchaseResult: Identifiable, Equatable {
        enum Kind: Equatable {
            case success
            case failure(message: String)
            case cancelled
        }
        
        let id = UUID()
        let kind: Kind
    }
    
    @Published private(set) var products: [ProductCard] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isPurchasing = false
    @Published var purchaseResult: PurchaseResult?
    @Published var showRestoreAlert = false
    
    private let purchaseService: PurchaseService
    private var cancellables: Set<AnyCancellable> = []
    private var loadTask: Task<Void, Never>?
    
    init(purchaseService: PurchaseService) {
        self.purchaseService = purchaseService
    }
    
    func loadProducts() {
        guard loadTask == nil else { return }
        
        isLoading = true
        loadTask = Task { [weak self] in
            guard let self else { return }
            do {
                let loadedProducts = try await purchaseService.loadProducts()
                await MainActor.run {
                    self.products = loadedProducts.map { product in
                        ProductCard(
                            id: product.id,
                            displayName: product.displayName,
                            localizedPrice: product.localizedPrice,
                            duration: product.duration,
                            isRecommended: product.duration.isBestValue
                        )
                    }
                    self.isLoading = false
                    self.loadTask = nil
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.loadTask = nil
                }
            }
        }
    }
    
    func purchase(_ productID: ProductID) {
        guard !isPurchasing else { return }
        
        isPurchasing = true
        purchaseResult = nil
        
        Task { [weak self] in
            guard let self else { return }
            do {
                try await purchaseService.purchase(productID)
                await MainActor.run {
                    self.isPurchasing = false
                    self.purchaseResult = PurchaseResult(kind: .success)
                }
            } catch let error as PurchaseError {
                await MainActor.run {
                    self.isPurchasing = false
                    switch error {
                    case .purchaseCancelled:
                        self.purchaseResult = PurchaseResult(kind: .cancelled)
                    default:
                        self.purchaseResult = PurchaseResult(kind: .failure(message: error.localizedDescription))
                    }
                }
            } catch {
                await MainActor.run {
                    self.isPurchasing = false
                    self.purchaseResult = PurchaseResult(kind: .failure(message: error.localizedDescription))
                }
            }
        }
    }
    
    func restorePurchases() {
        guard !isPurchasing else { return }
        
        isPurchasing = true
        purchaseResult = nil
        
        Task { [weak self] in
            guard let self else { return }
            do {
                try await purchaseService.restorePurchases()
                await MainActor.run {
                    self.isPurchasing = false
                    self.purchaseResult = PurchaseResult(kind: .success)
                    self.showRestoreAlert = true
                }
            } catch {
                await MainActor.run {
                    self.isPurchasing = false
                    self.purchaseResult = PurchaseResult(kind: .failure(message: error.localizedDescription))
                }
            }
        }
    }
    
    func dismissResult() {
        purchaseResult = nil
    }
    
    deinit {
        loadTask?.cancel()
    }
}

