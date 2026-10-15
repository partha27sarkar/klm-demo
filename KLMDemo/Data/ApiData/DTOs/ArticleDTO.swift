//
//  ArticleDTO.swift
//  KLMDemo
//

import Foundation

struct ArticleListResponseDTO: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [ArticleDTO]
}

struct AuthorDTO: Decodable {
    let name: String
    let socials: [String: String?]?
}

struct ArticleDTO: Decodable {
    let id: Int
    let title: String
    let authors: [AuthorDTO]
    let url: String
    let imageURL: String
    let newsSite: String
    let summary: String
    let publishedAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case authors
        case url
        case imageURL = "image_url"
        case newsSite = "news_site"
        case summary
        case publishedAt = "published_at"
        case updatedAt = "updated_at"
    }

    func mappingDomainModel() -> Article {
        Article(
            id: id,
            title: title,
            authors: authors.map(\.name),
            url: url,
            imageURL: imageURL,
            newsSite: newsSite,
            summary: summary,
            publishedAt: publishedAt,
            updatedAt: updatedAt
        )
    }
}
