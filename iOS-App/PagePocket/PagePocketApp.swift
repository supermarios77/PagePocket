//
//  PagePocketApp.swift
//  PagePocket
//
//  Created by mario on 30/10/2025.
//

import SwiftUI
import SwiftData

@main
struct PagePocketApp: App {
    @StateObject private var appEnvironment = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            RootView(viewModel: RootViewModel(appEnvironment: appEnvironment))
                .modelContainer(appEnvironment.modelContainer)
        }
    }
}
