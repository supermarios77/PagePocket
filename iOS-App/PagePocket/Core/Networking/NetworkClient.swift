//
//  NetworkClient.swift
//  PagePocket
//


import Foundation

protocol NetworkClient {
    func fetchData(from url: URL) async throws -> Data
}

enum NetworkClientError: Error {
    case invalidStatusCode(Int)
}

struct URLSessionNetworkClient: NetworkClient {
    private let session: URLSession

    init(session: URLSession? = nil) {
        if let session = session {
            self.session = session
        } else {
            // Configure URLSession with production-ready settings
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 30.0
            configuration.timeoutIntervalForResource = 60.0
            configuration.waitsForConnectivity = true
            configuration.httpMaximumConnectionsPerHost = 3
            self.session = URLSession(configuration: configuration)
        }
    }

    func fetchData(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        if let httpResponse = response as? HTTPURLResponse,
           !(200..<300).contains(httpResponse.statusCode) {
            throw NetworkClientError.invalidStatusCode(httpResponse.statusCode)
        }
        return data
    }
}

struct StubNetworkClient: NetworkClient {
    func fetchData(from url: URL) async throws -> Data {
        Data()
    }
}

