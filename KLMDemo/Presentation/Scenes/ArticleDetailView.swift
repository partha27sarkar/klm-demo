//
//  ArticleDetailView.swift
//  KLMDemo
//
//  Created by Partha Sarkar on 15/10/2026.
//

import SwiftUI

struct ArticleDetailView: View {
    let article: Article

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(article.title)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(article.newsSite)
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text(article.summary)

                if !article.authors.isEmpty {
                    Text("By \(article.authors.formatted())")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Link(
                    "Read Full Article",
                    destination: URL(string: article.url) ?? URL(string: "https://api.spaceflightnewsapi.net")!
                )
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("Article")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ArticleDetailView(
            article: Article(
                id: 1,
                title: "NASA Announces New Artemis Mission Milestone",
                authors: ["Jane Doe", "John Smith"],
                url: "https://www.nasa.gov/",
                imageURL: "",
                newsSite: "NASA",
                summary: "NASA has announced a new milestone for its Artemis program, bringing the next lunar mission one step closer to launch.",
                publishedAt: "2026-10-15T00:00:00Z",
                updatedAt: "2026-10-15T00:00:00Z"
            )
        )
    }
}
