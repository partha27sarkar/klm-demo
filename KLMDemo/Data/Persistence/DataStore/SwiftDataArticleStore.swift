//
//  SwiftDataArticleStore.swift
//  KLMDemo
//
//  Created by Partha Sarkar on 15/10/2026.
//

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
        let existing = try context.fetch(FetchDescriptor<ArticleRecord>())
        let incomingIDs = Set(articles.map(\.id))

        for record in existing where !incomingIDs.contains(record.id) {
            context.delete(record)
        }
        for article in articles {
            context.insert(ArticleRecord(article))
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

    // MARK: - Private Helpers

    private func updateAndInsert(_ article: Article, existingRecord: ArticleRecord?) {
        if let existingRecord {
            existingRecord.update(from: article)
        } else {
            context.insert(ArticleRecord(article))
        }
    }
}

// MARK: - ArticleRecord Mapping Helpers

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
            updatedAt: article.updatedAt
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
