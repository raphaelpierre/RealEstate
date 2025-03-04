import SwiftUI

struct MonetizationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    struct MonetizationOption: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let icon: String
        let color: Color
        let destination: AnyView
    }
    
    let options: [MonetizationOption] = [
        MonetizationOption(
            title: "Premium Subscription",
            description: "Unlock all premium features with a monthly, yearly, or lifetime subscription",
            icon: "crown.fill",
            color: .yellow,
            destination: AnyView(SubscriptionView())
        ),
        MonetizationOption(
            title: "Property Listing Packages",
            description: "Choose the perfect package to showcase your property to potential buyers",
            icon: "house.fill",
            color: Theme.primaryRed,
            destination: AnyView(ListingPackagesView())
        ),
        MonetizationOption(
            title: "In-App Purchases",
            description: "Enhance your experience with individual premium features and tools",
            icon: "bag.fill",
            color: .purple,
            destination: AnyView(InAppPurchasesView())
        )
    ]
    
    var body: some View {
        ZStack {
            Theme.backgroundBlack.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image("app_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .cornerRadius(20)
                        .padding(.bottom, 8)
                    
                    Text("Upgrade Your Experience")
                        .font(Theme.Typography.title)
                        .foregroundColor(Theme.textWhite)
                    
                    Text("Choose how you want to enhance your real estate journey")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.textWhite.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                
                // Options
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(options) { option in
                            NavigationLink(destination: option.destination) {
                                MonetizationOptionCard(option: option)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Restore Purchases Button
                Button {
                    // Restore purchases logic would go here
                } label: {
                    Text("Restore Purchases")
                        .font(.subheadline)
                        .foregroundColor(Theme.textWhite.opacity(0.7))
                        .padding(.vertical, 12)
                }
            }
            .padding(.bottom, 16)
        }
        .navigationTitle("Upgrade Options")
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

struct MonetizationOptionCard: View {
    let option: MonetizationView.MonetizationOption
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: option.icon)
                .font(.system(size: 28))
                .foregroundColor(option.color)
                .frame(width: 60, height: 60)
                .background(option.color.opacity(0.2))
                .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(option.title)
                    .font(Theme.Typography.heading)
                    .foregroundColor(Theme.textWhite)
                
                Text(option.description)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.textWhite.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Theme.textWhite.opacity(0.5))
                .padding(.trailing, 8)
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cornerRadius)
    }
}

#Preview {
    NavigationView {
        MonetizationView()
            .environmentObject(LocalizationManager.shared)
    }
} 