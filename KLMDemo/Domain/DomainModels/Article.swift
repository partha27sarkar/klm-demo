//
//  Article.swift
//  KLMDemo
//
//  Created by Partha Sarkar on 15/10/2026.
//

import Foundation

struct Article: Identifiable, Equatable, Sendable {
    let id: Int
    let title: String
    let authors: [String]
    let url: String
    let imageURL: String
    let newsSite: String
    let summary: String
    let publishedAt: String
    let updatedAt: String
    var favorite: Bool = false
}
