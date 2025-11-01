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

    init(session: URLSession = .shared) {
        self.session = session
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

