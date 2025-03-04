import SwiftUI

// Sample Property model
struct Property {
    let id: String
    let title: String
    let address: String
    let price: Int
    let bedrooms: Int
    let bathrooms: Int
    let area: Double
    let description: String
    let features: [String]
    let mainImage: String
    let images: [String]
}

// A fully localized Property Detail View
struct LocalizedPropertyDetailView: View {
    let property: Property
    @State private var selectedImageIndex = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Image gallery
                TabView(selection: $selectedImageIndex) {
                    ForEach(0..<property.images.count, id: \.self) { index in
                        Image(property.images[index])
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .tag(index)
                    }
                }
                .frame(height: 300)
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                VStack(alignment: .leading, spacing: 16) {
                    // Title and price
                    VStack(alignment: .leading, spacing: 8) {
                        Text(property.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(LocalizationManager.shared.formatCurrency(property.price))
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    // Address
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.gray)
                        Text(property.address)
                            .font(.subheadline)
                    }
                    
                    // Property details
                    HStack(spacing: 20) {
                        VStack {
                            Image(systemName: "bed.double.fill")
                                .font(.title2)
                            Text("\(property.bedrooms)")
                                .font(.subheadline)
                            Text("bedrooms".localized)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Image(systemName: "shower.fill")
                                .font(.title2)
                            Text("\(property.bathrooms)")
                                .font(.subheadline)
                            Text("bathrooms".localized)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Image(systemName: "square.fill")
                                .font(.title2)
                            Text(LocalizationManager.shared.formatArea(property.area))
                                .font(.subheadline)
                            Text("area".localized)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("description".localized)
                            .font(.headline)
                        
                        Text(property.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    // Features
                    VStack(alignment: .leading, spacing: 8) {
                        Text("features".localized)
                            .font(.headline)
                        
                        ForEach(property.features, id: \.self) { feature in
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(feature)
                            }
                        }
                    }
                    
                    // Contact buttons
                    HStack(spacing: 16) {
                        Button(action: {
                            // Schedule viewing action
                        }) {
                            HStack {
                                Image(systemName: "calendar")
                                Text("schedule_viewing".localized)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            // Contact agent action
                        }) {
                            HStack {
                                Image(systemName: "phone.fill")
                                Text("contact_agent".localized)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("property_details".localized)
        .navigationBarItems(
            trailing: Button(action: {
                // Save property action
            }) {
                Image(systemName: "heart")
                    .foregroundColor(.red)
                    .accessibilityLabel("save_property".localized)
            }
        )
    }
}

// Preview with both English and French locales
struct LocalizedPropertyDetailView_Previews: PreviewProvider {
    static var sampleProperty = Property(
        id: "1",
        title: "Modern Apartment in Downtown",
        address: "123 Main Street, City",
        price: 750000,
        bedrooms: 3,
        bathrooms: 2,
        area: 1200,
        description: "A beautiful modern apartment in the heart of downtown with stunning views of the city skyline. Recently renovated with high-end finishes and appliances.",
        features: [
            "Hardwood floors",
            "Stainless steel appliances",
            "In-unit laundry",
            "Central air conditioning",
            "24-hour doorman"
        ],
        mainImage: "property1",
        images: ["property1", "property1_living", "property1_kitchen", "property1_bedroom"]
    )
    
    static var previews: some View {
        Group {
            NavigationView {
                LocalizedPropertyDetailView(property: sampleProperty)
            }
            .previewDisplayName("English")
            
            NavigationView {
                LocalizedPropertyDetailView(property: sampleProperty)
            }
            .environment(\.locale, .init(identifier: "fr"))
            .previewDisplayName("French")
        }
    }
} 