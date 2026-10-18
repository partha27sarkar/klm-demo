import Foundation
import Observation

@MainActor
@Observable
final class ArticlesViewModel {
    private let fetchArticlesRequest: FetchArticlesRequest

    private(set) var state: ArticleListState = .idle
    private(set) var visibleArticles: [Article] = []

    var articles: [Article] {
        guard case let .loaded(articles) = state else {
            return []
        }

        return articles
    }

    var searchText = "" {
        didSet {
            updateVisibleArticles()
        }
    }

    var showsFavoritesOnly = false {
        didSet {
            updateVisibleArticles()
        }
    }

    init(fetchArticlesRequest: FetchArticlesRequest) {
        self.fetchArticlesRequest = fetchArticlesRequest
    }

    func loadArticles() async {
        guard !isLoading else { return }

        state = .loading

        do {
            let articles = try await fetchArticlesRequest.execute()
            state = .loaded(articles)
            updateVisibleArticles(from: articles)
        } catch {
            state = .failed(ArticleListError.from(error))
            visibleArticles = []
        }
    }

    func retry() async {
        await loadArticles()
    }

    func toggleFavorite(for articleID: Article.ID) {
        guard case var .loaded(articles) = state,
              let index = articles.firstIndex(where: { $0.id == articleID }) else {
            return
        }

        let favorite = !articles[index].favorite

        do {
            try fetchArticlesRequest.setFavorite(favorite, for: articleID)
            articles[index].favorite = favorite
            state = .loaded(articles)
            updateVisibleArticles(from: articles)
        } catch {
            // Keep the current UI state when local persistence cannot be updated.
        }
    }

    private var isLoading: Bool {
        if case .loading = state {
            return true
        }

        return false
    }

    private func updateVisibleArticles(from sourceArticles: [Article]? = nil) {
        let articles: [Article]

        if let sourceArticles {
            articles = sourceArticles
        } else if case let .loaded(loadedArticles) = state {
            articles = loadedArticles
        } else {
            visibleArticles = []
            return
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        visibleArticles = articles.filter { article in
            let matchesSearch = query.isEmpty || [
                article.title,
                article.authors.joined(separator: " "),
                article.newsSite,
                article.summary
            ].contains { $0.localizedCaseInsensitiveContains(query) }

            return matchesSearch && (!showsFavoritesOnly || article.favorite)
        }
    }
}
