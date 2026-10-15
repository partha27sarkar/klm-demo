import SwiftUI
import SwiftData

@main
struct KLMDemoApp: App {

    private let dependencies: AppDependencies

    init() {
        do {
            dependencies = try AppDependencies()
        } catch {
            fatalError("Failed to configure application: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ArticlesView(viewModel: dependencies.articlesViewModel)
        }
        .modelContainer(dependencies.modelContainer)
    }
}
