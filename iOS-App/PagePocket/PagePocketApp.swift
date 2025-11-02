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
            OnboardingView(viewModel: onboardingViewModel ?? OnboardingViewModel())
                .onAppear {
                    onboardingViewModel = OnboardingViewModel()
                    onboardingViewModel?.onComplete = {
                        showOnboarding = false
                    }
                }
        } else {
            RootView(viewModel: RootViewModel(appEnvironment: appEnvironment))
        }
    }
}
