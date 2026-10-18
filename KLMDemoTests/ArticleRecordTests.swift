import Testing
@testable import KLMDemo

@MainActor
struct ArticleRecordTests {
    @Test
    func `Record maps all persisted values to the domain`() {
        let expected = TestFixture.article(id: 42, isFavorite: true)
        let record = ArticleRecord(
            id: expected.id,
            title: expected.title,
            authorNames: expected.authors,
            url: expected.url,
            imageURL: expected.imageURL,
            newsSite: expected.newsSite,
            summary: expected.summary,
            publishedAt: expected.publishedAt,
            updatedAt: expected.updatedAt,
            isFavorite: expected.isFavorite
        )

        #expect(record.toDomain() == expected)
    }
}
