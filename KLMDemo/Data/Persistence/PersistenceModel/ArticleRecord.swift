//
//  ArticleRecord.swift
//  KLMDemo
//
//  Created by Partha Sarkar on 15/10/2026.
//

import Foundation
import SwiftData

/// The locally persisted representation of an article.
@Model
final class ArticleRecord {
    @Attribute(.unique) var id: Int
    var title: String
    var authorNames: [String]
    var url: String
    var imageURL: String
    var newsSite: String
    var summary: String
    var publishedAt: String
    var updatedAt: String
    /// `isFavorite` is a demo-only preference because the API does not provide a
    /// per-user favorite status. It is preserved when article data is refreshed.
    var isFavorite: Bool = false

    init(
        id: Int,
        title: String,
        authorNames: [String],
        url: String,
        imageURL: String,
        newsSite: String,
        summary: String,
        publishedAt: String,
        updatedAt: String,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.authorNames = authorNames
        self.url = url
        self.imageURL = imageURL
        self.newsSite = newsSite
        self.summary = summary
        self.publishedAt = publishedAt
        self.updatedAt = updatedAt
        self.isFavorite = isFavorite
    }

    func toDomain() -> Article {
        Article(
            id: id,
            title: title,
            authors: authorNames,
            url: url,
            imageURL: imageURL,
            newsSite: newsSite,
            summary: summary,
            publishedAt: publishedAt,
            updatedAt: updatedAt,
            isFavorite: isFavorite
        )
    }
}
