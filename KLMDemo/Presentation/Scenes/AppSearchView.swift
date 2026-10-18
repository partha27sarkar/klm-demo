import SwiftUI

struct AppSearchView: View {
    @Binding var searchQuery: String
    @Binding var showsFavoritesOnly: Bool

    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Search articles", text: $searchQuery)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                if !searchQuery.isEmpty {
                    Button {
                        searchQuery = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityLabel("Clear search")
                }
            }
            .padding(12)
            .background(.fill.tertiary, in: Capsule())

            Button {
                showsFavoritesOnly.toggle()
            } label: {
                Image(systemName: showsFavoritesOnly ? "heart.fill" : "heart")
                    .foregroundStyle(showsFavoritesOnly ? .red : .secondary)
                    .frame(width: 44, height: 44)
                    .background(.fill.tertiary, in: Circle())
            }
            .accessibilityLabel("Show favorites only")
            .accessibilityValue(showsFavoritesOnly ? "On" : "Off")
        }
    }
}
