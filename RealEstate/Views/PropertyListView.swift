import SwiftUI
import FirebaseFirestore

struct PropertyListView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var searchText = ""
    @State private var sortOption = SortOption.priceHighToLow
    
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    // MARK: - Computed Properties
    
    private var filteredAndSortedProperties: [Property] {
        let filtered = firebaseManager.properties.filter { property in
            searchText.isEmpty || 
            property.title.localizedCaseInsensitiveContains(searchText) ||
            property.description.localizedCaseInsensitiveContains(searchText) ||
            property.address.localizedCaseInsensitiveContains(searchText) ||
            property.city.localizedCaseInsensitiveContains(searchText) ||
            property.country.localizedCaseInsensitiveContains(searchText)
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
    
    // MARK: - View Components
    
    private var searchAndSortHeader: some View {
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
    }
    
    private var propertyList: some View {
        Group {
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
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    // MARK: - Body
    
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
                        searchAndSortHeader
                        propertyList
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
    
    // MARK: - Methods
    
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

// MARK: - Property Card View

struct PropertyCard: View {
    let property: Property
    
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    private var propertyImage: some View {
        Group {
            if let firstImage = property.imageURLs.first {
                AsyncImage(url: URL(string: firstImage)) { phase in
                    switch phase {
                    case .empty:
                        placeholderImage
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipped()
                    case .failure:
                        placeholderImage
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                placeholderImage
            }
        }
    }
    
    private var placeholderImage: some View {
        Rectangle()
            .foregroundColor(Theme.cardBackground)
            .overlay(
                Image(systemName: "photo")
                    .foregroundColor(Theme.textWhite.opacity(0.6))
            )
            .frame(height: 200)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            propertyImage
            
            VStack(alignment: .leading, spacing: Theme.padding) {
                // Title and Price
                VStack(alignment: .leading, spacing: 8) {
                    Text(property.title)
                        .font(Theme.Typography.heading)
                        .foregroundColor(Theme.textWhite)
                        .lineLimit(2)
                    
                    Text(currencyFormatter.string(from: NSNumber(value: property.price)) ?? "$0")
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
        }
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cornerRadius)
    }
}

// MARK: - Supporting Views

struct PropertyFeature: View {
    let icon: String
    let value: String
    
    var body: some View {
        Label {
            Text(value)
                .foregroundColor(Theme.textWhite.opacity(0.7))
        } icon: {
            Image(systemName: icon)
                .foregroundColor(Theme.primaryRed)
        }
        .font(Theme.Typography.caption)
    }
}

// MARK: - Sort Option

extension PropertyListView {
    enum SortOption: String, CaseIterable {
        case priceHighToLow = "Price: High to Low"
        case priceLowToHigh = "Price: Low to High"
        case bedsHighToLow = "Beds: Most to Least"
        case bedsLowToHigh = "Beds: Least to Most"
        case newest = "Newest First"
    }
}