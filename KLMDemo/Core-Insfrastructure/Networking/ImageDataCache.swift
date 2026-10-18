//
//  ImageDataCache.swift
//  KLMDemo
//
//  Created by Partha Sarkar on 15/10/2026.
//

import CryptoKit
import Foundation

actor ImageDataCache {
    private let fileManager: FileManager
    private let directoryURL: URL
    private let memoryCache = NSCache<NSURL, NSData>()

    init(
        fileManager: FileManager = .default,
        directoryURL: URL? = nil
    ) {
        self.fileManager = fileManager
        self.directoryURL = directoryURL ?? fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent("ArticleImageCache", isDirectory: true)

        try? fileManager.createDirectory(
            at: self.directoryURL,
            withIntermediateDirectories: true
        )
    }

    func data(for url: URL) -> Data? {
        if let cachedData = memoryCache.object(forKey: url as NSURL) {
            return cachedData as Data
        }

        guard let diskData = try? Data(contentsOf: fileURL(for: url)) else {
            return nil
        }

        memoryCache.setObject(diskData as NSData, forKey: url as NSURL)
        return diskData
    }

    func insert(_ data: Data, for url: URL) {
        memoryCache.setObject(data as NSData, forKey: url as NSURL)
        try? data.write(to: fileURL(for: url), options: .atomic)
    }

    private func fileURL(for url: URL) -> URL {
        let digest = SHA256.hash(data: Data(url.absoluteString.utf8))
        let fileName = digest.map { String(format: "%02x", $0) }.joined()
        return directoryURL.appendingPathComponent(fileName)
    }
}
