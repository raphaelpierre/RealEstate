import SwiftUI

struct ListingPackagesView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var selectedPackage: ListingPackage = .standard
    @State private var showingPaymentSheet = false
    
    enum ListingPackage: String, CaseIterable, Identifiable {
        case basic = "Basic"
        case standard = "Standard"
        case premium = "Premium"
        
        var id: String { self.rawValue }
        
        var price: String {
            switch self {
            case .basic: return "$29.99"
            case .standard: return "$49.99"
            case .premium: return "$99.99"
            }
        }
        
        var duration: String {
            switch self {
            case .basic: return "30 days"
            case .standard: return "60 days"
            case .premium: return "90 days"
            }
        }
        
        var features: [String] {
            switch self {
            case .basic:
                return [
                    "Single property listing",
                    "Up to 5 photos",
                    "Basic property details",
                    "Contact information"
                ]
            case .standard:
                return [
                    "Single property listing",
                    "Up to 15 photos",
                    "Detailed property description",
                    "Floor plan upload",
                    "Featured for 7 days",
                    "Contact information"
                ]
            case .premium:
                return [
                    "Single property listing",
                    "Unlimited photos",
                    "HD video tour",
                    "3D virtual tour",
                    "Detailed property description",
                    "Floor plan upload",
                    "Featured for 30 days",
                    "Priority placement in search",
                    "Social media promotion",
                    "Contact information"
                ]
            }
        }
        
        var tagline: String {
            switch self {
            case .basic: return "Essential visibility"
            case .standard: return "Most popular"
            case .premium: return "Maximum exposure"
            }
        }
        
        var color: Color {
            switch self {
            case .basic: return .blue
            case .standard: return Theme.primaryRed
            case .premium: return .purple
            }
        }
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundBlack.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("List Your Property")
                            .font(Theme.Typography.title)
                            .foregroundColor(Theme.textWhite)
                        
                        Text("Choose the perfect package to showcase your property")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.textWhite.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    
                    // Package Selection
                    VStack(spacing: 16) {
                        ForEach(ListingPackage.allCases) { package in
                            ListingPackageCard(
                                package: package,
                                isSelected: selectedPackage == package,
                                action: { selectedPackage = package }
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Selected Package Details
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Package Details")
                                .font(Theme.Typography.heading)
                                .foregroundColor(Theme.textWhite)
                            
                            Spacer()
                            
                            Text(selectedPackage.duration)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(selectedPackage.color)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(selectedPackage.color.opacity(0.2))
                                .cornerRadius(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(selectedPackage.features, id: \.self) { feature in
                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(selectedPackage.color)
                                    
                                    Text(feature)
                                        .font(Theme.Typography.body)
                                        .foregroundColor(Theme.textWhite)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Theme.cardBackground)
                    .cornerRadius(Theme.cornerRadius)
                    .padding(.horizontal)
                    
                    // Payment Button
                    Button {
                        showingPaymentSheet = true
                    } label: {
                        Text("Continue to Payment • \(selectedPackage.price)")
                            .font(Theme.Typography.heading)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedPackage.color)
                            .cornerRadius(Theme.cornerRadius)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Terms
                    Text("By proceeding, you agree to our Terms of Service and Privacy Policy. Listing will be active for \(selectedPackage.duration) from the date of publication.")
                        .font(.caption)
                        .foregroundColor(Theme.textWhite.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                    
                    Spacer()
                }
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Listing Packages")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Close") {
                    dismiss()
                }
                .foregroundColor(Theme.primaryRed)
            }
        }
        .sheet(isPresented: $showingPaymentSheet) {
            PaymentSheetView(package: selectedPackage)
        }
    }
}

struct ListingPackageCard: View {
    let package: ListingPackagesView.ListingPackage
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(package.rawValue)
                            .font(Theme.Typography.heading)
                            .foregroundColor(Theme.textWhite)
                        
                        Text(package.tagline)
                            .font(.caption)
                            .foregroundColor(Theme.textWhite.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(package.price)
                            .font(Theme.Typography.heading)
                            .foregroundColor(package.color)
                        
                        Text(package.duration)
                            .font(.caption)
                            .foregroundColor(Theme.textWhite.opacity(0.7))
                    }
                }
                
                if isSelected {
                    HStack {
                        Spacer()
                        Text("Selected")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(package.color)
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(package.color)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .fill(Theme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.cornerRadius)
                            .stroke(isSelected ? package.color : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PaymentSheetView: View {
    @Environment(\.dismiss) private var dismiss
    let package: ListingPackagesView.ListingPackage
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundBlack.ignoresSafeArea()
                
                VStack {
                    Text("Payment details will be implemented here")
                        .foregroundColor(Theme.textWhite)
                        .padding()
                }
            }
            .navigationTitle("Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Theme.primaryRed)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ListingPackagesView()
            .environmentObject(LocalizationManager.shared)
    }
} 