import SwiftUI

struct PropertyDetailView: View {
    let property: Property
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Image carousel
                TabView {
                    ForEach(property.imageURLs, id: \.self) { imageUrl in
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .foregroundColor(.gray.opacity(0.2))
                        }
                    }
                }
                .frame(height: 300)
                .tabViewStyle(PageTabViewStyle())
                
                VStack(alignment: .leading, spacing: 16) {
                    // Title and Price
                    VStack(alignment: .leading, spacing: 8) {
                        Text(property.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("$\(Int(property.price))")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    // Property Details
                    HStack(spacing: 30) {
                        PropertyFeature(icon: "bed.double", value: "\(property.bedrooms)", text: "Beds")
                        PropertyFeature(icon: "shower", value: "\(property.bathrooms)", text: "Baths")
                        PropertyFeature(icon: "square", value: "\(Int(property.area))", text: "m²")
                    }
                    .padding(.vertical)
                    
                    // Address
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Location", systemImage: "location")
                            .font(.headline)
                        Text(property.address)
                            .foregroundColor(.secondary)
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                        Text(property.description)
                            .foregroundColor(.secondary)
                    }
                    
                    // Contact Button
                    Button(action: {
                        // Add contact action here
                    }) {
                        Text("Contact Agent")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PropertyFeature: View {
    let icon: String
    let value: String
    let text: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
            Text(value)
                .font(.headline)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct PropertyDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PropertyDetailView(property: Property(
                title: "Modern Villa",
                price: 1250000,
                description: "Beautiful modern villa with amazing views",
                address: "123 Ocean Drive, Miami Beach, FL",
                bedrooms: 4,
                bathrooms: 3,
                area: 250,
                imageURLs: []
            ))
        }
    }
}