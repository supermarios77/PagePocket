import SwiftUI

struct PlaceholderCard: View {
    private let titleKey: LocalizedStringKey
    private let descriptionKey: LocalizedStringKey
    private let systemImageName: String

    init(
        titleKey: LocalizedStringKey,
        descriptionKey: LocalizedStringKey,
        systemImageName: String
    ) {
        self.titleKey = titleKey
        self.descriptionKey = descriptionKey
        self.systemImageName = systemImageName
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: systemImageName)
                .font(.title2)
                .foregroundStyle(.white.opacity(0.9))
                .padding(.bottom, 4)

            Text(titleKey)
                .font(.headline)
                .foregroundStyle(.white)

            Text(descriptionKey)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))

            Spacer(minLength: 0)

            HStack(spacing: 8) {
                Text("placeholder.action.learnMore")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white)

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .frame(width: 240, height: 180)
        .background(AppTheme.primaryGradient)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 8)
    }
}

struct PlaceholderListRow: View {
    private let titleKey: LocalizedStringKey
    private let subtitleKey: LocalizedStringKey
    private let statusKey: LocalizedStringKey?
    private let systemImageName: String

    init(
        titleKey: LocalizedStringKey,
        subtitleKey: LocalizedStringKey,
        statusKey: LocalizedStringKey? = nil,
        systemImageName: String
    ) {
        self.titleKey = titleKey
        self.subtitleKey = subtitleKey
        self.statusKey = statusKey
        self.systemImageName = systemImageName
    }

    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.accentColor.opacity(0.1))
                .overlay(
                    Image(systemName: systemImageName)
                        .font(.title3)
                        .foregroundStyle(Color.accentColor)
                )
                .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 4) {
                Text(titleKey)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(subtitleKey)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let statusKey {
                Text(statusKey)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.accentColor.opacity(0.12))
                    .clipShape(Capsule())
                    .foregroundStyle(Color.accentColor)
            }

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 12)
    }
}

#Preview("Card") {
    PlaceholderCard(
        titleKey: "preview.card.title",
        descriptionKey: "preview.card.description",
        systemImageName: "arrow.down.doc"
    )
    .padding()
}

#Preview("Row") {
    PlaceholderListRow(
        titleKey: "preview.row.title",
        subtitleKey: "preview.row.subtitle",
        statusKey: "preview.row.status",
        systemImageName: "doc.text.magnifyingglass"
    )
    .padding()
}

