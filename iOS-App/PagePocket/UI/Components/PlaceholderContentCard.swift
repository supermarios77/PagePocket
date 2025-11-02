import SwiftUI

struct PlaceholderCard: View {
    private let title: String
    private let description: String
    private let systemImageName: String

    init(
        title: String,
        description: String,
        systemImageName: String
    ) {
        self.title = title
        self.description = description
        self.systemImageName = systemImageName
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: systemImageName)
                .font(.title2)
                .foregroundStyle(.white.opacity(0.9))
                .padding(.bottom, 4)

            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            Text(description)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))

            Spacer(minLength: 0)

            HStack(spacing: 8) {
                Text(String(localized: "placeholder.action.learnMore"))
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
    private let title: String
    private let subtitle: String
    private let status: String?
    private let systemImageName: String

    init(
        title: String,
        subtitle: String,
        status: String? = nil,
        systemImageName: String
    ) {
        self.title = title
        self.subtitle = subtitle
        self.status = status
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
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let status {
                Text(status)
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
        title: "Capture for offline",
        description: "Download a page and keep it in sync",
        systemImageName: "arrow.down.doc"
    )
    .padding()
}

#Preview("Row") {
    PlaceholderListRow(
        title: "Sample Article",
        subtitle: "example.com • 5 min read",
        status: "New",
        systemImageName: "doc.text.magnifyingglass"
    )
    .padding()
}

