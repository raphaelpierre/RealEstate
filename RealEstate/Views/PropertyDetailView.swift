import SwiftUI

struct PropertyDetailView: View {
    let property: Property
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @EnvironmentObject private var authManager: AuthManager
    
    var body: some View {
        ZStack {
            Theme.backgroundBlack
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.padding) {
                    // Image Gallery
                    TabView {
                        ForEach(property.imageURLs, id: \.self) { imageURL in
                            AsyncImage(url: URL(string: imageURL)) { phase in
                                switch phase {
                                case .empty:
                                    Rectangle()
                                        .foregroundColor(Theme.cardBackground)
                                        .overlay(ProgressView().tint(Theme.primaryRed))
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .failure:
                                    Rectangle()
                                        .foregroundColor(Theme.cardBackground)
                                        .overlay(
                                            Image(systemName: "photo")
                                                .foregroundColor(Theme.textWhite.opacity(0.6))
                                        )
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                    .frame(height: 300)
                    .tabViewStyle(PageTabViewStyle())
                    
                    VStack(alignment: .leading, spacing: Theme.padding) {
                        // Title and Price
                        HStack {
                            Text(property.title)
                                .font(Theme.Typography.heading)
                                .foregroundColor(Theme.textWhite)
                                .lineLimit(2)
                        }
                        
                        Text("$\(Int(property.price))")
                            .font(Theme.Typography.title)
                            .foregroundColor(Theme.primaryRed)
                        
                        Text(property.address)
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.textWhite.opacity(0.8))
                        
                        // Features
                        HStack(spacing: Theme.padding) {
                            PropertyFeature(icon: "bed.double", value: "\(property.bedrooms)")
                            PropertyFeature(icon: "shower", value: "\(property.bathrooms)")
                            PropertyFeature(icon: "square", value: "\(Int(property.area))m²")
                        }
                        .padding(.top, Theme.smallPadding)
                        
                        // Description
                        VStack(alignment: .leading, spacing: Theme.smallPadding) {
                            Text("Description")
                                .font(Theme.Typography.heading)
                                .foregroundColor(Theme.textWhite)
                            Text(property.description)
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.textWhite.opacity(0.8))
                                .lineSpacing(4)
                        }
                        .padding(.top, Theme.padding)
                        
                        // Contact Button
                        Button(action: {
                            // Add contact action here
                        }) {
                            Text("Contact Agent")
                                .font(Theme.Typography.heading)
                                .foregroundColor(Theme.textWhite)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.primaryRed)
                                .cornerRadius(Theme.cornerRadius)
                        }
                        .padding(.top, Theme.padding)
                    }
                    .padding(Theme.padding)
                    .background(Theme.cardBackground)
                    .cornerRadius(Theme.cornerRadius)
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.backgroundBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(property.title)
                    .font(Theme.Typography.heading)
                    .foregroundColor(Theme.textWhite)
                    .lineLimit(1)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if authManager.isAuthenticated {
                    Button {
                        firebaseManager.toggleFavorite(for: property)
                    } label: {
                        Image(systemName: property.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(property.isFavorite ? Theme.primaryRed : Theme.textWhite)
                    }
                    .animation(.easeInOut, value: property.isFavorite)
                }
            }
        }
    }
}

struct DetailFeature: View {
    let icon: String
    let value: String
    let text: String
    
    var body: some View {
        VStack(spacing: Theme.smallPadding) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Theme.textWhite)
            Text(value)
                .font(Theme.Typography.heading)
                .foregroundColor(Theme.textWhite)
            Text(text)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.textWhite.opacity(0.8))
        }
    }
}

struct PropertyDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PropertyDetailView(property: Property(
                id: UUID().uuidString,
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