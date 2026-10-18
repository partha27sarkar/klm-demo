import Testing
@testable import KLMDemo

@MainActor
struct ArticleRepositoryTests {
    @Test
    func `Fetch returns the mock feed and caches it`() async throws {
        let store = try TestFixture.store()
        let repository = try TestFixture.repository(
            data: TestFixture.mockData(),
            store: store
        )

        let articles = try await repository.fetchArticles()
        let expected = try TestFixture.mockArticles()

        #expect(articles == expected)
        #expect(try store.fetchArticles() == articles.sorted { $0.id > $1.id })
    }

    @Test
    func `Fetch returns cached articles after an API failure`() async throws {
        let store = try TestFixture.store()
        let cached = TestFixture.article(id: 7)
        try store.save(article: cached)
        let repository = try TestFixture.repository(error: .failed, store: store)

        #expect(try await repository.fetchArticles() == [cached])
    }

    @Test
    func `Fetch rethrows an API failure when cache is empty`() async throws {
        let repository = try TestFixture.repository(error: .failed)

        await #expect(throws: TestError.failed) {
            try await repository.fetchArticles()
        }
    }

    @Test
    func `Favorite delegates to persistent storage`() throws {
        let store = try TestFixture.store()
        try store.save(article: TestFixture.article(id: 4))
        let repository = try TestFixture.repository(store: store)

        try repository.setFavorite(true, for: 4)

        #expect(try store.fetchArticles().first?.isFavorite == true)
    }
}
