//
//  ArticleListState.swift
//  KLMDemo
//
//  Created by Partha Sarkar on 15/10/2026.
//

enum ArticleListState {
    case idle
    case loading
    case loaded([Article])
    case failed(ArticleListError)
}

