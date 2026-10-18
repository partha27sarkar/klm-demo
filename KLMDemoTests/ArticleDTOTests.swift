import Testing
@testable import KLMDemo

struct ArticleDTOTests {
    @Test
    @MainActor
    func `Mock feed decodes and maps every article`() throws {
        let response = try TestFixture.mockResponse()
        let articles = response.results.map { $0.mappingDomainModel() }

        #expect(response.count == 36_492)
        #expect(articles.count == 10)
        #expect(articles.map(\.id) == [40394, 40393, 40392, 40391, 40390, 40389, 40388, 40387, 40386, 40385])
        #expect(articles.first?.title == "Arianespace Targets 23 Nov Ariane 6 Return Following Reported Turbopump Fix")
        #expect(articles.first?.authors == ["European Spaceflight"])
        #expect(articles.first?.newsSite == "European Spaceflight")
        #expect(articles.first?.isFavorite == false)
    }
}
