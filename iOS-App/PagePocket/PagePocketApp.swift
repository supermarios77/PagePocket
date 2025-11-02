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
            ContentView()
                .modelContainer(appEnvironment.modelContainer)
                .environmentObject(appEnvironment)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @State private var showOnboarding = !OnboardingViewModel.hasCompletedOnboarding
    @State private var onboardingViewModel: OnboardingViewModel?

    var body: some View {
        if showOnboarding {
            if let viewModel = onboardingViewModel {
                OnboardingView(
                    viewModel: viewModel,
                    offlineReaderService: appEnvironment.offlineReaderService
                )
            }
        } else {
            RootView(viewModel: RootViewModel(appEnvironment: appEnvironment))
        }
    }
    .onAppear {
        if onboardingViewModel == nil {
            let viewModel = OnboardingViewModel()
            viewModel.onComplete = {
                showOnboarding = false
            }
            onboardingViewModel = viewModel
        }
    }
}
