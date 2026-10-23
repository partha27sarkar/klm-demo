//
//  AppSearchView.swift
//  KLMDemo
//
//  Created by Partha Sarkar on 17/10/2026.
//

import SwiftUI

struct AppSearchView: View {
    @Binding var searchQuery: String
    @Binding var showsFavoritesOnly: Bool

    @FocusState private var isSearchFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Search articles", text: $searchQuery)
                    .focused($isSearchFocused)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .task(id: searchQuery) {
                        if searchQuery.isEmpty {
                            isSearchFocused = false
                        }
                    }

                if !searchQuery.isEmpty {
                    Button {
                        searchQuery = ""
                        isSearchFocused = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(12)
            .background(.fill.tertiary, in: Capsule())

            Button {
                showsFavoritesOnly.toggle()
            } label: {
                Image(systemName: showsFavoritesOnly ? "heart.fill" : "heart")
                    .foregroundStyle(showsFavoritesOnly ? .red : .secondary)
                    .frame(width: 44, height: 44)
                    .background(.fill.tertiary, in: Circle())
            }
        }
    }
}

#Preview {
    AppSearchPreview()
}

private struct AppSearchPreview: View {
    @State private var searchQuery = ""
    @State private var showsFavoritesOnly = false

    var body: some View {
        AppSearchView(
            searchQuery: $searchQuery,
            showsFavoritesOnly: $showsFavoritesOnly
        )
        .padding()
    }
}
