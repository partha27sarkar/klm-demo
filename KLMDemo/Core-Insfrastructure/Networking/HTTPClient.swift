//
//  HTTPClient.swift
//  KLMDemo
//
//  Created by Partha Sarkar on 15/10/2026.
//

import Foundation

protocol HTTPClient: Sendable {
    func get<T: Decodable>(
        _ type: T.Type,
        from url: URL,
        headers: [String: String]
    ) async throws -> T
}

struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func get<T: Decodable>(
        _ type: T.Type,
        from url: URL,
        headers: [String: String] = [:]
    ) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30

        for (field, value) in headers {
            request.setValue(value, forHTTPHeaderField: field)
        }

        let (data, response) = try await session.data(for: request)

        guard let response = response as? HTTPURLResponse else {
            throw HTTPError.invalidResponse
        }

        guard 200..<300 ~= response.statusCode else {
            throw HTTPError.statusCode(response.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw HTTPError.decodingFailed(error)
        }
    }
}
