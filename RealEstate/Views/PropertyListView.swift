import SwiftUI
import FirebaseFirestore
import MapKit

struct PropertyListView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var currencyManager: CurrencyManager
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedViewMode: ViewMode
    
    // New initializer to support setting initial view mode
    init(initialViewMode: ViewMode = .list) {
        _selectedViewMode = State(initialValue: initialViewMode)
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundBlack
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                Text("properties".localized)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Theme.textWhite)
                    .padding(.top)
                
                // Segmented control for view mode
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: selectedViewMode == .list ? "list.bullet" : "map")
                            .font(.system(size: 24))
                            .foregroundColor(Theme.primaryRed)
                        
                        Text("display_mode".localized)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Theme.textWhite)
                    }
                    
                    Picker("View Mode", selection: $selectedViewMode) {
                        Text("list".localized).tag(ViewMode.list)
                        Text("map".localized).tag(ViewMode.map)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding()
                .background(Theme.cardBackground)
                .cornerRadius(12)
                .padding(.horizontal)
                .id(localizationManager.refreshToggle)
                
                // Conditional view based on selected mode
                if selectedViewMode == .list {
                    // List view without filters
                    Group {
                        if firebaseManager.properties.isEmpty {
                            ContentUnavailableView(
                                "no_properties_found".localized,
                                systemImage: "house",
                                description: Text("Check back later for new listings")
                            )
                            .foregroundColor(Theme.textWhite)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(firebaseManager.properties) { property in
                                        NavigationLink(destination: PropertyDetailView(property: property)
                                            .environmentObject(localizationManager)) {
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
                        .environmentObject(localizationManager)
                        .environmentObject(currencyManager)
                }
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
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var currencyManager: CurrencyManager
    @State private var imageLoadError: String?
    
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
                    case .failure(let error):
                        placeholderImage
                            .onAppear {
                                imageLoadError = "Failed to load image: \(error.localizedDescription)"
                            }
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                placeholderImage
            }
        }
        .alert("Image Loading Error", isPresented: .constant(imageLoadError != nil)) {
            Button("OK") {
                imageLoadError = nil
            }
        } message: {
            if let error = imageLoadError {
                Text(error)
            }
        }
    }
    
    private var placeholderImage: some View {
        Image(systemName: "house")
            .font(.system(size: 40))
            .foregroundColor(Theme.primaryRed)
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(Theme.cardBackground)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Property Image
            propertyImage
                .frame(height: 200)
                .clipped()
            
            // Property Details
            VStack(alignment: .leading, spacing: 8) {
                // Title and Price
                HStack {
                    Text(property.title)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Theme.textWhite)
                    
                    Spacer()
                    
                    Text(currencyManager.formatPrice(currencyManager.convert(property.price)))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Theme.primaryRed)
                }
                
                // Location
                HStack {
                    Image(systemName: "location")
                        .foregroundColor(Theme.primaryRed)
                    Text("\(property.city), \(property.country)")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.textWhite.opacity(0.7))
                }
                
                // Property Features
                HStack(spacing: 16) {
                    PropertyFeature(icon: "bed.double", value: "\(property.bedrooms)")
                    PropertyFeature(icon: "shower", value: "\(property.bathrooms)")
                    PropertyFeature(icon: "ruler", value: "\(Int(property.area))m²")
                }
            }
            .padding()
        }
        .background(Theme.cardBackground)
        .cornerRadius(12)
    }
}

struct PropertyFeature: View {
    let icon: String
    let value: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(Theme.primaryRed)
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(Theme.textWhite.opacity(0.7))
        }
    }
}

#Preview {
    PropertyListView()
        .environmentObject(FirebaseManager.shared)
        .environmentObject(LocalizationManager.shared)
        .environmentObject(CurrencyManager.shared)
}