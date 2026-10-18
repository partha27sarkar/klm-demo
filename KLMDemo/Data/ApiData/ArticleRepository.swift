//
//  ArticleRepository.swift
//  KLMDemo
//
//  Created by Partha Sarkar on 15/10/2026.
//

import Foundation

final class ArticleRepository: ArticleRepositoryProtocol {
    private let store: SwiftDataArticleStore
    let httpClient: HTTPClient

    init(
        httpClient: HTTPClient,
        store: SwiftDataArticleStore
    ) {
        self.httpClient = httpClient
        self.store = store
    }

    func setFavorite(_ favorite: Bool, for articleID: Int) throws {
        try store.setFeatured(favorite, for: articleID)
    }

    func fetchArticles() async throws -> [Article] {
        do {
            let response = try await httpClient.get(
                ArticleListResponseDTO.self,
                from: URL.articleURL(
                    path: "articles",
                    queryItems: [URLQueryItem(name: "format", value: "json")]
                ),
                headers: [:]
            )
            let articles = response.results.map { $0.mappingDomainModel() }

            try store.replaceArticles(with: articles)

            // Return SwiftData's merged records so locally stored values such as
            // favorites win over API defaults.
            return try store.fetchArticles()
        } catch {
            let cachedArticles = try store.fetchArticles()

            if cachedArticles.isEmpty {
                throw error
            }

            return cachedArticles
        }
    }
}
