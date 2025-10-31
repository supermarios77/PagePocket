//
//  ContentView.swift
//  PagePocket
//
//  Created by mario on 30/10/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var showAdd: Bool = false
    var body: some View {
        SavedPagesListView()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                NavigationView {
                    AddPageView()
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Close") { showAdd = false }
                            }
                        }
                }
            }
    }
}

#Preview {
    ContentView()
}
