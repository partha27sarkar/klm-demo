

# KLMDemo

An iOS SwiftUI demo app that displays spaceflight news articles from the [Spaceflight News API](https://api.spaceflightnewsapi.net/v4/articles/).

Use the [`main` branch of the recommended repository](https://github.com/partha27sarkar/klm-demo/tree/main).

## Configuration

- Minimum deployment target: iOS 17.6.
- Development environment: Xcode 27 on macOS 27.

The development environment above is the setup reported for this demo. Compatibility with other Xcode and macOS versions has not been verified. The iOS deployment target specifies the minimum OS version for the app; it does not specify the Xcode version needed to build it.

### Running on a physical device

Before running the app on a physical iPhone or iPad, open the app target’s **Signing & Capabilities** settings in Xcode, select your development team, and replace the demo bundle identifier `assignment.ios.KLMDemo` with a unique bundle identifier registered to your team. Ensure that signing and provisioning are configured for the selected device.

## Features

- Browse and search articles.
- View article details and images.
- Mark articles as favourites and filter the list to show favourites only.
- Cache fetched articles locally with SwiftData for offline fallback.


## Public API content disclaimer
This demo displays third-party content supplied by the public Spaceflight News API. Some articles may contain incomplete or incorrectly formatted text, and linked images may be unavailable, fail to load, or appear corrupted. Content quality and image availability depend on the API and the original publishers.

## Architecture
The project separates responsibilities into the following layers:

- **Presentation** — SwiftUI scenes and observable view models.
- **Domain** — app models, operations, repository abstractions, and errors.
- **Data** — API data transfer objects (DTOs), the repository implementation, and SwiftData persistence.
- **Core infrastructure** — networking, image caching, and shared extensions.

## Local favourite persistence

Favourites are stored locally in SwiftData for this demo. The Spaceflight News API article response does not include a per-user favourite field.

When fresh API data is received, article fields are refreshed while the local `isFavorite` value is retained. This allows favourites to survive refreshes and remain available when the app falls back to cached articles.

In a production app that supports cross-device synchronisation, favourite status would typically be stored in a user-specific backend and synchronised with the local cache.

## Naming conventions

The codebase uses the following naming conventions:

- Types use `PascalCase`, for example, `ArticleRepository`.
- Properties, functions, and parameters use `camelCase`.
- Boolean values use descriptive names such as `isFavorite`, `isLoading`, or `showsFavoritesOnly`.
- Protocols describe the abstraction or capability they provide; this project uses names such as `ArticleRepositoryProtocol`.
- File names match their primary type where practical.
