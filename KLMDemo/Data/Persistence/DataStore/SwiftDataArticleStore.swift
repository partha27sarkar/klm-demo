import Foundation
import SwiftData

@MainActor
final class SwiftDataArticleStore {
    private let context: ModelContext

    init(container: ModelContainer) {
        context = ModelContext(container)
    }

    func fetchArticles() throws -> [Article] {
        let descriptor = FetchDescriptor<ArticleRecord>(
            sortBy: [SortDescriptor(\.id, order: .reverse)]
        )

        return try context.fetch(descriptor).map { $0.toDomain() }
    }

    func replaceArticles(with articles: [Article]) throws {
        let existingRecords = try context.fetch(FetchDescriptor<ArticleRecord>())
        let recordsByID = Dictionary(uniqueKeysWithValues: existingRecords.map { ($0.id, $0) })
        let incomingIDs = Set(articles.map(\.id))

        for record in existingRecords where !incomingIDs.contains(record.id) {
            context.delete(record)
        }

        for article in articles {
            if let existingRecord = recordsByID[article.id] {
                existingRecord.update(from: article)
            } else {
                context.insert(ArticleRecord(article))
            }
        }

        try context.save()
    }

    func save(article: Article) throws {
        let articleID = article.id
        var descriptor = FetchDescriptor<ArticleRecord>(
            predicate: #Predicate { $0.id == articleID }
        )
        descriptor.fetchLimit = 1

        let existing = try context.fetch(descriptor).first
        updateAndInsert(article, existingRecord: existing)

        try context.save()
    }

    func setFeatured(_ featured: Bool, for articleID: Int) throws {
        guard let record = try record(for: articleID) else { return }
        record.favorite = featured
        try context.save()
    }

    private func record(for articleID: Int) throws -> ArticleRecord? {
        var descriptor = FetchDescriptor<ArticleRecord>(
            predicate: #Predicate { $0.id == articleID }
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    private func updateAndInsert(_ article: Article, existingRecord: ArticleRecord?) {
        if let existingRecord {
            existingRecord.update(from: article)
        } else {
            context.insert(ArticleRecord(article))
        }
    }
}

private extension ArticleRecord {
    convenience init(_ article: Article) {
        self.init(
            id: article.id,
            title: article.title,
            authorNames: article.authors,
            url: article.url,
            imageURL: article.imageURL,
            newsSite: article.newsSite,
            summary: article.summary,
            publishedAt: article.publishedAt,
            updatedAt: article.updatedAt,
            favorite: article.favorite
        )
    }

    func update(from article: Article) {
        title = article.title
        authorNames = article.authors
        url = article.url
        imageURL = article.imageURL
        newsSite = article.newsSite
        summary = article.summary
        publishedAt = article.publishedAt
        updatedAt = article.updatedAt
    }
}
