import SwiftUI
import MapKit
import CoreLocation
import _MapKit_SwiftUI

// MARK: - Property Annotation View
private struct PropertyAnnotationView: View {
    let property: Property
    @EnvironmentObject private var currencyManager: CurrencyManager
    @State private var isNavigating = false
    
    private var priceText: String {
        currencyManager.formatPrice(currencyManager.convert(property.price))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Marker circle with property type icon
                let fillColor = Theme.primaryRed
                let strokeColor = Color.clear
                
                ZStack {
                    Circle()
                        .fill(fillColor)
                        .frame(width: 24, height: 24)
                        .shadow(color: .black.opacity(0.3), radius: 4)
                        .overlay(
                            Circle()
                                .stroke(strokeColor, lineWidth: 2)
                        )
                    
                    // Property type icon
                    Image(systemName: propertyTypeIcon(for: property.type))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Property info card
                VStack(alignment: .leading, spacing: 4) {
                    // Price
                    Text(priceText)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.primaryRed)
                        .cornerRadius(4)
                    
                    // Property details
                    VStack(alignment: .leading, spacing: 2) {
                        Text(property.title)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "bed.double")
                                .font(.system(size: 8))
                            Text("\(property.bedrooms)")
                            Image(systemName: "shower")
                                .font(.system(size: 8))
                            Text("\(property.bathrooms)")
                        }
                        .font(.system(size: 8))
                        .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(6)
                    .background(Theme.cardBackground)
                    .cornerRadius(4)
                    .shadow(color: .black.opacity(0.2), radius: 2)
                }
                .offset(y: -8)
            }
            .onTapGesture {
                isNavigating = true
            }
            .navigationDestination(isPresented: $isNavigating) {
                PropertyDetailView(property: property)
                    .environmentObject(currencyManager)
            }
        }
    }
    
    private func propertyTypeIcon(for type: String) -> String {
        switch type.lowercased() {
        case "house":
            return "house.fill"
        case "apartment":
            return "building.2.fill"
        case "villa":
            return "house.lodge.fill"
        case "land":
            return "leaf.fill"
        default:
            return "house.fill"
        }
    }
}

// MARK: - Property Map View
struct PropertyMapView: View {
    let properties: [Property]
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var currencyManager: CurrencyManager
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var cameraPosition: MapCameraPosition
    @State private var zoomLevel: Double = 0.2 // Default zoom level
    @State private var selectedProperty: Property? = nil
    @State private var isZoomedToAllProperties: Bool = true
    
