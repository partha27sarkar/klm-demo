//
//  HTTPError.swift
//  KLMDemo
//
//  Created by Partha Sarkar on 15/10/2026.
//

import Foundation

enum HTTPError: LocalizedError {
    case invalidResponse
    case statusCode(Int)
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned an invalid response."
        case .statusCode(let code):
            return "The server returned HTTP \(code)."
        case .decodingFailed:
            return "The server response could not be decoded."
        }
    }
}
