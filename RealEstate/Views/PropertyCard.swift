import SwiftUI

struct PropertyCard: View {
    let property: Property
    @EnvironmentObject private var currencyManager: CurrencyManager
    @State private var imageLoadError: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Property Image
            if let firstImage = property.imageURLs.first {
                OptimizedAsyncImage(
                    url: firstImage,
                    targetSize: CGSize(width: 300, height: 200)
                )
            } else {
                placeholderImage
            }
            
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
    
    private var placeholderImage: some View {
        Image(systemName: "house")
            .font(.system(size: 40))
            .foregroundColor(Theme.primaryRed)
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(Theme.cardBackground)
    }
}

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
        .font(.system(size: 14))
    }
} 