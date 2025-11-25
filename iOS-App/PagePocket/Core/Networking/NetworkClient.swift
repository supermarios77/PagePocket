//
//  NetworkClient.swift
//  PagePocket
//


import Foundation

protocol NetworkClient {
    func fetchData(from url: URL) async throws -> Data
}

enum NetworkClientError: Error, LocalizedError {
    case invalidStatusCode(Int)
    case invalidURL
    case networkUnavailable
    case timeout
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidStatusCode(let code):
            return "Server returned error code \(code)"
        case .invalidURL:
            return "Invalid URL provided"
        case .networkUnavailable:
            return "Network connection unavailable"
        case .timeout:
            return "Request timed out"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

struct URLSessionNetworkClient: NetworkClient {
    private let session: URLSession

    init(session: URLSession? = nil) {
        if let session = session {
            self.session = session
        } else {
            // Configure URLSession with production-ready settings
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = AppConstants.Network.requestTimeout
            configuration.timeoutIntervalForResource = AppConstants.Network.resourceTimeout
            configuration.waitsForConnectivity = true
            configuration.httpMaximumConnectionsPerHost = AppConstants.Network.maxConnectionsPerHost
            self.session = URLSession(configuration: configuration)
        }
    }

    func fetchData(from url: URL) async throws -> Data {
        // Validate URL scheme
        guard let scheme = url.scheme?.lowercased(), ["http", "https"].contains(scheme) else {
            throw NetworkClientError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                guard (200..<300).contains(httpResponse.statusCode) else {
                    throw NetworkClientError.invalidStatusCode(httpResponse.statusCode)
                }
            }
            
            return data
        } catch let error as NetworkClientError {
            throw error
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw NetworkClientError.networkUnavailable
            case .timedOut:
                throw NetworkClientError.timeout
            default:
                throw NetworkClientError.unknown(error)
            }
        } catch {
            throw NetworkClientError.unknown(error)
        }
    }
}

struct StubNetworkClient: NetworkClient {
    func fetchData(from url: URL) async throws -> Data {
        Data()
    }
}

