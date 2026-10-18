//
//  ShimmeringImagePlaceholder.swift
//  KLMDemo
//
//  Created by Partha Sarkar on 18/10/2026.
//

import SwiftUI

struct ShimmeringImagePlaceholder: View {
    @State private var isAnimating = false
    var body: some View {
        GeometryReader { proxy in
            Color.secondary.opacity(0.22)
                .overlay {
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.5),
                            .clear,
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(width: proxy.size.width * 0.55)
                    .rotationEffect(.degrees(20))
                    .offset(x: isAnimating ? proxy.size.width : -proxy.size.width)
                }
                .clipped()
        }
        .task {
            withAnimation(.linear(duration: 1.1).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}
