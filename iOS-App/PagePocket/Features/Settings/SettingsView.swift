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
            Section {
                ThemePicker(selection: $viewModel.theme)
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
    }
}

#Preview {
    @Previewable @State var theme = AppEnvironment.ThemePreference.system
    NavigationStack {
        SettingsView(viewModel: SettingsViewModel(theme: $theme))
    }
}

