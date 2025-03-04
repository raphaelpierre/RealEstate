import SwiftUI
import FirebaseFirestore
import MapKit

struct PropertyListView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedViewMode: ViewMode
    
    // New initializer to support setting initial view mode
    init(initialViewMode: ViewMode = .list) {
        _selectedViewMode = State(initialValue: initialViewMode)
    }
    
    var body: some View {
        VStack {
            // Segmented control for view mode
            Picker("View Mode", selection: $selectedViewMode) {
                Text("List").tag(ViewMode.list)
                Text("Map").tag(ViewMode.map)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Conditional view based on selected mode
            if selectedViewMode == .list {
                // List view without filters
                Group {
                    if firebaseManager.properties.isEmpty {
                        ContentUnavailableView(
                            "No Properties Found",
                            systemImage: "house",
                            description: Text("Check back later for new listings")
                        )
                    } else {
                        ScrollView {
                            LazyVStack(spacing: Theme.padding) {
                                ForEach(firebaseManager.properties) { property in
                                    NavigationLink(destination: PropertyDetailView(property: property)) {
                                        PropertyCard(property: property)
                                            .contentShape(Rectangle())
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            } else {
                // Map view
                PropertyMapView(properties: firebaseManager.properties)
            }
        }
        .onAppear {
            // Fetch properties if not already loaded
            Task {
                if firebaseManager.properties.isEmpty {
                    isLoading = true
                    do {
                        try await firebaseManager.fetchProperties()
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                    isLoading = false
                }
            }
        }
    }
    
    // Existing enums remain the same
    enum ViewMode {
        case list
        case map
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