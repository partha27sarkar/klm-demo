//
//  ArticlesViewModel.swift
//  KLMDemo
//
//  Created by Partha Sarkar on 15/10/2026.
//

import Foundation
import Observation

@Observable
final class ArticlesViewModel {
    private let fetchArticlesRequest: FetchArticlesRequest

    private(set) var state: ArticleListState = .idle

    init(fetchArticlesRequest: FetchArticlesRequest) {
        self.fetchArticlesRequest = fetchArticlesRequest
    }

    func loadArticles() async {
        guard !isLoading else { return }

        state = .loading

        do {
            let articles = try await fetchArticlesRequest.execute()
            state = .loaded(articles)
        } catch {
            state = .failed(ArticleListError.from(error))
        }
    }

    func retry() async {
        await loadArticles()
    }

    private var isLoading: Bool {
        if case .loading = state {
            return true
        }

        return false
    }

}
