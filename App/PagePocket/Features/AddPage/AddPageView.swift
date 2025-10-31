import SwiftUI

struct AddPageView: View {
    @StateObject private var viewModel = AddPageViewModel()
    @State private var isCleaned: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add Page")
                .font(.title2)
                .bold()

            HStack(spacing: 8) {
                TextField("Enter URL", text: $viewModel.urlText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .keyboardType(.URL)
                    .textFieldStyle(.roundedBorder)

                Button {
                    Task { await viewModel.save(isCleaned: isCleaned) }
                } label: {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Image(systemName: "tray.and.arrow.down")
                            .accessibilityHidden(true)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isSaving || viewModel.urlText.isEmpty)
                .accessibilityLabel("Save page for offline reading")
            }

            Toggle("Clean up ads/banners (beta)", isOn: $isCleaned)
                .toggleStyle(.switch)
                .accessibilityHint("Removes scripts, iframes, and obvious ad containers before saving")

            if let title = viewModel.lastSavedTitle, !title.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                    Text("Saved: \(title)")
                }
                .font(.subheadline)
                .transition(.opacity)
                .accessibilityLabel("Saved successfully: \(title)")
            }

            if let error = viewModel.errorMessage {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                    Text(error)
                }
                .font(.subheadline)
                .accessibilityLabel("Error: \(error)")
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    AddPageView()
}


