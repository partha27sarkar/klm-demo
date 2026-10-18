//
//  HTTPClient.swift
//  KLMDemo
//
//  Created by Partha Sarkar on 15/10/2026.
//

import Foundation

protocol HTTPRequestOperation {
    associatedtype Response
    nonisolated var request: URLRequest { get }
    nonisolated func decodeResponse(from data: Data) throws -> Response
}

protocol HTTPClient: Sendable {
    func execute<Operation: HTTPRequestOperation>(_ operation: Operation) async throws -> Operation.Response
}

extension HTTPClient {
    func get<T: Decodable>(
        _ type: T.Type,
        from url: URL,
        headers: [String: String] = [:]
    ) async throws -> T {
        try await execute(JSONGetOperation<T>(url: url, headers: headers))
    }
}

struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func execute<Operation: HTTPRequestOperation>(
        _ operation: Operation
    ) async throws -> Operation.Response {
        let (data, response) = try await session.data(for: operation.request)

        guard let response = response as? HTTPURLResponse else {
            throw HTTPError.invalidResponse
        }

        guard 200..<300 ~= response.statusCode else {
            throw HTTPError.statusCode(response.statusCode)
        }

        return try operation.decodeResponse(from: data)
    }
}

struct JSONGetOperation<Response: Decodable>: HTTPRequestOperation {
    nonisolated let request: URLRequest

    nonisolated init(url: URL, headers: [String: String] = [:]) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30

        for (field, value) in headers {
            request.setValue(value, forHTTPHeaderField: field)
        }

        self.request = request
    }

    nonisolated func decodeResponse(from data: Data) throws -> Response {
        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw HTTPError.decodingFailed(error)
        }
    }
}

struct DataGetOperation: HTTPRequestOperation {
    nonisolated let request: URLRequest

    nonisolated init(url: URL, headers: [String: String] = [:]) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30

        for (field, value) in headers {
            request.setValue(value, forHTTPHeaderField: field)
        }

        self.request = request
    }

    nonisolated func decodeResponse(from data: Data) throws -> Data {
        data
    }
}
