//
//  ArticleImageView.swift
//  KLMDemo
//
//  Created by Partha Sarkar on 16/10/2026.
//

import SwiftUI
import UIKit

@MainActor
struct ArticleImageView: View {
    private enum LoadingPhase {
        case checkingCache
        case downloading
        case loaded
        case timedOut
        case failed
    }

    private enum ImageLoadingError: Error {
        case timedOut
    }

    private static let imageRequestTimeout: Duration = .seconds(8)
    
    let imageURL: String
    let imageCache: ImageDataCache
    let contentMode: ContentMode

    @State private var image: UIImage?
    @State private var phase: LoadingPhase = .checkingCache

    init(
        imageURL: String,
        imageCache: ImageDataCache,
        contentMode: ContentMode = .fit
    ) {
        self.imageURL = imageURL
        self.imageCache = imageCache
        self.contentMode = contentMode
    }

    var body: some View {
        imageContent
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .task(id: imageURL) {
                await loadImage()
            }
    }

    @ViewBuilder
    private var imageContent: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } else {
            switch phase {
            case .downloading:
                ShimmeringImagePlaceholder()
            case .timedOut, .failed:
                placeholder
            case .checkingCache, .loaded:
                Color.secondary.opacity(0.08)
            }
        }
    }

    private func loadImage() async {
        image = nil
        phase = .checkingCache

        guard let url = normalizedURL else {
            phase = .failed
            return
        }

        if let cachedData = await imageCache.data(for: url),
           let cachedImage = ImageDecoder.image(from: cachedData) {
            guard !Task.isCancelled else {
                return
            }

            image = cachedImage
            phase = .loaded
            return
        }

        guard !Task.isCancelled else {
            return
        }

        phase = .downloading

        do {
            let downloadedData = try await downloadImageData(from: url)

            try Task.checkCancellation()

            guard let downloadedImage = ImageDecoder.image(from: downloadedData) else {
                phase = .failed
                return
            }

            await imageCache.insert(downloadedData, for: url)
            try Task.checkCancellation()

            image = downloadedImage
            phase = .loaded
        } catch is CancellationError {
            return
        } catch ImageLoadingError.timedOut {
            phase = .timedOut
        } catch let error as URLError where error.code == .timedOut {
            phase = .timedOut
        } catch {
            guard !Task.isCancelled else {
                return
            }

            phase = .failed
        }
    }

    private func downloadImageData(from url: URL) async throws -> Data {
        try await withThrowingTaskGroup(of: Data.self) { group in
            group.addTask {
                try await URLSessionHTTPClient().execute(
                    DataGetOperation(url: url)
                )
            }

            group.addTask {
                try await Task.sleep(for: Self.imageRequestTimeout)
                throw ImageLoadingError.timedOut
            }

            defer {
                group.cancelAll()
            }

            guard let data = try await group.next() else {
                throw CancellationError()
            }

            return data
        }
    }

    private var normalizedURL: URL? {
        let trimmedURLString = imageURL.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedURLString.isEmpty else {
            return nil
        }

        let encodedURLString = trimmedURLString.addingPercentEncoding(
            withAllowedCharacters: .urlFragmentAllowed
        )
        let url = URL(string: trimmedURLString)
            ?? encodedURLString.flatMap(URL.init(string:))

        guard let url,
              var components = URLComponents(
                url: url,
                resolvingAgainstBaseURL: false
              ) else {
            return nil
        }

        switch components.scheme?.lowercased() {
        case "http":
            components.scheme = "https"
        case "https":
            break
        default:
            return nil
        }

        return components.url
    }

    private var placeholder: some View {
        Image(systemName: "photo")
            .font(.title2)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private enum ImageDecoder {
    static func image(from data: Data) -> UIImage? {
        if let image = UIImage(data: data) {
            return image
        }

        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}
