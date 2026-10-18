//
//  ArticleImageView.swift
//  KLMDemo
//

import ImageIO
import SwiftUI
import UIKit

@MainActor
struct ArticleImageView: View {
    let imageURL: String
    let imageCache: ImageDataCache
    let contentMode: ContentMode

    @State private var image: UIImage?
    @State private var loadFailed = false

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
            } else if loadFailed {
                placeholder(systemImage: "photo")
            } else {
                ProgressView()
                    .controlSize(.regular)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .task(id: imageURL) {
            await loadImage()
        }
    }

    private func loadImage() async {
        image = nil
        loadFailed = false

        guard let url = normalizedURL else {
            loadFailed = true
            return
        }

        if let cachedData = await imageCache.data(for: url),
           let cachedImage = ImageDecoder.image(from: cachedData) {
            image = cachedImage
            return
        }

        do {
            let downloadedData = try await URLSessionHTTPClient().execute(
                DataGetOperation(
                    url: url,
                    headers: [
                        "Accept": "image/*,*/*;q=0.8",
                        "User-Agent": "KLMDemo/1.0"
                    ]
                )
            )

            guard let downloadedImage = ImageDecoder.image(from: downloadedData) else {
                loadFailed = true
                return
            }

            await imageCache.insert(downloadedData, for: url)
            image = downloadedImage
        } catch is CancellationError {
            return
        } catch {
            loadFailed = true
        }
    }

    private var normalizedURL: URL? {
        let trimmedURLString = imageURL.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedURLString.isEmpty else {
            return nil
        }

        if let url = URL(string: trimmedURLString) {
            return url
        }

        let encodedURLString = trimmedURLString.addingPercentEncoding(
            withAllowedCharacters: .urlFragmentAllowed
        )

        return encodedURLString.flatMap(URL.init(string:))
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
