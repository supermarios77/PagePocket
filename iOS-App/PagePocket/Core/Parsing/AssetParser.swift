import Foundation

enum AssetType {
    case image
    case stylesheet
}

struct AssetReference: Hashable {
    let original: String   // As found in HTML/CSS
    let absoluteURL: URL?  // Resolved with baseURL if possible
    let type: AssetType
}

struct AssetParser {
    func extractAssets(from htmlData: Data, baseURL: URL?) -> [AssetReference] {
        guard let html = String(data: htmlData, encoding: .utf8) ?? String(data: htmlData, encoding: .isoLatin1) else {
            return []
        }
        var results: Set<AssetReference> = []

        // <img ... src="...">
        results.formUnion(extract(from: html, pattern: #"<img[^>]*?src=[\"']([^\"'>\s]+)[\"']"#, type: .image, baseURL: baseURL))

        // <link rel="stylesheet" href="...">
        results.formUnion(extract(from: html, pattern: #"<link[^>]*?rel=[\"']stylesheet[\"'][^>]*?href=[\"']([^\"'>\s]+)[\"']"#, type: .stylesheet, baseURL: baseURL))

        // url(...) in inline styles or CSS blocks embedded in HTML
        results.formUnion(extract(from: html, pattern: #"url\((?:\s*['\"]?)([^)'\"]+)(?:['\"]?\s*)\)"#, type: .image, baseURL: baseURL))

        return Array(results)
    }

    private func extract(from text: String, pattern: String, type: AssetType, baseURL: URL?) -> Set<AssetReference> {
        var found: Set<AssetReference> = []
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return found }
        let ns = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: ns.length))
        for match in matches {
            guard match.numberOfRanges >= 2 else { continue }
            let urlString = ns.substring(with: match.range(at: 1))
            guard !urlString.lowercased().hasPrefix("data:") else { continue }
            let absolute = resolve(urlString: urlString, baseURL: baseURL)
            found.insert(AssetReference(original: urlString, absoluteURL: absolute, type: type))
        }
        return found
    }

    private func resolve(urlString: String, baseURL: URL?) -> URL? {
        if let url = URL(string: urlString), url.scheme != nil { return url }
        guard let baseURL else { return nil }
        return URL(string: urlString, relativeTo: baseURL)?.absoluteURL
    }
}


