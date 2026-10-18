//
//  ArticleRepositoryProtocol.swift
//  KLMDemo
//
//  Created by Partha Sarkar on 15/10/2026.
//

import Foundation

protocol ArticleRepositoryProtocol: AnyObject {
    func fetchArticles() async throws -> [Article]
    func setFavorite(_ isFavorite: Bool, for articleID: Int) throws
}
