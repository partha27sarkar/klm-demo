import Foundation
import Testing
@testable import KLMDemo

@MainActor
struct ArticleListErrorTests {
    @Test(arguments: [
        (HTTPError.statusCode(401), "Article information is currently unavailable."),
        (HTTPError.statusCode(499), "Article information is currently unavailable."),
        (HTTPError.statusCode(500), "The service is temporarily unavailable."),
        (HTTPError.invalidResponse, "The service is temporarily unavailable."),
        (HTTPError.decodingFailed(TestError.failed), "We couldn't process the article information."),
        (URLError(.notConnectedToInternet), "Please check your internet connection."),
        (TestError.failed, "Something went wrong. Please try again.")
    ] as [(any Error, String)])
    func `Error maps to a user-facing message`(error: any Error, message: String) {
        #expect(ArticleListError.map(error).message == message)
    }
}
