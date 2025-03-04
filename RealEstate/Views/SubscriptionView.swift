import SwiftUI

struct SubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var selectedPlan: SubscriptionPlan = .monthly
    
    enum SubscriptionPlan: String, CaseIterable, Identifiable {
        case monthly = "Monthly"
        case yearly = "Yearly"
        case lifetime = "Lifetime"
        
        var id: String { self.rawValue }
        
        var price: String {
            switch self {
            case .monthly: return "$9.99/month"
            case .yearly: return "$89.99/year"
            case .lifetime: return "$249.99"
            }
        }
        
        var savings: String? {
            switch self {
            case .yearly: return "Save 25%"
            case .lifetime: return "Best value"
            default: return nil
            }
        }
        
        var features: [String] {
            [
                "Unlimited property listings",
                "Featured placement in search results",
                "Advanced analytics dashboard",
                "Priority customer support",
                "No advertisements"
            ]
        }
        
        var additionalFeatures: [String] {
            switch self {
            case .yearly:
                return ["Virtual staging tools"]
            case .lifetime:
                return ["Virtual staging tools", "Custom branding options", "API access"]
            default:
                return []
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
                        Text("Premium Subscription")
                            .font(Theme.Typography.title)
                            .foregroundColor(Theme.textWhite)
                        
                        Text("Unlock premium features to boost your real estate business")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.textWhite.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    
                    // Plan Selection
                    VStack(spacing: 16) {
                        ForEach(SubscriptionPlan.allCases) { plan in
                            SubscriptionPlanCard(
                                plan: plan,
                                isSelected: selectedPlan == plan,
                                action: { selectedPlan = plan }
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Premium Features")
                            .font(Theme.Typography.heading)
                            .foregroundColor(Theme.textWhite)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(selectedPlan.features, id: \.self) { feature in
                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Theme.primaryRed)
                                    
                                    Text(feature)
                                        .font(Theme.Typography.body)
                                        .foregroundColor(Theme.textWhite)
                                }
                            }
                            
                            ForEach(selectedPlan.additionalFeatures, id: \.self) { feature in
                                HStack(spacing: 12) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(Theme.primaryRed)
                                    
                                    Text(feature)
                                        .font(Theme.Typography.body)
                                        .foregroundColor(Theme.primaryRed)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Theme.cardBackground)
                    .cornerRadius(Theme.cornerRadius)
                    .padding(.horizontal)
                    
                    // Subscribe Button
                    Button {
                        // Handle subscription purchase
                    } label: {
                        Text("Subscribe Now")
                            .font(Theme.Typography.heading)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.primaryRed)
                            .cornerRadius(Theme.cornerRadius)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Terms
                    Text("Subscription will automatically renew unless auto-renew is turned off at least 24 hours before the end of the current period. You can manage your subscriptions in your account settings.")
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
        .navigationTitle("Premium Plans")
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

struct SubscriptionPlanCard: View {
    let plan: SubscriptionView.SubscriptionPlan
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.rawValue)
                        .font(Theme.Typography.heading)
                        .foregroundColor(Theme.textWhite)
                    
                    Text(plan.price)
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.textWhite.opacity(0.8))
                    
                    if let savings = plan.savings {
                        Text(savings)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.primaryRed)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Theme.primaryRed.opacity(0.2))
                            .cornerRadius(12)
                    }
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? Theme.primaryRed : Theme.textWhite.opacity(0.5))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .fill(Theme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.cornerRadius)
                            .stroke(isSelected ? Theme.primaryRed : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        SubscriptionView()
            .environmentObject(LocalizationManager.shared)
    }
} 