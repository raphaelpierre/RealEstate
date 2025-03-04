import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var currencyManager: CurrencyManager
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    private var favorites: [Property] {
        firebaseManager.properties.filter { $0.isFavorite }
    }
    
    // MARK: - Property Info Card
    private struct PropertyInfoCard: View {
        let property: Property
        @EnvironmentObject private var currencyManager: CurrencyManager
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                // Title and Price Section
                VStack(alignment: .leading, spacing: 8) {
                    Text(property.title)
                        .font(Theme.Typography.heading)
                        .foregroundColor(Theme.textWhite)
                        .lineLimit(2)
                    
                    Text(currencyManager.formatPrice(property.price))
                        .font(Theme.Typography.title)
                        .foregroundColor(Theme.primaryRed)
                }
                
                // Key Details
                HStack(spacing: Theme.padding) {
                    Label {
                        Text("\(property.bedrooms) Beds")
                            .foregroundColor(Theme.textWhite.opacity(0.7))
                    } icon: {
                        Image(systemName: "bed.double.fill")
                            .foregroundColor(Theme.primaryRed)
                    }
                    
                    Label {
                        Text("\(property.bathrooms) Baths")
                            .foregroundColor(Theme.textWhite.opacity(0.7))
                    } icon: {
                        Image(systemName: "shower.fill")
                            .foregroundColor(Theme.primaryRed)
                    }
                    
                    Label {
                        Text("\(Int(property.area))m²")
                            .foregroundColor(Theme.textWhite.opacity(0.7))
                    } icon: {
                        Image(systemName: "square.fill")
                            .foregroundColor(Theme.primaryRed)
                    }
                }
                .font(Theme.Typography.caption)
                
                // Location
                if !property.address.isEmpty || !property.city.isEmpty {
                    Label {
                        Text("\(property.address), \(property.city)")
                            .foregroundColor(Theme.textWhite.opacity(0.7))
                            .lineLimit(1)
                    } icon: {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(Theme.primaryRed)
                    }
                    .font(Theme.Typography.caption)
                }
            }
            .padding()
            .background(Theme.cardBackground)
        }
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
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Theme.primaryRed))
                        .scaleEffect(1.5)
                } else if favorites.isEmpty {
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
                                NavigationLink(destination: PropertyDetailView(property: property)
                                    .environmentObject(firebaseManager)
                                    .environmentObject(authManager)
                                    .environmentObject(localizationManager)
                                    .environmentObject(currencyManager)) {
                                    VStack(alignment: .leading, spacing: 0) {
                                        // Image with heart button overlay
                                        ZStack(alignment: .topTrailing) {
                                            if let firstImage = property.imageURLs.first {
                                                AsyncImage(url: URL(string: firstImage)) { phase in
                                                    switch phase {
                                                    case .empty:
                                                        Rectangle()
                                                            .foregroundColor(Theme.cardBackground)
                                                            .overlay(
                                                                Image(systemName: "photo")
                                                                    .foregroundColor(Theme.textWhite.opacity(0.6))
                                                            )
                                                            .frame(height: 200)
                                                    case .success(let image):
                                                        image
                                                            .resizable()
                                                            .scaledToFill()
                                                            .frame(height: 200)
                                                            .clipped()
                                                    case .failure:
                                                        Rectangle()
                                                            .foregroundColor(Theme.cardBackground)
                                                            .overlay(
                                                                Image(systemName: "photo")
                                                                    .foregroundColor(Theme.textWhite.opacity(0.6))
                                                            )
                                                            .frame(height: 200)
                                                    @unknown default:
                                                        EmptyView()
                                                    }
                                                }
                                            } else {
                                                Rectangle()
                                                    .foregroundColor(Theme.cardBackground)
                                                    .overlay(
                                                        Image(systemName: "photo")
                                                            .foregroundColor(Theme.textWhite.opacity(0.6))
                                                    )
                                                    .frame(height: 200)
                                            }
                                            
                                            // Heart Button
                                            Button(action: {
                                                Task {
                                                    do {
                                                        try await firebaseManager.toggleFavorite(for: property)
                                                    } catch {
                                                        errorMessage = error.localizedDescription
                                                        showError = true
                                                    }
                                                }
                                            }) {
                                                Group {
                                                    Image(systemName: property.isFavorite ? "heart.fill" : "heart")
                                                        .foregroundColor(property.isFavorite ? Theme.primaryRed : Theme.textWhite)
                                                        .font(.title3)
                                                        .contentShape(Rectangle())
                                                }
                                                .frame(width: 44, height: 44)
                                                .background(Theme.cardBackground.opacity(0.8))
                                                .clipShape(Circle())
                                                .padding(8)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                        .frame(height: 200)
                                        .clipped()
                                        
                                        // Property Info
                                        VStack(alignment: .leading, spacing: Theme.padding) {
                                            // Title and Price Section
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text(property.title)
                                                    .font(Theme.Typography.heading)
                                                    .foregroundColor(Theme.textWhite)
                                                
                                                Text(currencyManager.formatPrice(property.price))
                                                    .font(Theme.Typography.title)
                                                    .foregroundColor(Theme.primaryRed)
                                            }
                                            
                                            // Type and Purpose Section
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text("Property Details")
                                                    .font(Theme.Typography.caption)
                                                    .foregroundColor(Theme.textWhite)
                                                    .fontWeight(.semibold)
                                                
                                                HStack(spacing: 16) {
                                                    Label {
                                                        Text(property.type)
                                                            .foregroundColor(Theme.textWhite.opacity(0.7))
                                                    } icon: {
                                                        Image(systemName: "house.fill")
                                                            .foregroundColor(Theme.primaryRed)
                                                    }
                                                    
                                                    Label {
                                                        Text(property.purpose)
                                                            .foregroundColor(Theme.textWhite.opacity(0.7))
                                                    } icon: {
                                                        Image(systemName: property.purpose.lowercased() == "rent" ? "key.fill" : "cart.fill")
                                                            .foregroundColor(Theme.primaryRed)
                                                    }
                                                }
                                                .font(Theme.Typography.caption)
                                            }
                                            
                                            // Features Section
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text("Features")
                                                    .font(Theme.Typography.caption)
                                                    .foregroundColor(Theme.textWhite)
                                                    .fontWeight(.semibold)
                                                
                                                HStack(spacing: 24) {
                                                    Label {
                                                        Text("\(property.bedrooms) Bedrooms")
                                                            .foregroundColor(Theme.textWhite.opacity(0.7))
                                                    } icon: {
                                                        Image(systemName: "bed.double.fill")
                                                            .foregroundColor(Theme.primaryRed)
                                                    }
                                                    
                                                    Label {
                                                        Text("\(property.bathrooms) Bathrooms")
                                                            .foregroundColor(Theme.textWhite.opacity(0.7))
                                                    } icon: {
                                                        Image(systemName: "shower.fill")
                                                            .foregroundColor(Theme.primaryRed)
                                                    }
                                                    
                                                    Label {
                                                        Text("\(Int(property.area))m²")
                                                            .foregroundColor(Theme.textWhite.opacity(0.7))
                                                    } icon: {
                                                        Image(systemName: "square.fill")
                                                            .foregroundColor(Theme.primaryRed)
                                                    }
                                                }
                                                .font(Theme.Typography.caption)
                                            }
                                            
                                            // Location Section
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text("Location")
                                                    .font(Theme.Typography.caption)
                                                    .foregroundColor(Theme.textWhite)
                                                    .fontWeight(.semibold)
                                                
                                                VStack(alignment: .leading, spacing: 4) {
                                                    if !property.address.isEmpty {
                                                        Label {
                                                            Text(property.address)
                                                                .foregroundColor(Theme.textWhite.opacity(0.7))
                                                        } icon: {
                                                            Image(systemName: "location.fill")
                                                                .foregroundColor(Theme.primaryRed)
                                                        }
                                                    }
                                                    
                                                    if !property.city.isEmpty {
                                                        Label {
                                                            Text(property.city)
                                                                .foregroundColor(Theme.textWhite.opacity(0.7))
                                                        } icon: {
                                                            Image(systemName: "building.2.fill")
                                                                .foregroundColor(Theme.primaryRed)
                                                        }
                                                    }
                                                    
                                                    if !property.zipCode.isEmpty {
                                                        Label {
                                                            Text(property.zipCode)
                                                                .foregroundColor(Theme.textWhite.opacity(0.7))
                                                        } icon: {
                                                            Image(systemName: "mail.fill")
                                                                .foregroundColor(Theme.primaryRed)
                                                        }
                                                    }
                                                    
                                                    if !property.country.isEmpty {
                                                        Label {
                                                            Text(property.country)
                                                                .foregroundColor(Theme.textWhite.opacity(0.7))
                                                        } icon: {
                                                            Image(systemName: "globe.europe.africa.fill")
                                                                .foregroundColor(Theme.primaryRed)
                                                        }
                                                    }
                                                }
                                                .font(Theme.Typography.caption)
                                            }
                                            
                                            // Description Section
                                            if !property.description.isEmpty {
                                                VStack(alignment: .leading, spacing: 8) {
                                                    Text("Description")
                                                        .font(Theme.Typography.caption)
                                                        .foregroundColor(Theme.textWhite)
                                                        .fontWeight(.semibold)
                                                    
                                                    Text(property.description)
                                                        .font(Theme.Typography.body)
                                                        .foregroundColor(Theme.textWhite.opacity(0.7))
                                                        .lineLimit(3)
                                                }
                                            }
                                        }
                                        .padding()
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .background(Theme.cardBackground)
                                .cornerRadius(Theme.cornerRadius)
                                .id(property.id + (property.isFavorite ? "-fav" : ""))
                                .transition(.opacity.combined(with: .move(edge: .leading)))
                            }
                        }
                        .padding()
                        .animation(.easeInOut, value: favorites.count)
                    }
                    .refreshable {
                        await loadData()
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
        .task {
            await loadData()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func loadData() async {
        guard authManager.isAuthenticated else { return }
        
        isLoading = true
        do {
            try await firebaseManager.loadFavorites()
            try await firebaseManager.fetchProperties()
        } catch {
            if let error = error as? FirebaseManager.FavoriteError {
                errorMessage = error.localizedDescription
            } else if let error = error as? FirebaseManager.AuthError {
                errorMessage = error.localizedDescription
            } else {
                errorMessage = error.localizedDescription
            }
            showError = true
        }
        isLoading = false
    }
}