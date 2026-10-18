//
//  ArticleRepository.swift
//  KLMDemo
//
//  Created by Partha Sarkar on 15/10/2026.
//

import Foundation

/// Retrieves articles from the API and maintains their local SwiftData cache.
final class ArticleRepository: ArticleRepositoryProtocol {
    private let store: SwiftDataArticleStore
    private let httpClient: HTTPClient

    init(
        httpClient: HTTPClient,
        store: SwiftDataArticleStore
    ) {
        self.httpClient = httpClient
        self.store = store
    }

    /// Persists a demo-only favorite preference on the device.
    ///
    /// The Spaceflight News API does not expose a user favourite field, so this
    /// preference intentionally remains local rather than being sent to the API.
    func setFavorite(_ isFavorite: Bool, for articleID: Int) throws {
        try store.setFavoriteLocally(isFavorite, for: articleID)
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

            // Fetch the merged records so local preferences, including
            // `isFavorite`, are retained while API-sourced fields are refreshed.
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
