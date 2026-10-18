import Foundation
import Testing
@testable import KLMDemo

@MainActor
struct HTTPClientTests {
    @Test
    func `GET decodes the mock feed asynchronously`() async throws {
        let client = StubHTTPClient(data: try TestFixture.mockData())

        let response = try await client.get(
            ArticleListResponseDTO.self,
            from: URL(string: "https://example.com/articles")!
        )

        #expect(response.results.count == 10)
    }

    @Test
    func `JSON operation reports invalid data`() {
        let operation = JSONGetOperation<ArticleListResponseDTO>(
            url: URL(string: "https://example.com/articles")!
        )

        #expect(throws: HTTPError.self) {
            try operation.decodeResponse(from: Data("invalid".utf8))
        }
    }

    @Test
    func `Data operation returns unchanged bytes`() throws {
        let expected = Data([1, 2, 3])
        let operation = DataGetOperation(
            url: URL(string: "https://example.com/image")!,
            headers: ["Accept": "image/*"]
        )

        #expect(try operation.decodeResponse(from: expected) == expected)
        let httpMethod = operation.request.httpMethod
        let acceptHeader = operation.request.value(forHTTPHeaderField: "Accept")

        #expect(httpMethod == "GET")
        #expect(acceptHeader == "image/*")
    }
}
