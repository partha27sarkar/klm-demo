import Testing
@testable import KLMDemo

@MainActor
struct SwiftDataArticleStoreTests {
    @Test
    func `Save inserts and updates an article`() throws {
        let store = try TestFixture.store()
        let original = TestFixture.article(id: 1)
        let updated = Article(
            id: 1,
            title: "Updated",
            authors: ["Updated Author"],
            url: original.url,
            imageURL: original.imageURL,
            newsSite: original.newsSite,
            summary: "Updated summary",
            publishedAt: original.publishedAt,
            updatedAt: original.updatedAt
        )

        try store.save(article: original)
        try store.save(article: updated)

        #expect(try store.fetchArticles() == [updated])
    }

    @Test
    func `Replace removes stale articles and keeps local favorite state`() throws {
        let store = try TestFixture.store()
        try store.save(article: TestFixture.article(id: 1, isFavorite: true))
        try store.save(article: TestFixture.article(id: 2))

        let refreshed = TestFixture.article(id: 1)
        try store.replaceArticles(with: [refreshed])

        #expect(try store.fetchArticles() == [TestFixture.article(id: 1, isFavorite: true)])
    }

    @Test
    func `Fetch sorts articles by descending identifier`() throws {
        let store = try TestFixture.store()
        try store.replaceArticles(with: [
            TestFixture.article(id: 1),
            TestFixture.article(id: 3),
            TestFixture.article(id: 2)
        ])

        #expect(try store.fetchArticles().map(\.id) == [3, 2, 1])
    }

    @Test
    func `Favorite update changes an existing record and ignores a missing record`() throws {
        let store = try TestFixture.store()
        try store.save(article: TestFixture.article(id: 7))

        try store.setFavoriteLocally(true, for: 7)
        try store.setFavoriteLocally(true, for: 999)

        #expect(try store.fetchArticles().first?.isFavorite == true)
    }

    @Test
    func `Replace accepts an empty feed`() throws {
        let store = try TestFixture.store()
        try store.save(article: TestFixture.article())
        try store.replaceArticles(with: [])

        #expect(try store.fetchArticles().isEmpty)
    }
}
