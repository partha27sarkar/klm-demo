# KLMDemo : Recomended use the **[main](https://github.com/partha27sarkar/klm-demo.git)** repo.

An iOS SwiftUI demo app that displays spaceflight news articles from the [Spaceflight News API](https://api.spaceflightnewsapi.net/v4/articles/). Please use the **[main](https://github.com/partha27sarkar/klm-demo.git)** repo.

## Features

- Browse and search articles.
- View article details and images.
- Mark articles as favourites and filter the list to favourites.
- Cache fetched articles locally with SwiftData for offline fallback.
- Support iPhone and iPad layouts.

## Architecture

The project separates responsibilities into the following layers:

- **Presentation** — SwiftUI scenes and observable view models.
- **Domain** — app models, operations, repository abstractions, and errors.
- **Data** — API DTOs, repository implementation, and SwiftData persistence.
- **Core-Infrastructure** — networking, image caching, and shared extensions.

## Local favourite persistence

The Spaceflight News API does not provide a per-user favourite field or an endpoint for updating one. Therefore, **for this demo only**, favourites are stored locally in SwiftData to demonstrate the feature.

When fresh API data is received, article fields are refreshed while the local `isFavorite` value is retained. This lets a favourite survive refreshes and be available when the app falls back to cached articles. In a production app, the favourite status would normally be persisted by a user-specific backend and synchronized with it.

## Naming conventions

The codebase follows standard Swift naming:

- Types use `PascalCase` (for example, `ArticleRepository`).
- Properties, functions, and parameters use `camelCase`.
- Boolean values use a predicate-style name such as `isFavorite`, `isLoading`, or `showsFavoritesOnly`.
- Protocol names describe the capability they provide (for example, `ArticleRepositoryProtocol`).
- File names match their primary type where practical.
