import SwiftUI

struct PropertyDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @EnvironmentObject private var authManager: AuthManager
    @State private var showError = false
    @State private var errorMessage = ""
    let property: Property
    @State private var currentProperty: Property
    @State private var isFavoriteProcessing = false
    
    init(property: Property) {
        self.property = property
        _currentProperty = State(initialValue: property)
    }
    
    private var formattedPrice: String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale(identifier: "en_US")
        return currencyFormatter.string(from: NSNumber(value: currentProperty.price)) ?? "$0"
    }
    
    private var imageGallery: some View {
        TabView {
            ForEach(currentProperty.imageURLs, id: \.self) { imageURL in
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Theme.primaryRed))
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure(_):
                        Image(systemName: "photo")
                            .foregroundColor(Theme.textWhite.opacity(0.5))
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .clipped()
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
    
    private func openWhatsApp() {
        guard let whatsappNumber = currentProperty.contact.whatsapp.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              !whatsappNumber.isEmpty,
              let url = URL(string: "https://wa.me/\(whatsappNumber)") else {
            // Show an alert if WhatsApp number is invalid
            errorMessage = "Invalid WhatsApp number"
            showError = true
            return
        }
        
        UIApplication.shared.open(url)
    }
    
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Contact")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.textWhite)
                .fontWeight(.semibold)
            
            if !currentProperty.contact.whatsapp.isEmpty {
                Button(action: openWhatsApp) {
                    HStack {
                        Image("whatsapp_icon") // Assumes you have a WhatsApp icon in Assets
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color(red: 37/255, green: 211/255, blue: 102/255))
                        
                        Text("Contact via WhatsApp")
                            .foregroundColor(Theme.textWhite)
                            .font(Theme.Typography.body)
                    }
                    .padding(12)
                    .background(Theme.cardBackground)
                    .cornerRadius(10)
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundBlack
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.padding) {
                    // Image Gallery
                    imageGallery
                        .frame(height: 300)
                    
                    VStack(alignment: .leading, spacing: Theme.padding) {
                        // Title and Price Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text(currentProperty.title)
                                .font(Theme.Typography.heading)
                                .foregroundColor(Theme.textWhite)
                            
                            Text(formattedPrice)
                                .font(Theme.Typography.title)
                                .foregroundColor(Theme.primaryRed)
                        }
                        
                        // Type and Purpose Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Property Details")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.textWhite)
                                .fontWeight(.semibold)
                            
                            HStack(spacing: 16) {
                                Label {
                                    Text(currentProperty.type)
                                        .foregroundColor(Theme.textWhite.opacity(0.7))
                                } icon: {
                                    Image(systemName: "house.fill")
                                        .foregroundColor(Theme.primaryRed)
                                }
                                
                                Label {
                                    Text(currentProperty.purpose)
                                        .foregroundColor(Theme.textWhite.opacity(0.7))
                                } icon: {
                                    Image(systemName: currentProperty.purpose.lowercased() == "rent" ? "key.fill" : "cart.fill")
                                        .foregroundColor(Theme.primaryRed)
                                }
                            }
                            .font(Theme.Typography.caption)
                        }
                        
                        // Features Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Features")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.textWhite)
                                .fontWeight(.semibold)
                            
                            HStack(spacing: 24) {
                                Label {
                                    Text("\(currentProperty.bedrooms) Bedrooms")
                                        .foregroundColor(Theme.textWhite.opacity(0.7))
                                } icon: {
                                    Image(systemName: "bed.double.fill")
                                        .foregroundColor(Theme.primaryRed)
                                }
                                
                                Label {
                                    Text("\(currentProperty.bathrooms) Bathrooms")
                                        .foregroundColor(Theme.textWhite.opacity(0.7))
                                } icon: {
                                    Image(systemName: "shower.fill")
                                        .foregroundColor(Theme.primaryRed)
                                }
                                
                                Label {
                                    Text("\(Int(currentProperty.area))m²")
                                        .foregroundColor(Theme.textWhite.opacity(0.7))
                                } icon: {
                                    Image(systemName: "square.fill")
                                        .foregroundColor(Theme.primaryRed)
                                }
                            }
                            .font(Theme.Typography.caption)
                        }
                        
                        // Location Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Location")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.textWhite)
                                .fontWeight(.semibold)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                if !currentProperty.address.isEmpty {
                                    Label {
                                        Text(currentProperty.address)
                                            .foregroundColor(Theme.textWhite.opacity(0.7))
                                    } icon: {
                                        Image(systemName: "location.fill")
                                            .foregroundColor(Theme.primaryRed)
                                    }
                                }
                                
                                if !currentProperty.city.isEmpty {
                                    Label {
                                        Text(currentProperty.city)
                                            .foregroundColor(Theme.textWhite.opacity(0.7))
                                    } icon: {
                                        Image(systemName: "building.2.fill")
                                            .foregroundColor(Theme.primaryRed)
                                    }
                                }
                                
                                if !currentProperty.zipCode.isEmpty {
                                    Label {
                                        Text(currentProperty.zipCode)
                                            .foregroundColor(Theme.textWhite.opacity(0.7))
                                    } icon: {
                                        Image(systemName: "mail.fill")
                                            .foregroundColor(Theme.primaryRed)
                                    }
                                }
                                
                                if !currentProperty.country.isEmpty {
                                    Label {
                                        Text(currentProperty.country)
                                            .foregroundColor(Theme.textWhite.opacity(0.7))
                                    } icon: {
                                        Image(systemName: "globe.europe.africa.fill")
                                            .foregroundColor(Theme.primaryRed)
                                    }
                                }
                            }
                            .font(Theme.Typography.caption)
                        }
                        
                        // Description Section
                        if !currentProperty.description.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.textWhite)
                                    .fontWeight(.semibold)
                                
                                Text(currentProperty.description)
                                    .font(Theme.Typography.body)
                                    .foregroundColor(Theme.textWhite.opacity(0.7))
                            }
                        }
                        
                        // Contact Section
                        contactSection
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.backgroundBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text(currentProperty.title)
                    .font(Theme.Typography.heading)
                    .foregroundColor(Theme.textWhite)
                    .lineLimit(1)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if authManager.isAuthenticated {
                    Button(action: {
                        Task {
                            isFavoriteProcessing = true
                            do {
                                try await firebaseManager.toggleFavorite(for: currentProperty)
                                // Update the current property's favorite status
                                currentProperty.isFavorite.toggle()
                            } catch {
                                errorMessage = error.localizedDescription
                                showError = true
                            }
                            isFavoriteProcessing = false
                        }
                    }) {
                        Group {
                            if isFavoriteProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Theme.textWhite))
                            } else {
                                Image(systemName: currentProperty.isFavorite ? "heart.fill" : "heart")
                                    .foregroundColor(currentProperty.isFavorite ? Theme.primaryRed : Theme.textWhite)
                                    .font(.title3)
                                    .contentShape(Rectangle())
                            }
                        }
                        .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .disabled(isFavoriteProcessing)
                } else {
                    // Debug: Print when auth check fails
                    Text("")
                        .onAppear {
                            print("⚠️ Auth check failed in toolbar - isAuthenticated: \(authManager.isAuthenticated)")
                        }
                }
            }
        }
        .onAppear {
            print("👤 Auth Status: \(authManager.isAuthenticated)")
            print("👤 Current User: \(authManager.currentUser != nil ? "Logged in" : "nil")")
            print("🏠 Property: \(currentProperty.title) (ID: \(currentProperty.id))")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
}

// MARK: - Helper Views
private struct DetailChip: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(Theme.primaryRed)
            Text(text)
                .font(Theme.Typography.caption)
        }
        .foregroundColor(Theme.textWhite)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cornerRadius)
    }
}

private struct LocationRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        Label {
            Text(text)
                .foregroundColor(Theme.textWhite.opacity(0.7))
        } icon: {
            Image(systemName: icon)
                .foregroundColor(Theme.primaryRed)
        }
    }
}

// MARK: - Preview
struct PropertyDetailView_Previews: PreviewProvider {
    static var sampleProperty: Property {
        Property(
            title: "Luxury Villa",
            price: 1250000,
            description: "Beautiful modern villa with amazing views",
            address: "123 Ocean Drive, Miami Beach, FL",
            zipCode: "33139",
            city: "Miami Beach",
            country: "USA",
            bedrooms: 4,
            bathrooms: 3,
            area: 250,
            type: "Villa",
            purpose: "Sale",
            imageURLs: []
        )
    }
    
    static var previews: some View {
        NavigationView {
            PropertyDetailView(property: sampleProperty)
                .environmentObject(FirebaseManager.shared)
                .environmentObject(AuthManager.shared)
        }
    }
}