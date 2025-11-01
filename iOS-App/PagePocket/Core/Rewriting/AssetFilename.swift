import Foundation

enum AssetFilename {
    static func make(for url: URL) -> String {
        let ext = (url.path as NSString).pathExtension
        let baseComponent = ((url.lastPathComponent as NSString).deletingPathExtension)
        let sanitizedBase = sanitize(baseComponent.isEmpty ? "file" : baseComponent)
        let shortHash = String(url.absoluteString.hashValue.magnitude, radix: 36)

        if ext.isEmpty {
            return "\(sanitizedBase)-\(shortHash)"
        } else {
            return "\(sanitizedBase)-\(shortHash).\(ext)"
        }
    }

    private static func sanitize(_ name: String) -> String {
        let invalid = CharacterSet(charactersIn: "/\\?%*|\"<>:")
        let components = name.components(separatedBy: invalid)
        let joined = components.joined(separator: "-")
        return joined.isEmpty ? "file" : String(joined.prefix(60))
    }
}


