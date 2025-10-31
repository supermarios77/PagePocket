import Foundation

struct RewrittenPage {
    let htmlData: Data
    let assetURLToRelativePath: [URL: String]
}

struct AssetRewriter {
    func rewrite(htmlData: Data, baseURL: URL?, assets: [AssetReference], assetDirectoryName: String = "assets") -> RewrittenPage {
        guard var html = String(data: htmlData, encoding: .utf8) ?? String(data: htmlData, encoding: .isoLatin1) else {
            return RewrittenPage(htmlData: htmlData, assetURLToRelativePath: [:])
        }

        // Build stable relative paths for each absolute asset URL
        var mapping: [URL: String] = [:]
        for asset in assets {
            guard let absolute = asset.absoluteURL ?? resolve(urlString: asset.original, baseURL: baseURL) else { continue }
            if mapping[absolute] != nil { continue }
            let filename = suggestedFilename(for: absolute)
            mapping[absolute] = "\(assetDirectoryName)/\(filename)"
        }

        // Replace occurrences in HTML for src/href/url(...)
        if !mapping.isEmpty {
            html = replaceImgSrc(in: html, mapping: mapping, baseURL: baseURL)
            html = replaceStylesheetHref(in: html, mapping: mapping, baseURL: baseURL)
            html = replaceCSSURLs(in: html, mapping: mapping, baseURL: baseURL)
        }

        return RewrittenPage(htmlData: Data(html.utf8), assetURLToRelativePath: mapping)
    }

    // MARK: - Replacement helpers

    private func replaceImgSrc(in html: String, mapping: [URL: String], baseURL: URL?) -> String {
        let pattern = #"(<img[^>]*?src=)[\"']([^\"'>\s]+)[\"']"#
        return replace(html: html, pattern: pattern, groupIndex: 2, mapping: mapping, baseURL: baseURL)
    }

    private func replaceStylesheetHref(in html: String, mapping: [URL: String], baseURL: URL?) -> String {
        let pattern = #"(<link[^>]*?rel=[\"']stylesheet[\"'][^>]*?href=)[\"']([^\"'>\s]+)[\"']"#
        return replace(html: html, pattern: pattern, groupIndex: 2, mapping: mapping, baseURL: baseURL)
    }

    private func replaceCSSURLs(in html: String, mapping: [URL: String], baseURL: URL?) -> String {
        let pattern = #"(url\((?:\s*['\"]?))([^)'\"]+)(?:(['\"]?\s*)\))"#
        return replace(html: html, pattern: pattern, groupIndex: 2, mapping: mapping, baseURL: baseURL)
    }

    private func replace(html: String, pattern: String, groupIndex: Int, mapping: [URL: String], baseURL: URL?) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return html }
        let ns = html as NSString
        var result = html
        var offset = 0
        let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: ns.length))

        for match in matches {
            guard match.numberOfRanges > groupIndex else { continue }
            let range = match.range(at: groupIndex)
            let urlString = ns.substring(with: range)
            guard let absolute = resolve(urlString: urlString, baseURL: baseURL) else { continue }
            guard let relative = mapping[absolute] else { continue }

            if let swiftRange = Range(NSRange(location: range.location + offset, length: range.length), in: result) {
                result.replaceSubrange(swiftRange, with: relative)
                offset += relative.count - range.length
            }
        }
        return result
    }

    // MARK: - Utilities

    private func resolve(urlString: String, baseURL: URL?) -> URL? {
        if let url = URL(string: urlString), url.scheme != nil { return url }
        guard let baseURL else { return nil }
        return URL(string: urlString, relativeTo: baseURL)?.absoluteURL
    }

    private func suggestedFilename(for url: URL) -> String {
        let ext = (url.path as NSString).pathExtension
        let base = ((url.lastPathComponent as NSString).deletingPathExtension)
        let sanitizedBase = sanitizeFilename(base.isEmpty ? "file" : base)
        let shortHash = String(url.absoluteString.hashValue.magnitude, radix: 36)
        if ext.isEmpty {
            return "\(sanitizedBase)-\(shortHash)"
        } else {
            return "\(sanitizedBase)-\(shortHash).\(ext)"
        }
    }

    private func sanitizeFilename(_ name: String) -> String {
        let invalid = CharacterSet(charactersIn: "/\\?%*|\"<>:")
        let components = name.components(separatedBy: invalid)
        let joined = components.joined(separator: "-")
        return joined.isEmpty ? "file" : String(joined.prefix(60))
    }
}


