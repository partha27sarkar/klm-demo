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
        case failed
    }
    
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
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if phase == .failed {
                placeholder(systemImage: "photo")
            } else if phase == .downloading {
                ShimmeringImagePlaceholder()
            } else {
                Color.secondary.opacity(0.08)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .task(id: imageURL) {
            await loadImage()
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
            image = cachedImage
            phase = .loaded
            return
        }

        phase = .downloading

        do {
            let downloadedData = try await URLSessionHTTPClient().execute(
                DataGetOperation(url: url)
            )

            guard let downloadedImage = ImageDecoder.image(from: downloadedData) else {
                phase = .failed
                return
            }

            await imageCache.insert(downloadedData, for: url)
            image = downloadedImage
            phase = .loaded
        } catch is CancellationError {
            return
        } catch {
            phase = .failed
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

    private func placeholder(systemImage: String) -> some View {
        Image(systemName: systemImage)
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
