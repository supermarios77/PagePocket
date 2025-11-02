import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel: OnboardingViewModel
    let offlineReaderService: OfflineReaderService
    @State private var currentPage = 0
    
    init(viewModel: OnboardingViewModel, offlineReaderService: OfflineReaderService) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.offlineReaderService = offlineReaderService
    }
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [
                    Color.accentColor.opacity(0.1),
                    Color(.systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(Array(viewModel.pages.enumerated()), id: \.offset) { index, page in
                        if index == 1 {
                            InteractiveTryItPageView(offlineReaderService: offlineReaderService)
                                .tag(index)
                        } else {
                            OnboardingPageView(page: page, index: index)
                                .tag(index)
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                VStack(spacing: 16) {
                    if currentPage < viewModel.pages.count - 1 {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage += 1
                            }
                        }) {
                            Text(String(localized: "onboarding.next"))
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.primaryGradient)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: Color.accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    } else {
                        Button(action: {
                            withAnimation {
                                viewModel.completeOnboarding()
                            }
                        }) {
                            Text(String(localized: "onboarding.getStarted"))
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.primaryGradient)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: Color.accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
    }
}

private struct OnboardingPageView: View {
    let page: OnboardingViewModel.Page
    let index: Int
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Group {
                if index == 1 {
                    // Special interactive demo for "how to" page
                    HowToDemoView(isAnimating: $isAnimating)
                        .padding(.bottom, 20)
                } else {
                    // Standard icon with gradient
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.accentColor.opacity(0.2),
                                        Color.accentColor.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 180, height: 180)
                        
                        Image(systemName: page.iconName)
                            .font(.system(size: 80, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.accentColor, Color.accentColor.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .padding(.bottom, 20)
                }
            }
            
            VStack(spacing: 20) {
                Text(page.title)
                    .font(.system(size: 34, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                
                Text(page.description)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .padding(.horizontal, 40)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.vertical, 40)
        .padding(.horizontal, 20)
        .onAppear {
            if index == 1 {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
        }
    }
}

private struct HowToDemoView: View {
    @Binding var isAnimating: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Browser icon with URL
            VStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 140, height: 100)
                    .overlay(
                        VStack(spacing: 6) {
                            Image(systemName: "safari")
                                .font(.system(size: 32))
                                .foregroundStyle(Color.accentColor)
                            Text("example.com")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    )
                
                // Arrow
                Image(systemName: "arrow.down")
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
                    .symbolEffect(.bounce.up, value: isAnimating)
                
                // Downloaded icon
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 120, height: 80)
                    .overlay(
                        Image(systemName: "doc.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.accentColor)
                            .symbolEffect(.pulse, value: isAnimating)
                    )
            }
        }
    }
}

private struct InteractiveTryItPageView: View {
    let offlineReaderService: OfflineReaderService
    @State private var urlText = ""
    @State private var isSaving = false
    @State private var showSuccess = false
    @State private var showError = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Text(String(localized: "onboarding.howto.title"))
                    .font(.system(size: 34, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                
                Text(String(localized: "onboarding.howto.description"))
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .padding(.horizontal, 20)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "link")
                        .foregroundStyle(.secondary)
                    
                    TextField(String(localized: "onboarding.howto.placeholder"), text: $urlText)
                        .textFieldStyle(.plain)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .keyboardType(.URL)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )
                
                Button(action: {
                    Task {
                        await saveURL()
                    }
                }) {
                    if isSaving {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text(String(localized: "onboarding.howto.action"))
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(AppTheme.primaryGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
                .disabled(urlText.isEmpty || isSaving)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.vertical, 40)
        .alert(isPresented: $showSuccess) {
            Alert(
                title: Text("✓"),
                message: Text(String(localized: "onboarding.howto.success")),
                dismissButton: .default(Text(String(localized: "common.ok")))
            )
        }
        .alert(String(localized: "onboarding.howto.error"), isPresented: $showError) {
            Button(String(localized: "common.ok")) { showError = false }
        }
    }
    
    private func saveURL() async {
        guard let url = normalizeURL(from: urlText) else {
            showError = true
            return
        }
        
        isSaving = true
        do {
            _ = try await offlineReaderService.savePage(from: url)
            showSuccess = true
            urlText = ""
        } catch {
            showError = true
        }
        isSaving = false
    }
    
    private func normalizeURL(from text: String) -> URL? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        
        if let url = URL(string: trimmed), url.scheme != nil {
            guard ["http", "https"].contains(url.scheme?.lowercased()) else {
                return nil
            }
            return url
        }
        
        let prefixed = "https://" + trimmed
        return URL(string: prefixed)
    }
}

#Preview {
    OnboardingView(viewModel: OnboardingViewModel(), offlineReaderService: StubOfflineReaderService())
}

