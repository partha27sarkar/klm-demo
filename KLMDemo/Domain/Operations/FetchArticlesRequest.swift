//
//  FetchArticlesRequest.swift
//  KLMDemo
//
//  Created by Partha Sarkar on 15/10/2026.
//

import Foundation

struct FetchArticlesRequest {
    private let repository: ArticleRepository

    init(repository: ArticleRepository) {
        self.repository = repository
    }

    func execute() async throws -> [Article] {
        try await repository.fetchArticles()
    }
}
