//
//  AppDependencies.swift
//  KLMDemo
//
//  Created by Partha Sarkar on 15/10/2026.
//

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
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        modelContainer = {
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }()

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
