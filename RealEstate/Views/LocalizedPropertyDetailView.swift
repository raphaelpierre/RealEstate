import SwiftUI

/// A demo view to showcase localization of property details
struct LocalizedPropertyDetailView: View {
    let property: Property
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Property image
                if !property.imageURLs.isEmpty {
                    AsyncImage(url: URL(string: property.imageURLs[0])) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 250)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 250)
                                .clipped()
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 250)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                )
                        @unknown default:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 250)
                        }
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 250)
                        .overlay(
                            Image(systemName: "house.fill")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        )
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // Property title and price
                    VStack(alignment: .leading, spacing: 8) {
                        Text(property.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.textWhite)
                        
                        Text(LocalizationManager.shared.formatCurrency(property.price))
                            .font(.title2)
                            .foregroundColor(Theme.primaryRed)
                    }
                    
                    Divider()
                        .background(Theme.textWhite)
                    
                    // Property details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("property_details".localized)
                            .font(.headline)
                            .foregroundColor(Theme.textWhite)
                        
                        if property.type.lowercased() == "land" {
                            HStack(spacing: 20) {
                                DetailItem(icon: "square.fill", value: LocalizationManager.shared.formatArea(property.area))
                                DetailItem(icon: "percent", value: "\(Int(property.buildableAreaPercentage))%")
                            }
                        } else {
                            HStack(spacing: 20) {
                                DetailItem(icon: "bed.double.fill", value: "\(property.bedrooms) \("bedrooms".localized)")
                                DetailItem(icon: "shower.fill", value: "\(property.bathrooms) \("bathrooms".localized)")
                                DetailItem(icon: "square.fill", value: LocalizationManager.shared.formatArea(property.area))
                            }
                        }
                        
                        HStack(spacing: 20) {
                            DetailItem(icon: "house.fill", value: property.type.localized)
                            DetailItem(icon: "tag.fill", value: property.purpose.localized)
                        }
                    }
                    
                    Divider()
                        .background(Theme.textWhite)
                    
                    // Property address
                    VStack(alignment: .leading, spacing: 8) {
                        Text("address".localized)
                            .font(.headline)
                            .foregroundColor(Theme.textWhite)
                        
                        Text("\(property.address), \(property.city)")
                            .foregroundColor(Theme.textWhite)
                        
                        if !property.zipCode.isEmpty {
                            Text("\(property.zipCode), \(property.country)")
                                .foregroundColor(Theme.textWhite)
                        }
                    }
                    
                    Divider()
                        .background(Theme.textWhite)
                    
                    // Property description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("description".localized)
                            .font(.headline)
                            .foregroundColor(Theme.textWhite)
                        
                        Text(property.description)
                            .foregroundColor(Theme.textWhite)
                    }
                    
                    // Contact button
                    if !property.contact.whatsapp.isEmpty {
                        Button(action: {
                            // Contact action would go here
                            if let whatsappURL = URL(string: "https://wa.me/\(property.contact.whatsapp)") {
                                UIApplication.shared.open(whatsappURL)
                            }
                        }) {
                            Text("contact_agent".localized)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.primaryRed)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.top, 20)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("property_details".localized)
        .navigationBarTitleDisplayMode(.inline)
        .background(Theme.backgroundBlack)
        .edgesIgnoringSafeArea(.top)
        // This is important to force the view to refresh when the language changes
        .id(localizationManager.refreshToggle)
    }
}

/// A helper view for displaying property details with icons
struct DetailItem: View {
    let icon: String
    let value: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(Theme.primaryRed)
            Text(value)
                .foregroundColor(Theme.textWhite)
        }
    }
}

// Preview
struct LocalizedPropertyDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LocalizedPropertyDetailView(property: Property.example)
                .environmentObject(LocalizationManager.shared)
        }
    }
} 