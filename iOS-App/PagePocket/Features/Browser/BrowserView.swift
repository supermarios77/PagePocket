//
//  BrowserView.swift
//  PagePocket


import SwiftUI

struct BrowserView: View {
    @StateObject private var viewModel: BrowserViewModel

    init(viewModel: BrowserViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Text("placeholder.browser.message")
    }
}

#Preview {
    BrowserView(viewModel: BrowserViewModel())
}

