import SwiftUI
import FirebaseFirestore

struct PropertyListView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var searchText = ""
    @State private var sortOption = SortOption.priceHighToLow
    
    enum SortOption: String, CaseIterable {
        case priceHighToLow = "Price: High to Low"
        case priceLowToHigh = "Price: Low to High"
        case bedsHighToLow = "Beds: Most to Least"
        case bedsLowToHigh = "Beds: Least to Most"
        case newest = "Newest First"
    }
    
    var filteredAndSortedProperties: [Property] {
        let filtered = firebaseManager.properties.filter { property in
            searchText.isEmpty || 
            property.title.localizedCaseInsensitiveContains(searchText) ||
            property.description.localizedCaseInsensitiveContains(searchText) ||
            property.address.localizedCaseInsensitiveContains(searchText)
        }
        
        return filtered.sorted { first, second in
            switch sortOption {
            case .priceHighToLow:
                return first.price > second.price
            case .priceLowToHigh:
                return first.price < second.price
            case .bedsHighToLow:
                return first.bedrooms > second.bedrooms
            case .bedsLowToHigh:
                return first.bedrooms < second.bedrooms
            case .newest:
                return first.createdAt > second.createdAt
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundBlack
                    .ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                        .tint(Theme.primaryRed)
                } else {
                    VStack(spacing: Theme.padding) {
                        // Sort and Search Header
                        VStack(spacing: Theme.smallPadding) {
                            // Sort Picker
                            Picker("Sort", selection: $sortOption) {
                                ForEach(SortOption.allCases, id: \.self) { option in
                                    Text(option.rawValue)
                                        .foregroundColor(Theme.textWhite)
                                        .tag(option)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(Theme.primaryRed)
                            
                            // Search Bar
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(Theme.textWhite.opacity(0.6))
                                TextField("Search properties...", text: $searchText)
                                    .foregroundColor(Theme.textWhite)
                                    .tint(Theme.primaryRed)
                            }
                            .padding()
                            .background(Theme.cardBackground)
                            .cornerRadius(Theme.cornerRadius)
                        }
                        .padding(.horizontal)
                        
                        // Property List
                        if filteredAndSortedProperties.isEmpty {
                            ContentUnavailableView(
                                "No Properties Found",
                                systemImage: "house",
                                description: Text("Try adjusting your search criteria")
                            )
                            .foregroundColor(Theme.textWhite)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: Theme.padding) {
                                    ForEach(filteredAndSortedProperties) { property in
                                        NavigationLink(destination: PropertyDetailView(property: property)) {
                                            PropertyCard(property: property)
                                                .contentShape(Rectangle())
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .simultaneousGesture(TapGesture().onEnded {
                                            // Empty gesture to prevent navigation when tapping the heart
                                        })
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Properties")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Theme.backgroundBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .task {
                await loadProperties()
            }
            .refreshable {
                await loadProperties()
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    private func loadProperties() async {
        isLoading = true
        do {
            try await firebaseManager.fetchProperties()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

struct PropertyCard: View {
    let property: Property
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @EnvironmentObject private var authManager: AuthManager
    @State private var isFavorite: Bool
    
    init(property: Property) {
        self.property = property
        _isFavorite = State(initialValue: property.isFavorite)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Property Image
            if let firstImage = property.imageURLs.first {
                AsyncImage(url: URL(string: firstImage)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .foregroundColor(Theme.cardBackground)
                            .overlay(ProgressView().tint(Theme.primaryRed))
                            .frame(height: 200)
                            .overlay(alignment: .topTrailing) {
                                favoriteButton
                            }
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .overlay(alignment: .topTrailing) {
                                favoriteButton
                            }
                    case .failure:
                        Rectangle()
                            .foregroundColor(Theme.cardBackground)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(Theme.textWhite.opacity(0.6))
                            )
                            .frame(height: 200)
                            .overlay(alignment: .topTrailing) {
                                favoriteButton
                            }
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
                    .overlay(alignment: .topTrailing) {
                        favoriteButton
                    }
            }
            
            VStack(alignment: .leading, spacing: Theme.smallPadding) {
                Text(property.title)
                    .font(Theme.Typography.heading)
                    .foregroundColor(Theme.textWhite)
                    .lineLimit(1)
                
                Text("$\(Int(property.price))")
                    .font(Theme.Typography.title)
                    .foregroundColor(Theme.primaryRed)
                
                Text(property.address)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.textWhite.opacity(0.8))
                    .lineLimit(2)
                
                HStack(spacing: Theme.padding) {
                    PropertyFeature(icon: "bed.double", value: "\(property.bedrooms)")
                    PropertyFeature(icon: "shower", value: "\(property.bathrooms)")
                    PropertyFeature(icon: "square", value: "\(Int(property.area))m²")
                }
                .padding(.top, Theme.smallPadding)
            }
            .padding(Theme.padding)
        }
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cornerRadius)
        .shadow(color: Color.black.opacity(Theme.shadowOpacity), radius: Theme.shadowRadius, x: 0, y: 2)
    }
    
    private var favoriteButton: some View {
        Group {
            if authManager.isAuthenticated {
                Button {
                    isFavorite.toggle() // Update local state immediately
                    firebaseManager.toggleFavorite(for: property)
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? Theme.primaryRed : Theme.textWhite)
                        .font(.title2)
                        .padding(Theme.padding)
                }
                .animation(.easeInOut, value: isFavorite)
            } else {
                NavigationLink(destination: LoginView()) {
                    Image(systemName: "heart")
                        .foregroundColor(Theme.textWhite)
                        .font(.title2)
                        .padding(Theme.padding)
                }
            }
        }
    }
}

struct PropertyFeature: View {
    let icon: String
    let value: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(Theme.textWhite.opacity(0.6))
            Text(value)
                .foregroundColor(Theme.textWhite.opacity(0.8))
                .font(Theme.Typography.caption)
        }
    }
}