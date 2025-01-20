import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @EnvironmentObject private var authManager: AuthManager
    
    private var favorites: [Property] {
        firebaseManager.properties.filter { $0.isFavorite }
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundBlack
                .ignoresSafeArea()
            
            if !authManager.isAuthenticated {
                VStack(spacing: Theme.padding) {
                    Text("Sign in to view your favorites")
                        .font(Theme.Typography.heading)
                        .foregroundColor(Theme.textWhite)
                        .multilineTextAlignment(.center)
                    
                    NavigationLink {
                        LoginView()
                    } label: {
                        Text("Sign In")
                            .foregroundColor(Theme.primaryRed)
                            .padding()
                            .background(Theme.cardBackground)
                            .cornerRadius(Theme.cornerRadius)
                    }
                }
            } else {
                if favorites.isEmpty {
                    ContentUnavailableView(
                        "No Favorites Yet",
                        systemImage: "heart",
                        description: Text("Properties you favorite will appear here")
                    )
                    .foregroundColor(Theme.textWhite)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 20)
                        ], spacing: Theme.padding) {
                            ForEach(favorites) { property in
                                NavigationLink(destination: PropertyDetailView(property: property)) {
                                    PropertyCard(property: property)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .id(property.id + (property.isFavorite ? "-fav" : ""))
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        try? await firebaseManager.fetchProperties()
                    }
                }
            }
        }
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.backgroundBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Favorites")
                    .font(Theme.Typography.heading)
                    .foregroundColor(Theme.textWhite)
            }
        }
    }
}