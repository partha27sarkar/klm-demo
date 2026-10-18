import Testing
@testable import KLMDemo

@MainActor
struct FetchArticlesRequestTests {
    @Test
    func `Execute asynchronously returns the mock feed`() async throws {
        let repository = try TestFixture.repository(data: TestFixture.mockData())
        let request = FetchArticlesRequest(repository: repository)

        #expect(try await request.execute() == TestFixture.mockArticles().sorted { $0.id > $1.id })
    }

    @Test
    func `Set favorite persists the preference`() async throws {
        let store = try TestFixture.store()
        let repository = try TestFixture.repository(data: TestFixture.mockData(), store: store)
        let request = FetchArticlesRequest(repository: repository)
        let articles = try await request.execute()
        let articleID = try #require(articles.first?.id)

        try request.setFavorite(true, for: articleID)

        #expect(try store.fetchArticles().first { $0.id == articleID }?.isFavorite == true)
    }
}
