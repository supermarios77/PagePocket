import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @State private var showClearCacheConfirmation = false
    @Environment(\.dismiss) private var dismiss

    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            premiumSection
            
            Section {
                ThemePicker(selection: viewModel.theme)
            } header: {
                Text(String(localized: "settings.section.general.title"))
            }

            Section {
                Toggle(String(localized: "settings.section.downloads.autoDownload"), isOn: $viewModel.autoDownload)
                Toggle(String(localized: "settings.section.downloads.downloadOverWiFi"), isOn: $viewModel.downloadOverWiFi)
            } header: {
                Text(String(localized: "settings.section.downloads.title"))
            }

            Section {
                Button(role: .destructive, action: {
                    showClearCacheConfirmation = true
                }) {
                    Label(String(localized: "settings.section.privacy.clearCache"), systemImage: "trash")
                }
            } header: {
                Text(String(localized: "settings.section.privacy.title"))
            } footer: {
                Text(String(localized: "settings.section.privacy.clearCache.description"))
            }

            Section {
                HStack {
                    Text(String(localized: "settings.section.about.version"))
                    Spacer()
                    Text(viewModel.appVersion)
                        .foregroundStyle(.secondary)
                }

                Link(String(localized: "settings.section.about.feedback"), destination: viewModel.feedbackURL)
            } header: {
                Text(String(localized: "settings.section.about.title"))
            }
        }
        .navigationTitle(String(localized: "settings.navigation.title"))
        .confirmationDialog(
            String(localized: "settings.action.clearCache"),
            isPresented: $showClearCacheConfirmation,
            titleVisibility: .visible
        ) {
            Button(String(localized: "settings.action.clearCache"), role: .destructive) {
                Task {
                    await viewModel.clearCache()
                }
            }
            Button(String(localized: "settings.action.cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "settings.section.privacy.clearCache.description"))
        }
        .alert(item: Binding(
            get: { viewModel.cacheFeedback },
            set: { viewModel.cacheFeedback = $0 }
        )) { feedback in
            Alert(
                title: Text(feedback.kind == .success 
                    ? String(localized: "settings.action.clearCache.success")
                    : String(localized: "settings.action.clearCache.failed")),
                dismissButton: .default(Text(String(localized: "common.ok"))) {
                    viewModel.cacheFeedback = nil
                }
            )
        }
        .alert(item: Binding(
            get: { viewModel.syncFeedback },
            set: { viewModel.syncFeedback = $0 }
        )) { feedback in
            Alert(
                title: Text(feedback.kind == .success 
                    ? String(localized: "settings.action.sync.success")
                    : String(localized: "settings.action.sync.failed")),
                dismissButton: .default(Text(String(localized: "common.ok"))) {
                    viewModel.syncFeedback = nil
                }
            )
        }
    }
    
    private var premiumSection: some View {
        Section {
            HStack {
                Image(systemName: viewModel.isPremium ? "crown.fill" : "crown")
                    .foregroundStyle(viewModel.isPremium ? Color.orange : Color.gray)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "settings.section.premium.status"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text(viewModel.isPremium 
                        ? String(localized: "settings.section.premium.status.active")
                        : String(localized: "settings.section.premium.status.free"))
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                if !viewModel.isPremium {
                    Text("Upgrade")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.primaryGradient)
                        .clipShape(Capsule())
                }
            }
            
            if viewModel.isPremium {
                Divider()
                
                Button(action: {
                    Task {
                        await viewModel.syncNow()
                    }
                }) {
                    HStack {
                        Image(systemName: "icloud.and.arrow.up")
                            .foregroundStyle(Color.accentColor)
                        
                        if viewModel.isSyncing {
                            ProgressView()
                                .controlSize(.small)
                        }
                        
                        Text(String(localized: "settings.section.premium.syncNow"))
                            .foregroundStyle(.primary)
                        
                        Spacer()
                    }
                }
                .disabled(viewModel.isSyncing)
            }
        } header: {
            Text(String(localized: "settings.section.premium.title"))
        } footer: {
            if viewModel.isPremium {
                Text(String(localized: "settings.section.premium.cloudSync"))
                    .font(.caption)
            }
        }
    }
}

private struct ThemePicker: View {
    @Binding var selection: AppEnvironment.ThemePreference

    var body: some View {
        Picker(String(localized: "settings.section.general.appTheme"), selection: $selection) {
            Text(String(localized: "settings.section.general.appTheme.system")).tag(AppEnvironment.ThemePreference.system)
            Text(String(localized: "settings.section.general.appTheme.light")).tag(AppEnvironment.ThemePreference.light)
            Text(String(localized: "settings.section.general.appTheme.dark")).tag(AppEnvironment.ThemePreference.dark)
        }
        .tint(.accentColor)
    }
}

#Preview {
    @Previewable @State var theme = AppEnvironment.ThemePreference.system
    NavigationStack {
        SettingsView(viewModel: SettingsViewModel(theme: $theme, purchaseService: MockPurchaseService(), cloudSyncService: MockCloudSyncService()))
    }
}

