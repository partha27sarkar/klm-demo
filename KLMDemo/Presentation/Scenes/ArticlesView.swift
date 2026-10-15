//
//  ArticlesView.swift
//  KLMDemo
//
//  Created by Partha Sarkar on 15/10/2026.
//

import SwiftUI
import SwiftData

struct ArticlesView: View {
    @Bindable var viewModel: ArticlesViewModel

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("All News Articles")
        }
        .task {
            await viewModel.loadArticles()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Loading articles…")
        case let .loaded(articles):
            List(articles) { article in
                NavigationLink {
                    ArticleDetailView(article: article)
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(article.title)
                            .font(.headline)
                        Text(article.newsSite)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        case let .failed(error):
            ContentUnavailableView {
                Label("Unable to Load Articles", systemImage: "exclamationmark.triangle")
            } description: {
                Text(error.message)
            } actions: {
                Button("Try Again") {
                    Task {
                        await viewModel.retry()
                    }
                }
            }
        }
    }
}

#Preview {
    ArticlesView(
        viewModel: ArticlesViewModel(
            fetchArticlesRequest: FetchArticlesRequest(
                repository: ArticleRepository(
                    httpClient: URLSessionHTTPClient(),
                    store: SwiftDataArticleStore(
                        container: try! ModelContainer(
                            for: ArticleRecord.self,
                            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
                        )
                    )
                )
            )
        )
    )
}
