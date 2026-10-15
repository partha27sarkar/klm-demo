//
//  URL+Query.swift
//  KLMDemo
//
//  Created by Partha Sarkar on 15/10/2026.
//

import Foundation

extension URL {
    static func articleURL(
        path: String,
        queryItems: [URLQueryItem] = []
    ) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.spaceflightnewsapi.net"
        components.path = "/v4/\(path)"
        components.queryItems = queryItems

        guard let url = components.url else {
            preconditionFailure("Unable to construct the article API URL.")
        }

        return url
    }
}
