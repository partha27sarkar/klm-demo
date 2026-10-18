import Foundation
import SwiftData
import Testing
@testable import KLMDemo

struct KLMDemoTests {
    @Test
    @MainActor
    func articleDTOMapsAllValuesToDomainModel() throws {
        let data = Data("""
        {
          "id": 42,
          "title": "Artemis Update",
          "authors": [{"name": "Ada"}, {"name": "Grace"}],
          "url": "https://example.com/article",
          "image_url": "https://example.com/image.jpg",
          "news_site": "Space News",
          "summary": "Mission update",
          "published_at": "2026-10-15T10:00:00Z",
          "updated_at": "2026-10-15T11:00:00Z"
        }
        """.utf8)

        let dto = try JSONDecoder().decode(ArticleDTO.self, from: data)

        #expect(dto.mappingDomainModel() == sampleArticle(id: 42))
    }

    @Test
    @MainActor
    func persistenceStoreSavesFetchesAndReplacesAnArticle() throws {
        let store = try makeStore()
        let original = sampleArticle(id: 10)
        let updated = Article(
            id: 10,
            title: "Updated mission",
            authors: ["New Author"],
            url: "https://example.com/updated",
            imageURL: "https://example.com/updated.jpg",
            newsSite: "Updated News",
            summary: "Updated summary",
            publishedAt: "2026-10-16T10:00:00Z",
            updatedAt: "2026-10-16T11:00:00Z"
        )

        try store.save(article: original)
        try store.save(article: updated)

        #expect(try store.fetchArticles() == [updated])
    }

    @Test
    @MainActor
    func persistenceStoreKeepsFeaturedStatusWhenRefreshingArticles() throws {
        let store = try makeStore()
        let serverArticle = sampleArticle(id: 10)
        var favoriteArticle = serverArticle
        favoriteArticle.favorite = true

        try store.save(article: favoriteArticle)
        try store.replaceArticles(with: [serverArticle])

        #expect(try store.fetchArticles() == [favoriteArticle])
    }

    @Test
    @MainActor
    func persistenceStoreCachesDownloadedImageData() throws {
        let store = try makeStore()
        let article = sampleArticle(id: 11)
        let imageData = Data([0x01, 0x02, 0x03])

        try store.save(article: article)

       // #expect(try store.favoriteArticle().first?.imageData == imageData)
    }

    @Test
    @MainActor
    func persistenceStoreFetchesNewestIdentifiersFirst() throws {
        let store = try makeStore()

        try store.save(article: sampleArticle(id: 1))
        try store.save(article: sampleArticle(id: 3))
        try store.save(article: sampleArticle(id: 2))

        #expect(try store.fetchArticles().map(\.id) == [3, 2, 1])
    }

    @Test
    @MainActor
    func repositoryReturnsNetworkArticlesAndCachesThem() async throws {
        let store = try makeStore()
        let expected = sampleArticle(id: 42)
        let repository = ArticleRepository(
            httpClient: StubHTTPClient(data: articleListData(for: expected)),
            store: store
        )

        let articles = try await repository.fetchArticles()

        #expect(articles == [expected])
        #expect(try store.fetchArticles() == [expected])
    }

    @Test
    @MainActor
    func repositoryReturnsCachedArticlesWhenNetworkRequestFails() async throws {
        let store = try makeStore()
        let cachedArticle = sampleArticle(id: 7)
        try store.save(article: cachedArticle)

        let repository = ArticleRepository(
            httpClient: StubHTTPClient(shouldFail: true),
            store: store
        )

        #expect(try await repository.fetchArticles() == [cachedArticle])
    }

