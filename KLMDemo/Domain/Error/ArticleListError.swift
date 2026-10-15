//
//  ArticleListError.swift
//  KLMDemo
//
//  Created by Partha Sarkar on 15/10/2026.
//

import Foundation

enum ArticleListError {
    case network
    case server
    case invalidData
    case unavailable
    case unknown

    var message: String {
        switch self {
        case .network:
            "Please check your internet connection."
        case .server:
            "The service is temporarily unavailable."
        case .invalidData:
            "We couldn't process the article information."
        case .unavailable:
            "Article information is currently unavailable."
        case .unknown:
            "Something went wrong. Please try again."
        }
    }

    static func from(_ error: Error) -> ArticleListError {
        if let httpError = error as? HTTPError {
            switch httpError {
            case .statusCode(401...499):
                return .unavailable
            case .statusCode, .invalidResponse:
                return .server
            case .decodingFailed:
                return .invalidData
            }
        }

        if error is URLError {
            return .network
        }

        return .unknown
    }
}
