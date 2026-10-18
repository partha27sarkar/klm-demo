import Foundation
import SwiftData
@testable import KLMDemo

enum TestFixture {
    static func mockData() throws -> Data {
        guard let url = Bundle(for: BundleToken.self).url(forResource: "MOCK", withExtension: "json") else {
            throw TestError.missingMock
        }
        let data = try Data(contentsOf: url)
        guard let jsonStart = data.firstIndex(of: 0x7B) else {
            throw TestError.missingMock
        }
        return Data(data[jsonStart...])
    }

    static func mockResponse() throws -> ArticleListResponseDTO {
        try JSONDecoder().decode(ArticleListResponseDTO.self, from: mockData())
    }

    static func mockArticles() throws -> [Article] {
        try mockResponse().results.map { $0.mappingDomainModel() }
    }

    static func article(id: Int = 1, isFavorite: Bool = false) -> Article {
        Article(
            id: id,
            title: "Article \(id)",
            authors: ["Author \(id)"],
            url: "https://example.com/articles/\(id)",
            imageURL: "https://example.com/images/\(id).jpg",
            newsSite: "Space News",
            summary: "Summary \(id)",
            publishedAt: "2026-10-15T10:00:00Z",
            updatedAt: "2026-10-15T11:00:00Z",
            isFavorite: isFavorite
        )
    }

    @MainActor
    static func store() throws -> SwiftDataArticleStore {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ArticleRecord.self, configurations: configuration)
        return SwiftDataArticleStore(container: container)
    }

    @MainActor
    static func repository(
        data: Data? = nil,
        error: TestError? = nil,
        store: SwiftDataArticleStore? = nil
    ) throws -> ArticleRepository {
        ArticleRepository(
            httpClient: StubHTTPClient(data: data, error: error),
            store: try store ?? self.store()
        )
    }
}

struct StubHTTPClient: HTTPClient {
    let data: Data?
    let error: TestError?

    nonisolated init(data: Data? = nil, error: TestError? = nil) {
        self.data = data
        self.error = error
    }

    func execute<Operation: HTTPRequestOperation>(
        _ operation: Operation
    ) async throws -> Operation.Response {
        if let error {
            throw error
        }
        guard let data else {
            throw TestError.missingResponse
        }
        return try operation.decodeResponse(from: data)
    }
}

enum TestError: Error, Equatable {
    case failed
    case missingMock
    case missingResponse
}

private final class BundleToken {}