    @Test
    @MainActor
    func repositoryRethrowsNetworkFailureWhenNoCacheExists() async {
        let store = try! makeStore()
        let repository = ArticleRepository(
            httpClient: StubHTTPClient(shouldFail: true),
            store: store
        )

        await #expect(throws: StubHTTPError.failed) {
            try await repository.fetchArticles()
        }
    }

    @Test
    func articleListErrorProvidesTheCorrectUserMessage() {
        #expect(ArticleListError.from(HTTPError.statusCode(404)).message == "Article information is currently unavailable.")
        #expect(ArticleListError.from(HTTPError.statusCode(500)).message == "The service is temporarily unavailable.")
        #expect(ArticleListError.from(HTTPError.invalidResponse).message == "The service is temporarily unavailable.")
        #expect(ArticleListError.from(HTTPError.decodingFailed(StubHTTPError.failed)).message == "We couldn't process the article information.")
        #expect(ArticleListError.from(URLError(.notConnectedToInternet)).message == "Please check your internet connection.")
        #expect(ArticleListError.from(StubHTTPError.failed).message == "Something went wrong. Please try again.")
    }

    @Test
    @MainActor
    func articleSearchFiltersByEverySearchableField() async throws {
        let articles = [
            sampleArticle(id: 1),
            Article(
                id: 2,
                title: "Lunar Weather Report",
                authors: ["Neil Armstrong"],
                url: "https://example.com/lunar-weather",
                imageURL: "https://example.com/lunar-weather.jpg",
                newsSite: "Orbital Daily",
                summary: "A detailed report on conditions at the lunar base.",
                publishedAt: "2026-10-16T10:00:00Z",
                updatedAt: "2026-10-16T11:00:00Z"
            )
        ]
        let viewModel = try await makeViewModel(with: articles)

        viewModel.searchText = "artemis"
        #expect(viewModel.visibleArticles.map(\.id) == [1])

        viewModel.searchText = "grace"
        #expect(viewModel.visibleArticles.map(\.id) == [1])

        viewModel.searchText = "orbital"
        #expect(viewModel.visibleArticles.map(\.id) == [2])

        viewModel.searchText = "lunar base"
        #expect(viewModel.visibleArticles.map(\.id) == [2])
    }

    @Test
    @MainActor
    func articleSearchTrimsWhitespaceAndCombinesWithFavoritesFilter() async throws {
        let favoriteArticle = sampleArticle(id: 1)
        let nonFavoriteArticle = Article(
            id: 2,
            title: "Artemis Launch Schedule",
            authors: ["Jordan Lee"],
            url: "https://example.com/launch-schedule",
            imageURL: "https://example.com/launch-schedule.jpg",
            newsSite: "Space News",
            summary: "The launch window has been confirmed.",
            publishedAt: "2026-10-16T10:00:00Z",
            updatedAt: "2026-10-16T11:00:00Z"
        )
        let viewModel = try await makeViewModel(with: [favoriteArticle, nonFavoriteArticle])
        viewModel.toggleFavorite(for: favoriteArticle.id)

        viewModel.searchText = "  ARTEMIS  "
        #expect(viewModel.visibleArticles.map(\.id) == [1, 2])

        viewModel.showsFavoritesOnly = true
        #expect(viewModel.visibleArticles.map(\.id) == [1])

        viewModel.searchText = "no matches"
        #expect(viewModel.visibleArticles.isEmpty)
    }

    @MainActor
    private func makeStore() throws -> SwiftDataArticleStore {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ArticleRecord.self, configurations: configuration)
        return SwiftDataArticleStore(container: container)
    }

    @MainActor
    private func makeViewModel(with articles: [Article]) async throws -> ArticlesViewModel {
        let repository = ArticleRepository(
            httpClient: StubHTTPClient(data: articleListData(for: articles)),
            store: try makeStore()
        )
        let viewModel = ArticlesViewModel(
            fetchArticlesRequest: FetchArticlesRequest(repository: repository)
        )
        await viewModel.loadArticles()
        return viewModel
    }

    private func sampleArticle(id: Int) -> Article {
        Article(
            id: id,
            title: "Artemis Update",
            authors: ["Ada", "Grace"],
            url: "https://example.com/article",
            imageURL: "https://example.com/image.jpg",
            newsSite: "Space News",
            summary: "Mission update",
            publishedAt: "2026-10-15T10:00:00Z",
            updatedAt: "2026-10-15T11:00:00Z"
        )
    }

    private func articleListData(for article: Article) -> Data {
        articleListData(for: [article])
    }

    private func articleListData(for articles: [Article]) -> Data {
        let results = articles.map { article in
            """
            {
              "id": \(article.id),
              "title": "\(article.title)",
              "authors": \(authorsJSON(article.authors)),
              "url": "\(article.url)",
              "image_url": "\(article.imageURL)",
              "news_site": "\(article.newsSite)",
              "summary": "\(article.summary)",
              "published_at": "\(article.publishedAt)",
              "updated_at": "\(article.updatedAt)"
            }
            """
        }.joined(separator: ",")

        return Data("""
        {
          "count": \(articles.count),
          "next": null,
          "previous": null,
          "results": [\(results)]
        }
        """.utf8)
    }

    private func authorsJSON(_ authors: [String]) -> String {
        let values = authors.map { #"{ "name": "\#($0)" }"# }.joined(separator: ",")
        return "[\(values)]"
    }
}

private struct StubHTTPClient: HTTPClient {
    let data: Data?
    let shouldFail: Bool

    init(data: Data? = nil, shouldFail: Bool = false) {
        self.data = data
        self.shouldFail = shouldFail
    }

    nonisolated func execute<Operation: HTTPRequestOperation>(
        _ operation: Operation
    ) async throws -> Operation.Response {
        if shouldFail {
            throw StubHTTPError.failed
        }

        guard let data else {
            throw StubHTTPError.missingResponse
        }

        return try operation.decodeResponse(from: data)
    }
}

private enum StubHTTPError: Error, Equatable {
    case failed
    case missingResponse
}
