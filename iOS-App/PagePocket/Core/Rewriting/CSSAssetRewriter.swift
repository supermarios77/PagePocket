import Foundation

struct CSSAssetRewriter {
    func process(cssData: Data, baseURL: URL, assetDirectoryName: String = "assets", mapping: inout [URL: String]) -> (Data, [URL: String]) {
        guard let original = String(data: cssData, encoding: .utf8) ?? String(data: cssData, encoding: .isoLatin1) else {
            return (cssData, [:])
        }

        let mutable = NSMutableString(string: original)
        var discovered: [URL: String] = [:]

        rewriteURLs(in: mutable,
                    pattern: #"url\((?:\s*['"]?)([^)'"\s]+)(?:['"]?\s*)\)"#,
                    captureIndex: 1,
                    assetDirectoryName: assetDirectoryName,
                    baseURL: baseURL,
                    mapping: &mapping,
                    discovered: &discovered)

        rewriteImportStatements(in: mutable,
                                assetDirectoryName: assetDirectoryName,
                                baseURL: baseURL,
                                mapping: &mapping,
                                discovered: &discovered)

        if let data = (mutable as String).data(using: .utf8) {
            return (data, discovered)
        } else {
            return (cssData, discovered)
        }
    }

    private func rewriteURLs(in mutable: NSMutableString,
                              pattern: String,
                              captureIndex: Int,
                              assetDirectoryName: String,
                              baseURL: URL,
                              mapping: inout [URL: String],
                              discovered: inout [URL: String]) {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return }
        let matches = regex.matches(in: mutable as String, options: [], range: NSRange(location: 0, length: mutable.length))

        for match in matches.reversed() {
            guard match.numberOfRanges > captureIndex else { continue }
            let range = match.range(at: captureIndex)
            let urlString = mutable.substring(with: range)
            guard shouldDownloadAsset(from: urlString) else { continue }
            guard let absolute = resolve(urlString: urlString, baseURL: baseURL) else { continue }
            let relative = relativePath(for: absolute,
                                        assetDirectoryName: assetDirectoryName,
                                        mapping: &mapping,
                                        discovered: &discovered)
            mutable.replaceCharacters(in: range, with: relative)
        }
    }

    private func rewriteImportStatements(in mutable: NSMutableString,
                                         assetDirectoryName: String,
                                         baseURL: URL,
                                         mapping: inout [URL: String],
                                         discovered: inout [URL: String]) {
        let pattern = #"@import\s+(?:url\((?:\s*['"]?)([^)'"\s]+)(?:['"]?\s*)\)|['"]([^'"]+)['"])"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return }
        let matches = regex.matches(in: mutable as String, options: [], range: NSRange(location: 0, length: mutable.length))

        for match in matches.reversed() {
            let primaryRange = match.range(at: 1)
            let fallbackRange = match.range(at: 2)
            let chosenRange = primaryRange.location != NSNotFound ? primaryRange : fallbackRange
            guard chosenRange.location != NSNotFound else { continue }
            let urlString = mutable.substring(with: chosenRange)
            guard shouldDownloadAsset(from: urlString) else { continue }
            guard let absolute = resolve(urlString: urlString, baseURL: baseURL) else { continue }
            let relative = relativePath(for: absolute,
                                        assetDirectoryName: assetDirectoryName,
                                        mapping: &mapping,
                                        discovered: &discovered)
            mutable.replaceCharacters(in: chosenRange, with: relative)
        }
    }

    private func relativePath(for absolute: URL,
                               assetDirectoryName: String,
                               mapping: inout [URL: String],
                               discovered: inout [URL: String]) -> String {
        if let existing = mapping[absolute] {
            return existing
        }
        let relative = "\(assetDirectoryName)/\(AssetFilename.make(for: absolute))"
        mapping[absolute] = relative
        discovered[absolute] = relative
        return relative
    }

    private func shouldDownloadAsset(from value: String) -> Bool {
        guard !value.isEmpty else { return false }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("data:") { return false }
        if trimmed.hasPrefix("#") { return false }
        return true
    }

    private func resolve(urlString: String, baseURL: URL) -> URL? {
        if let url = URL(string: urlString), url.scheme != nil {
            return url
        }
        return URL(string: urlString, relativeTo: baseURL)?.absoluteURL
    }
}


