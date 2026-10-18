//
//  KLMDemoApp.swift
//  KLMDemo
//
//  Created by Partha Sarkar on 15/10/2026.
//

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
            ArticlesView(
                viewModel: dependencies.articlesViewModel,
                imageCache: dependencies.imageCache
            )
        }
        .modelContainer(dependencies.modelContainer)
    }
}
