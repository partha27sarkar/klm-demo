import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    let viewModel: ArticlesViewModel
    let imageCache: ImageDataCache

    private var displayedArticle: Article {
        if case let .loaded(articles) = viewModel.state {
            return articles.first(where: { $0.id == article.id }) ?? article
        }

        return article
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ArticleImageView(
                        imageURL: displayedArticle.imageURL,
                        imageCache: imageCache
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: proxy.size.height * 0.3)

                    ArticleDetailHeader(
                        title: displayedArticle.title,
                        newsSite: displayedArticle.newsSite
                    )

                    Text(displayedArticle.summary)

                    if !displayedArticle.authors.isEmpty {
                        Text("By \(displayedArticle.authors.formatted())")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Link(
                        "Read Full Article",
                        destination: URL(string: displayedArticle.url) ?? URL(string: "https://api.spaceflightnewsapi.net")!
                    )
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        .navigationTitle("Article")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.toggleFavorite(for: displayedArticle.id)
                } label: {
                    Image(systemName: displayedArticle.favorite ? "heart.fill" : "heart")
                        .foregroundStyle(displayedArticle.favorite ? .red : .primary)
                }
            }
        }
    }
}

private struct ArticleDetailHeader: View {
    let title: String
    let newsSite: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)

            Text(newsSite)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
}
