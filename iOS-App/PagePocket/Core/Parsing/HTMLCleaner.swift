import Foundation

struct HTMLCleaner {
    func clean(_ data: Data) -> Data {
        guard var html = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) else {
            return data
        }

        // Remove inline <script>...</script>
        html = html.replacingOccurrences(of: #"<script[\s\S]*?</script>"#, with: "", options: [.regularExpression, .caseInsensitive])
        // Remove <iframe ...></iframe>
        html = html.replacingOccurrences(of: #"<iframe[\s\S]*?</iframe>"#, with: "", options: [.regularExpression, .caseInsensitive])
        // Remove elements with common ad-like ids/classes (very naive)
        let adLikePatterns = [
            #"<[^>]*?(id|class)=[\"'][^\"']*(ad|ads|advert|banner|cookie|gdpr|popup)[^\"']*[\"'][^>]*?>[\s\S]*?</[^>]+>"#
        ]
        for pattern in adLikePatterns {
            html = html.replacingOccurrences(of: pattern, with: "", options: [.regularExpression, .caseInsensitive])
        }

        return Data(html.utf8)
    }
}


