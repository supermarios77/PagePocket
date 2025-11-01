import SwiftUI

struct SectionHeader: View {
    private let titleKey: LocalizedStringKey
    private let subtitleKey: LocalizedStringKey?

    init(titleKey: LocalizedStringKey, subtitleKey: LocalizedStringKey? = nil) {
        self.titleKey = titleKey
        self.subtitleKey = subtitleKey
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(titleKey)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            if let subtitleKey {
                Text(subtitleKey)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    SectionHeader(
        titleKey: "preview.section.title",
        subtitleKey: "preview.section.subtitle"
    )
    .padding()
}

