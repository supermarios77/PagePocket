//
//  NetworkClient.swift
//  PagePocket
//


import Foundation

protocol NetworkClient {
    func fetchData(from url: URL) async throws -> Data
}

struct StubNetworkClient: NetworkClient {
    func fetchData(from url: URL) async throws -> Data {
        Data()
    }
}

