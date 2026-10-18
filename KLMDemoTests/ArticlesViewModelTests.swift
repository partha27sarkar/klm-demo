import Testing
@testable import KLMDemo

@MainActor
struct ArticlesViewModelTests {
    @Test
    func `Load presents the mock feed`() async throws {
        let viewModel = try makeViewModel()

        await viewModel.loadArticles()
        let expected = try TestFixture.mockArticles().sorted { $0.id > $1.id }

        #expect(viewModel.articles == expected)
        #expect(viewModel.visibleArticles == viewModel.articles)
    }

    @Test
    func `Search filters mock feed by title author site and summary`() async throws {
        let viewModel = try makeViewModel()
        await viewModel.loadArticles()

        for query in ["Arianespace", "Chris Bergin", "NASASpaceflight", "tropics"] {
            viewModel.searchText = query
            #expect(!viewModel.visibleArticles.isEmpty)
        }

        viewModel.searchText = "  arianespace  "
        #expect(viewModel.visibleArticles.map(\.id) == [40394])
    }

    @Test
    func `Favorites filter and toggle update the visible list`() async throws {
        let viewModel = try makeViewModel()
        await viewModel.loadArticles()
        let articleID = try #require(viewModel.articles.first?.id)

        viewModel.toggleFavorite(for: articleID)
        viewModel.showsFavoritesOnly = true

        #expect(viewModel.visibleArticles.map(\.id) == [articleID])

        viewModel.toggleFavorite(for: articleID)
        #expect(viewModel.visibleArticles.isEmpty)
    }

    @Test
    func `Unknown favorite identifier leaves the feed unchanged`() async throws {
        let viewModel = try makeViewModel()
        await viewModel.loadArticles()
        let original = viewModel.articles

        viewModel.toggleFavorite(for: -1)

        #expect(viewModel.articles == original)
    }

    @Test
    func `Failure clears articles and retry remains safe`() async throws {
        let repository = try TestFixture.repository(error: .failed)
        let viewModel = ArticlesViewModel(
            fetchArticlesRequest: FetchArticlesRequest(repository: repository)
        )

        await viewModel.loadArticles()
        #expect(viewModel.articles.isEmpty)
        #expect(viewModel.visibleArticles.isEmpty)
        if case let .failed(error) = viewModel.state {
            #expect(error.message == "Something went wrong. Please try again.")
        } else {
            Issue.record("Expected a failed state")
        }

        await viewModel.retry()
        #expect(viewModel.articles.isEmpty)
    }

    private func makeViewModel() throws -> ArticlesViewModel {
        let repository = try TestFixture.repository(data: TestFixture.mockData())
        return ArticlesViewModel(
            fetchArticlesRequest: FetchArticlesRequest(repository: repository)
        )
    }
}
