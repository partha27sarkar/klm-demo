//
//  FetchArticlesRequest.swift
//  KLMDemo
//
//  Created by Partha Sarkar on 15/10/2026.
//

import Foundation

struct FetchArticlesRequest {
    private let repository: any ArticleRepositoryProtocol

    init(repository: any ArticleRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [Article] {
        try await repository.fetchArticles()
    }
    
    func setFavorite(_ favorite: Bool, for articleID: Int) throws {
        try repository.setFavorite(favorite, for: articleID)
    }
}