    init(properties: [Property]) {
        self.properties = properties
        
        // Calculate initial region based on properties
        let validProperties = properties.filter { $0.latitude != 0.0 && $0.longitude != 0.0 }
        
        // Default to San Francisco if no valid properties
        let center = validProperties.isEmpty 
            ? CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
            : PropertyMapView.calculateCenterCoordinate(from: properties)
        
        // Initialize camera position with a default value
        let region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )
        _cameraPosition = State(initialValue: .region(region))
    }
    
    private static func calculateCenterCoordinate(from properties: [Property]) -> CLLocationCoordinate2D {
        // Filter out properties with valid coordinates
        let validProperties = properties.filter { $0.latitude != 0.0 && $0.longitude != 0.0 }
        
        // If no valid properties, return a default location (e.g., San Francisco)
        guard !validProperties.isEmpty else {
            return CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        }
        
        // Calculate average latitude and longitude
        let latitudes = validProperties.map { $0.latitude }
        let longitudes = validProperties.map { $0.longitude }
        
        let centerLatitude = latitudes.reduce(0, +) / Double(latitudes.count)
        let centerLongitude = longitudes.reduce(0, +) / Double(longitudes.count)
        
        return CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
    }
    
    private func calculateBestZoomLevel() -> Double {
        guard !properties.isEmpty else { return 0.2 }
        
        let validProperties = properties.filter { $0.latitude != 0.0 && $0.longitude != 0.0 }
        guard !validProperties.isEmpty else { return 0.2 }
        
        // Calculate the spread of properties
        let latitudes = validProperties.map { $0.latitude }
        let longitudes = validProperties.map { $0.longitude }
        
        let latSpread = (latitudes.max() ?? 0) - (latitudes.min() ?? 0)
        let lonSpread = (longitudes.max() ?? 0) - (longitudes.min() ?? 0)
        
        // Add padding to ensure all properties are visible
        let padding = 2.0 // 100% padding for better overview
        let baseSpread = max(latSpread, lonSpread) * padding
        
        // Adjust zoom level based on spread
        if baseSpread > 10 {
            return 10.0 // Maximum zoom out for very spread properties
        } else if baseSpread > 5 {
            return 5.0
        } else if baseSpread > 2 {
            return 2.0
        } else if baseSpread > 1 {
            return 1.0
        } else if baseSpread > 0.5 {
            return 0.5
        } else {
            return 0.2 // Minimum zoom level
        }
    }
    
    private func calculateVisibleRegion() -> MKCoordinateRegion {
        let validProperties = properties.filter { $0.latitude != 0.0 && $0.longitude != 0.0 }
        guard !validProperties.isEmpty else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
            )
        }
        
        // Calculate bounds
        let latitudes = validProperties.map { $0.latitude }
        let longitudes = validProperties.map { $0.longitude }
        
        let minLat = latitudes.min() ?? 0
        let maxLat = latitudes.max() ?? 0
        let minLon = longitudes.min() ?? 0
        let maxLon = longitudes.max() ?? 0
        
        // Calculate center
        let centerLat = (minLat + maxLat) / 2
        let centerLon = (minLon + maxLon) / 2
        
        // Calculate span with padding
        let latDelta = (maxLat - minLat) * 1.5 // 50% padding
        let lonDelta = (maxLon - minLon) * 1.5 // 50% padding
        
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        )
    }
    
    private func handleRegionChange(_ position: MapCameraPosition) {
        guard !isZoomedToAllProperties else { return }
        
        if let region = position.region {
            let zoomThreshold = calculateBestZoomLevel() * 2
            if abs(region.span.latitudeDelta) > zoomThreshold {
                isZoomedToAllProperties = true
                selectedProperty = nil
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color that matches the app's theme
                Theme.backgroundBlack.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Map(position: $cameraPosition) {
                        ForEach(properties.filter { $0.latitude != 0 && $0.longitude != 0 }) { property in
                            Annotation("", coordinate: property.coordinate) {
                                PropertyAnnotationView(property: property)
                                    .onTapGesture {
                                        if selectedProperty?.id == property.id {
                                            // If tapping the same property, navigate to detail
                                            selectedProperty = nil
                                        } else {
                                            // Zoom to the property
                                            zoomToSelectedProperty(property)
                                        }
                                    }
                            }
                        }
                        UserAnnotation()
                    }
                    .mapStyle(.standard) // Always use standard (light) mode for the map
                    .mapControls {
                        MapUserLocationButton()
                    }
                    .onChange(of: cameraPosition) { oldPosition, newPosition in
                        handleRegionChange(newPosition)
                    }
                    
                    if selectedProperty != nil {
                        Button(action: {
                            selectedProperty = nil
                            zoomToProperties()
                        }) {
                            VStack {
                                Image(systemName: "xmark.circle")
                                Text("Reset Zoom")
                            }
                            .padding()
                            .background(Theme.primaryRed)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding()
                    }
                }
                .onAppear {
                    zoomToProperties()
                }
                .id(currencyManager.refreshToggle)
            }
            .preferredColorScheme(.dark) // Force dark mode for the entire view
        }
    }
    
    private func zoomToProperties() {
        guard !properties.isEmpty else { return }
        
        withAnimation {
            let region = calculateVisibleRegion()
            cameraPosition = .region(region)
            selectedProperty = nil
            isZoomedToAllProperties = true
        }
    }
    
    private func zoomToSelectedProperty(_ property: Property) {
        withAnimation {
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: property.latitude, longitude: property.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)  // Tighter zoom
            )
            cameraPosition = .region(region)
            selectedProperty = property
            isZoomedToAllProperties = false
        }
    }
}

// You'll need to extend your Property model to conform to Identifiable and have a coordinate
extension Property {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}