//
//  AppDependencies.swift
//  KLMDemo
//
//  Created by Partha Sarkar on 15/10/2026.
//

import Foundation
import SwiftData

@MainActor
final class AppDependencies {
    let modelContainer: ModelContainer
    let articlesRepository: ArticleRepository
    let articlesViewModel: ArticlesViewModel
    let imageCache: ImageDataCache

    init() throws {
        let schema = Schema([
            ArticleRecord.self,
        ])
        let applicationSupportURL = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let storeURL = applicationSupportURL.appending(path: "KLMDemo.store")
        let modelConfiguration = ModelConfiguration(schema: schema, url: storeURL)

        modelContainer = try ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )

        let httpClient = URLSessionHTTPClient()
        let articleStore = SwiftDataArticleStore(container: modelContainer)

        articlesRepository = ArticleRepository(
            httpClient: httpClient,
            store: articleStore
        )
        articlesViewModel = ArticlesViewModel(
            fetchArticlesRequest: FetchArticlesRequest(
                repository: articlesRepository
            )
        )
        imageCache = ImageDataCache()
    }
}
