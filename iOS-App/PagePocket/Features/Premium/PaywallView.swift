//
//  PaywallView.swift
//  PagePocket
//

import SwiftUI

struct PaywallView: View {
    @StateObject private var viewModel: PaywallViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: PaywallViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    heroSection
                    
                    featuresSection
                    
                    productsSection
                    
                    footerSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(String(localized: "premium.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common.cancel")) {
                        dismiss()
                    }
                }
            }
            .overlay(alignment: .center) {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .task {
                viewModel.loadProducts()
            }
            .alert(item: Binding(
                get: { viewModel.purchaseResult },
                set: { _ in viewModel.dismissResult() }
            )) { result in
                Alert(
                    title: Text(alertTitle(for: result.kind)),
                    message: Text(alertMessage(for: result.kind)),
                    dismissButton: .default(Text(String(localized: "common.ok"))) {
                        if result.kind == .success {
                            dismiss()
                        }
                    }
                )
            }
        }
    }
    
    // MARK: - Private Views
    
    private var heroSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .yellow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(String(localized: "premium.subtitle"))
                .font(.title2)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(premiumFeatures, id: \.title) { feature in
                HStack(spacing: 16) {
                    Image(systemName: feature.icon)
                        .font(.title2)
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(feature.title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        Text(feature.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    private var productsSection: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.products) { product in
                Button(action: {
                    viewModel.purchase(product.id)
                }) {
                    ProductCardView(product: product, isLoading: viewModel.isPurchasing)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var footerSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                viewModel.restorePurchases()
            }) {
                Text(String(localized: "premium.restore"))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 8) {
                Button(String(localized: "premium.terms")) {
                    // Open terms URL
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
                
                Text("•")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                
                Button(String(localized: "premium.privacy")) {
                    // Open privacy URL
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
        }
    }
    
    private func alertTitle(for kind: PaywallViewModel.PurchaseResult.Kind) -> String {
        switch kind {
        case .success:
            String(localized: "premium.success.title")
        case .failure, .cancelled:
            String(localized: "premium.error.title")
        }
    }
    
    private func alertMessage(for kind: PaywallViewModel.PurchaseResult.Kind) -> String {
        switch kind {
        case .success:
            String(localized: "premium.success.message")
        case .failure(let message):
            message
        case .cancelled:
            String(localized: "premium.error.message")
        }
    }
    
    private let premiumFeatures: [(icon: String, title: String, description: String)] = [
        ("infinity", String(localized: "premium.feature.unlimited.title"), String(localized: "premium.feature.unlimited.description")),
        ("icloud.and.arrow.up", String(localized: "premium.feature.sync.title"), String(localized: "premium.feature.sync.description")),
        ("eye.slash", String(localized: "premium.feature.adfree.title"), String(localized: "premium.feature.adfree.description"))
    ]
}

// MARK: - Product Card View

private struct ProductCardView: View {
    let product: PaywallViewModel.ProductCard
    let isLoading: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(product.displayName)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    if product.isRecommended {
                        Text("BEST VALUE")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor)
                            .clipShape(Capsule())
                    }
                }
                
                Text(product.localizedPrice)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if isLoading {
                ProgressView()
            } else {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(product.isRecommended ? Color.accentColor : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    PaywallView(viewModel: PaywallViewModel(purchaseService: MockPurchaseService()))
}

