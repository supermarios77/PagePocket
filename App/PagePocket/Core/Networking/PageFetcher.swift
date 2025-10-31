import Foundation

enum PageFetcherError: Error {
    case invalidStatusCode(Int)
    case unsupportedMIME(String?)
}

struct PageFetcher {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchHTML(from url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else { return data }
        guard (200...299).contains(http.statusCode) else {
            throw PageFetcherError.invalidStatusCode(http.statusCode)
        }

        if let contentType = http.value(forHTTPHeaderField: "Content-Type")?.lowercased() {
            // Allow text/html or unspecified; reject clearly non-HTML (like binary)
            if !(contentType.contains("text/html") || contentType.contains("application/xhtml+xml")) {
                // Some servers return charset only or odd values; be permissive but safe
                if !contentType.contains("text/") && !contentType.contains("application/xml") {
                    throw PageFetcherError.unsupportedMIME(contentType)
                }
            }
        }
        return data
    }
}


