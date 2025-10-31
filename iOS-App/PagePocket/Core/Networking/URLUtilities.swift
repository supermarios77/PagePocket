import Foundation

enum URLUtilities {
    static func normalizedURL(from input: String) -> URL? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if let url = URL(string: trimmed), url.scheme != nil { return url }

        if let withScheme = URL(string: "https://" + trimmed) { return withScheme }
        return nil
    }

    static func isLikelyWebURL(_ input: String) -> Bool {
        guard let url = normalizedURL(from: input) else { return false }
        if let scheme = url.scheme?.lowercased(), ["http", "https"].contains(scheme) { return true }
        return false
    }
}


