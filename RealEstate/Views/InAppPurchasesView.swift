import SwiftUI

struct InAppPurchasesView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var selectedCategory: PurchaseCategory = .features
    
    enum PurchaseCategory: String, CaseIterable, Identifiable {
        case features = "Premium Features"
        case credits = "Credit Packs"
        case tools = "Pro Tools"
        
        var id: String { self.rawValue }
        
        var icon: String {
            switch self {
            case .features: return "star.fill"
            case .credits: return "creditcard.fill"
            case .tools: return "hammer.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .features: return .purple
            case .credits: return Theme.primaryRed
            case .tools: return .blue
            }
        }
    }
    
    struct PurchaseItem: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let price: String
        let icon: String
        let category: PurchaseCategory
        let popular: Bool
        
        var color: Color {
            category.color
        }
    }
    
    let purchaseItems: [PurchaseItem] = [
        // Premium Features
        PurchaseItem(
            title: "Advanced Search Filters",
            description: "Unlock powerful search filters to find your perfect property faster",
            price: "$4.99",
            icon: "magnifyingglass.circle.fill",
            category: .features,
            popular: true
        ),
        PurchaseItem(
            title: "Property Price History",
            description: "View complete price history and market trends for any property",
            price: "$3.99",
            icon: "chart.line.uptrend.xyaxis.circle.fill",
            category: .features,
            popular: false
        ),
        PurchaseItem(
            title: "Neighborhood Analytics",
            description: "Get detailed insights about neighborhoods including schools, crime rates, and amenities",
            price: "$5.99",
            icon: "map.fill",
            category: .features,
            popular: true
        ),
        
        // Credit Packs
        PurchaseItem(
            title: "10 Contact Credits",
            description: "Reveal contact information for 10 property listings",
            price: "$9.99",
            icon: "person.crop.circle.fill",
            category: .credits,
            popular: false
        ),
        PurchaseItem(
            title: "25 Contact Credits",
            description: "Reveal contact information for 25 property listings",
            price: "$19.99",
            icon: "person.2.circle.fill",
            category: .credits,
            popular: true
        ),
        PurchaseItem(
            title: "50 Contact Credits",
            description: "Reveal contact information for 50 property listings",
            price: "$34.99",
            icon: "person.3.fill",
            category: .credits,
            popular: false
        ),
        
        // Pro Tools
        PurchaseItem(
            title: "Mortgage Calculator Pro",
            description: "Advanced mortgage calculator with custom interest rates and payment schedules",
            price: "$2.99",
            icon: "calculator.fill",
            category: .tools,
            popular: true
        ),
        PurchaseItem(
            title: "Property Comparison Tool",
            description: "Compare up to 5 properties side by side with detailed analytics",
            price: "$3.99",
            icon: "square.grid.3x3.fill",
            category: .tools,
            popular: false
        ),
        PurchaseItem(
            title: "Investment ROI Calculator",
            description: "Calculate potential return on investment for rental properties",
            price: "$4.99",
            icon: "dollarsign.circle.fill",
            category: .tools,
            popular: true
        )
    ]
    
    var filteredItems: [PurchaseItem] {
        purchaseItems.filter { $0.category == selectedCategory }
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "bag.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Theme.primaryRed)
                        .padding(.bottom, 8)
                    
                    Text("Enhance Your Experience")
                        .font(Theme.Typography.title)
                        .foregroundColor(Theme.textWhite)
                    
                    Text("Unlock premium features and tools to make your real estate journey even better")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.textWhite.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                .padding(.bottom, 24)
                
                // Category Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(PurchaseCategory.allCases) { category in
                            CategoryButton(
                                category: category,
                                isSelected: selectedCategory == category,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
                
                // Purchase Items
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredItems) { item in
                            PurchaseItemCard(item: item)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("In-App Purchases")
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

struct CategoryButton: View {
    let category: InAppPurchasesView.PurchaseCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: category.icon)
                    .font(.system(size: 14))
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .foregroundColor(isSelected ? .white : category.color)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? category.color : category.color.opacity(0.15))
            )
        }
    }
}

struct PurchaseItemCard: View {
    let item: InAppPurchasesView.PurchaseItem
    @State private var showingPurchaseConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                Image(systemName: item.icon)
                    .font(.system(size: 24))
                    .foregroundColor(item.color)
                    .frame(width: 40, height: 40)
                    .background(item.color.opacity(0.2))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.title)
                            .font(Theme.Typography.heading)
                            .foregroundColor(Theme.textWhite)
                        
                        if item.popular {
                            Text("Popular")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(item.color)
                                .cornerRadius(8)
                        }
                    }
                    
                    Text(item.description)
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.textWhite.opacity(0.7))
                        .lineLimit(2)
                }
                .padding(.leading, 4)
            }
            
            Button {
                showingPurchaseConfirmation = true
            } label: {
                HStack {
                    Text("Purchase")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(item.price)
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
                .padding()
                .foregroundColor(.white)
                .background(item.color)
                .cornerRadius(Theme.cornerRadius)
            }
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cornerRadius)
        .alert("Confirm Purchase", isPresented: $showingPurchaseConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Purchase") { }
        } message: {
            Text("Would you like to purchase \(item.title) for \(item.price)?")
        }
    }
}

#Preview {
    NavigationView {
        InAppPurchasesView()
            .environmentObject(LocalizationManager.shared)
    }
} 