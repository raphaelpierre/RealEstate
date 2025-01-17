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
                if isLoading {
                    ProgressView()
                } else {
                    VStack(spacing: 0) {
                        // Sort Picker
                        Picker("Sort", selection: $sortOption) {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding()
                        
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search properties...", text: $searchText)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        
                        // Property List
                        if filteredAndSortedProperties.isEmpty {
                            ContentUnavailableView(
                                "No Properties Found",
                                systemImage: "house",
                                description: Text("Try adjusting your search criteria")
                            )
                        } else {
                            List(filteredAndSortedProperties) { property in
                                NavigationLink(destination: PropertyDetailView(property: property)) {
                                    PropertyRowView(property: property)
                                }
                            }
                            .listStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("Properties")
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

struct PropertyRowView: View {
    let property: Property
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Property Image
            if let firstImage = property.imageURLs.first {
                AsyncImage(url: URL(string: firstImage)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.2))
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.2))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Property Details
            Text(property.title)
                .font(.headline)
            Text(property.address)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("$\(Int(property.price))")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            // Property Features
            HStack(spacing: 15) {
                Label("\(property.bedrooms)", systemImage: "bed.double")
                Label("\(property.bathrooms)", systemImage: "shower")
                Label("\(Int(property.area))m²", systemImage: "square")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}
