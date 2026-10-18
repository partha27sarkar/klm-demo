//
//  Article.swift
//  KLMDemo
//
//  Created by Partha Sarkar on 15/10/2026.
//

import Foundation

nonisolated struct Article: Identifiable, Equatable, Sendable {
    let id: Int
    let title: String
    let authors: [String]
    let url: String
    let imageURL: String
    let newsSite: String
    let summary: String
    let publishedAt: String
    let updatedAt: String
    /// `isFavorite` is a demo-only preference because the API does not provide a
    /// per-user favorite status. It is preserved when article data is refreshed.
    var isFavorite: Bool = false
}
