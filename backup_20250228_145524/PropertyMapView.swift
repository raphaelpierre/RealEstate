import SwiftUI
import MapKit
import CoreLocation

extension MKCoordinateRegion: Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        return lhs.center.latitude == rhs.center.latitude &&
               lhs.center.longitude == rhs.center.longitude &&
               lhs.span.latitudeDelta == rhs.span.latitudeDelta &&
               lhs.span.longitudeDelta == rhs.span.longitudeDelta
    }
}

struct PropertyMapView: View {
    let properties: [Property]
    
    @State private var region: MKCoordinateRegion
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
        
        // Initialize region with a default value
        _region = State(initialValue: MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        ))
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
        
        // More nuanced zoom calculation
        let baseSpread = max(latSpread, lonSpread)
        return baseSpread > 1 ? 2.0 : (baseSpread > 0.5 ? 1.0 : 0.5)
    }
    
    private func zoomToProperties() {
        guard !properties.isEmpty else { return }
        
        let center = PropertyMapView.calculateCenterCoordinate(from: properties)
        let zoomLevel = calculateBestZoomLevel()
        
        withAnimation {
            region = MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(latitudeDelta: zoomLevel, longitudeDelta: zoomLevel)
            )
            selectedProperty = nil
            isZoomedToAllProperties = true
        }
    }
    
    private func zoomToSelectedProperty(_ property: Property) {
        withAnimation {
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: property.latitude, longitude: property.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)  // Tighter zoom
            )
            selectedProperty = property
            isZoomedToAllProperties = false
        }
    }
    
    var body: some View {
        VStack {
            Map(initialPosition: .region(region)) {
                ForEach(properties) { property in
                    Annotation("$\(property.price, specifier: "%.0f")", coordinate: CLLocationCoordinate2D(latitude: property.latitude, longitude: property.longitude)) {
                        VStack(spacing: 0) {
                            Circle()
                                .fill(selectedProperty?.id == property.id ? Theme.primaryBlue : Theme.primaryRed)
                                .frame(width: 20, height: 20)  // Slightly larger
                                .shadow(color: .black.opacity(0.3), radius: 4)
                                .overlay(
                                    Circle()
                                        .stroke(selectedProperty?.id == property.id ? Theme.primaryRed : Color.clear, lineWidth: 2)
                                )
                            
                            VStack {
                                NavigationLink(destination: PropertyDetailView(property: property)) {
                                    Text("$\(property.price, specifier: "%.0f")")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(2)
                                        .background(Theme.primaryRed)
                                        .cornerRadius(4)
                                        .offset(y: -15)
                                }
                            }
                        }
                        .onTapGesture {
                            if selectedProperty?.id == property.id {
                                // If tapping the same property, navigate to detail
                                NavigationLink(destination: PropertyDetailView(property: property)) {
                                    EmptyView()
                                }.buttonStyle(PlainButtonStyle()).hidden().disabled(false)
                            } else {
                                // Zoom to the property
                                zoomToSelectedProperty(property)
                            }
                        }
                    }
                }
            }
            .mapStyle(.standard)
            .mapControls {
                MapUserLocationButton()
            }
            .onChange(of: region) { oldValue, newValue in
                // Detect if user has manually zoomed out
                if !isZoomedToAllProperties {
                    let zoomThreshold = calculateBestZoomLevel() * 2
                    if abs(newValue.span.latitudeDelta) > zoomThreshold {
                        isZoomedToAllProperties = true
                        selectedProperty = nil
                    }
                }
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
                    .background(Theme.primaryBlue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
        .onAppear {
            zoomToProperties()
        }
    }
}

// You'll need to extend your Property model to conform to Identifiable and have a coordinate
extension Property {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}