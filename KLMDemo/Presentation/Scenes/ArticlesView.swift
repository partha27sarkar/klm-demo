//
//  ArticlesView.swift
//  KLMDemo
//
//  Created by Partha Sarkar on 15/10/2026.
//

import SwiftData
import SwiftUI

struct ArticlesView: View {
    @Bindable var viewModel: ArticlesViewModel
    let imageCache: ImageDataCache

    var body: some View {
        NavigationStack {
            ArticleListContent(viewModel: viewModel, imageCache: imageCache)
            .navigationTitle("All News Articles")
        }
        .task {
            await viewModel.loadArticles()
        }
    }
}

private struct ArticleListContent: View {
    @Bindable var viewModel: ArticlesViewModel
    let imageCache: ImageDataCache

    var body: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Loading articles…")
        case .loaded:
            VStack(spacing: 0) {
                AppSearchView(
                    searchQuery: $viewModel.searchText,
                    showsFavoritesOnly: $viewModel.showsFavoritesOnly
                )
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                if viewModel.visibleArticles.isEmpty, !viewModel.searchText.isEmpty {
                    ContentUnavailableView.search(text: viewModel.searchText)
                } else {
                    List(viewModel.visibleArticles) { article in
                        ArticleRow(
                            article: article,
                            viewModel: viewModel,
                            imageCache: imageCache
                        )
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

private struct ArticleRow: View {
    let article: Article
    let viewModel: ArticlesViewModel
    let imageCache: ImageDataCache

    var body: some View {
        HStack(spacing: 12) {
            NavigationLink {
                ArticleDetailView(
                    article: article,
                    viewModel: viewModel,
                    imageCache: imageCache
                )
            } label: {
                HStack(spacing: 12) {
                    ArticleImageView(
                        imageURL: article.imageURL,
                        imageCache: imageCache
                    )
                    .frame(width: 84, height: 84)

                    ArticleRowText(
                        title: article.title,
                        newsSite: article.newsSite
                    )
                }
            }
            .buttonStyle(.plain)

            Button {
                viewModel.toggleFavorite(for: article.id)
            } label: {
                Image(systemName: article.isFavorite ? "heart.fill" : "heart")
                    .foregroundStyle(article.isFavorite ? .red : .secondary)
                    .imageScale(.large)
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 4)
    }
}

private struct ArticleRowText: View {
    let title: String
    let newsSite: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .lineLimit(3)

            Text(newsSite)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: ArticleRecord.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    ArticlesView(
        viewModel: ArticlesViewModel(
            fetchArticlesRequest: FetchArticlesRequest(
                repository: ArticleRepository(
                    httpClient: URLSessionHTTPClient(),
                    store: SwiftDataArticleStore(container: container)
                )
            )
        ),
        imageCache: ImageDataCache()
    )
}
