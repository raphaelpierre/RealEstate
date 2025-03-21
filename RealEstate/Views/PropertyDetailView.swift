import SwiftUI

struct PropertyDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var currencyManager: CurrencyManager
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var failedImageURLs: Set<String> = []
    let property: Property
    @State private var currentProperty: Property
    @State private var isFavoriteProcessing = false
    @State private var isFavorite = false
    @State private var showOrangeMoneyPayment = false
    
    init(property: Property) {
        self.property = property
        _currentProperty = State(initialValue: property)
    }
    
    private var formattedPrice: String {
        return currencyManager.formatPrice(currencyManager.convert(currentProperty.price))
    }
    
    private func toggleFavorite() {
        guard authManager.isAuthenticated else {
            errorMessage = "Please sign in to add favorites"
            showError = true
            return
        }
        
        isFavoriteProcessing = true
        
        Task {
            do {
                try await firebaseManager.toggleFavorite(for: currentProperty)
                isFavorite.toggle()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isFavoriteProcessing = false
        }
    }
    
    private func checkFavoriteStatus() {
        isFavorite = firebaseManager.isFavorite(currentProperty.id)
    }
    
    private var imageGallery: some View {
        VStack {
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
                            VStack(spacing: 12) {
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(Theme.textWhite.opacity(0.5))
                                Text("Failed to load image")
                                    .font(.system(size: 14))
                                    .foregroundColor(Theme.textWhite.opacity(0.7))
                                Button("Retry") {
                                    failedImageURLs.remove(imageURL)
                                }
                                .foregroundColor(Theme.primaryRed)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Theme.cardBackground)
                                .cornerRadius(8)
                            }
                            .onAppear {
                                if !failedImageURLs.contains(imageURL) {
                                    failedImageURLs.insert(imageURL)
                                }
                            }
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
            
            if !failedImageURLs.isEmpty {
                Text("\(failedImageURLs.count) image\(failedImageURLs.count > 1 ? "s" : "") failed to load")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.textWhite.opacity(0.7))
                    .padding(.top, 8)
            }
        }
    }
    
    private func openWhatsApp() {
        guard let whatsappNumber = currentProperty.contact.whatsapp.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              !whatsappNumber.isEmpty,
              let url = URL(string: "https://wa.me/\(whatsappNumber)") else {
            errorMessage = "Invalid WhatsApp number"
            showError = true
            return
        }
        
        UIApplication.shared.open(url)
    }
    
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "phone.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Theme.primaryRed)
                
                Text("contact".localized)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Theme.textWhite)
            }
            
            // WhatsApp Contact
            if !currentProperty.contact.whatsapp.isEmpty {
                Button {
                    if let whatsappURL = URL(string: "https://wa.me/\(currentProperty.contact.whatsapp)") {
                        UIApplication.shared.open(whatsappURL)
                    }
                } label: {
                    HStack {
                        Image("whatsapp_icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                        Text("contact_whatsapp".localized)
                            .font(.system(size: 16))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.cardBackground)
                    .cornerRadius(12)
                    .foregroundColor(Theme.textWhite)
                }
            }
            
            // Orange Money Payment Button
            Button {
                showOrangeMoneyPayment = true
            } label: {
                HStack {
                    Image("orange_money_icon") // Vous devrez ajouter cette image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                    Text("pay_with_orange_money".localized)
                        .font(.system(size: 16))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Theme.primaryRed)
                .cornerRadius(12)
                .foregroundColor(.white)
            }
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(12)
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundBlack
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Image Gallery
                    imageGallery
                        .frame(height: 300)
                    
                    // Property Details
                    VStack(alignment: .leading, spacing: 24) {
                        // Title and Price
                        VStack(alignment: .leading, spacing: 8) {
                            Text(currentProperty.title)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Theme.textWhite)
                            
                            Text(formattedPrice)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Theme.primaryRed)
                        }
                        
                        // Location
                        HStack {
                            Image(systemName: "location")
                                .foregroundColor(Theme.primaryRed)
                            Text("\(currentProperty.city), \(currentProperty.country)")
                                .font(.system(size: 16))
                                .foregroundColor(Theme.textWhite.opacity(0.7))
                        }
                        
                        // Property Features
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 24))
                                    .foregroundColor(Theme.primaryRed)
                                
                                Text("property_features".localized)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(Theme.textWhite)
                            }
                            
                            if currentProperty.type.lowercased() == "land" {
                                VStack(spacing: 16) {
                                    // Total Area
                                    HStack(spacing: 16) {
                                        Image(systemName: "ruler.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(Theme.primaryRed)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("total_area".localized)
                                                .font(.system(size: 14))
                                                .foregroundColor(Theme.textWhite.opacity(0.7))
                                            Text("\(Int(currentProperty.area))m²")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(Theme.textWhite)
                                        }
                                    }
                                    
                                    // Buildable Area
                                    HStack(spacing: 16) {
                                        Image(systemName: "building.2.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(Theme.primaryRed)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("buildable_area".localized)
                                                .font(.system(size: 14))
                                                .foregroundColor(Theme.textWhite.opacity(0.7))
                                            Text("\(Int(currentProperty.area * currentProperty.buildableAreaPercentage / 100))m²")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(Theme.textWhite)
                                        }
                                    }
                                    
                                    // Buildable Area Percentage
                                    HStack(spacing: 16) {
                                        Image(systemName: "percent")
                                            .font(.system(size: 20))
                                            .foregroundColor(Theme.primaryRed)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("buildable_area_percentage".localized)
                                                .font(.system(size: 14))
                                                .foregroundColor(Theme.textWhite.opacity(0.7))
                                            Text("\(Int(currentProperty.buildableAreaPercentage))%")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(Theme.textWhite)
                                        }
                                    }
                                    
                                    // Purpose
                                    HStack(spacing: 16) {
                                        Image(systemName: "tag.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(Theme.primaryRed)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("purpose".localized)
                                                .font(.system(size: 14))
                                                .foregroundColor(Theme.textWhite.opacity(0.7))
                                            Text(currentProperty.purpose.localized)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(Theme.textWhite)
                                        }
                                    }
                                }
                            } else {
                                HStack(spacing: 16) {
                                    PropertyFeature(icon: "bed.double", value: "\(currentProperty.bedrooms)")
                                    PropertyFeature(icon: "shower", value: "\(currentProperty.bathrooms)")
                                    PropertyFeature(icon: "ruler", value: "\(Int(currentProperty.area))m²")
                                }
                            }
                        }
                        .padding()
                        .background(Theme.cardBackground)
                        .cornerRadius(12)
                        
                        // Description
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "text.alignleft")
                                    .font(.system(size: 24))
                                    .foregroundColor(Theme.primaryRed)
                                
                                Text("description".localized)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(Theme.textWhite)
                            }
                            
                            Text(currentProperty.description)
                                .font(.system(size: 16))
                                .foregroundColor(Theme.textWhite.opacity(0.7))
                        }
                        .padding()
                        .background(Theme.cardBackground)
                        .cornerRadius(12)
                        
                        // Contact Section
                        contactSection
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: toggleFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? Theme.primaryRed : Theme.textWhite)
                }
                .disabled(isFavoriteProcessing)
            }
        }
        .onAppear {
            checkFavoriteStatus()
        }
        .alert("error".localized, isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showOrangeMoneyPayment) {
            OrangeMoneyPaymentView(
                property: currentProperty,
                amount: currentProperty.price
            )
        }
    }
}

#Preview {
    PropertyDetailView(property: Property(
        title: "Sample Property",
        price: 500000,
        description: "A beautiful property with great features",
        address: "123 Main St",
        bedrooms: 3,
        bathrooms: 2,
        area: 150,
        imageURLs: []
    ))
    .environmentObject(FirebaseManager.shared)
    .environmentObject(AuthManager.shared)
    .environmentObject(LocalizationManager.shared)
    .environmentObject(CurrencyManager.shared)
}