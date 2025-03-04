import SwiftUI
import Charts

struct AnalyticsDashboardView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var currencyManager: CurrencyManager
    
    // Analytics Data
    private var totalProperties: Int {
        firebaseManager.properties.count
    }
    
    private var propertiesByType: [(type: String, count: Int)] {
        let types = Dictionary(grouping: firebaseManager.properties) { $0.type }
        return types.map { (type: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }
    
    private var propertiesByPurpose: [(purpose: String, count: Int)] {
        let purposes = Dictionary(grouping: firebaseManager.properties) { $0.purpose }
        return purposes.map { (purpose: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }
    
    private var averagePrice: Double {
        guard !firebaseManager.properties.isEmpty else { return 0 }
        let total = firebaseManager.properties.reduce(0) { $0 + $1.price }
        return total / Double(firebaseManager.properties.count)
    }
    
    private var priceRange: (min: Double, max: Double) {
        let prices = firebaseManager.properties.map { $0.price }
        return (min: prices.min() ?? 0, max: prices.max() ?? 0)
    }
    
    private var averageBedrooms: Double {
        guard !firebaseManager.properties.isEmpty else { return 0 }
        let total = firebaseManager.properties.reduce(0) { $0 + $1.bedrooms }
        return Double(total) / Double(firebaseManager.properties.count)
    }
    
    private var averageBathrooms: Double {
        guard !firebaseManager.properties.isEmpty else { return 0 }
        let total = firebaseManager.properties.reduce(0) { $0 + $1.bathrooms }
        return Double(total) / Double(firebaseManager.properties.count)
    }
    
    private var averageArea: Double {
        guard !firebaseManager.properties.isEmpty else { return 0 }
        let total = firebaseManager.properties.reduce(0) { $0 + $1.area }
        return total / Double(firebaseManager.properties.count)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.padding) {
                // Overview Cards
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: Theme.padding) {
                    StatCard(
                        title: "total_properties".localized,
                        value: "\(totalProperties)",
                        icon: "building.2.fill"
                    )
                    
                    StatCard(
                        title: "average_price".localized,
                        value: currencyManager.formatPrice(averagePrice),
                        icon: "dollarsign.circle.fill"
                    )
                    
                    StatCard(
                        title: "average_bedrooms".localized,
                        value: String(format: "%.1f", averageBedrooms),
                        icon: "bed.double.fill"
                    )
                    
                    StatCard(
                        title: "average_bathrooms".localized,
                        value: String(format: "%.1f", averageBathrooms),
                        icon: "shower.fill"
                    )
                }
                
                // Property Types Chart
                VStack(alignment: .leading, spacing: Theme.smallPadding) {
                    Text("property_types".localized)
                        .font(Theme.Typography.heading)
                        .foregroundColor(Theme.textWhite)
                    
                    Chart(propertiesByType, id: \.type) { item in
                        BarMark(
                            x: .value("Type", item.type),
                            y: .value("Count", item.count)
                        )
                        .foregroundStyle(Theme.primaryRed)
                    }
                    .frame(height: 200)
                    .padding()
                    .background(Theme.cardBackground)
                    .cornerRadius(Theme.cornerRadius)
                }
                
                // Property Purposes Chart
                VStack(alignment: .leading, spacing: Theme.smallPadding) {
                    Text("property_purposes".localized)
                        .font(Theme.Typography.heading)
                        .foregroundColor(Theme.textWhite)
                    
                    Chart(propertiesByPurpose, id: \.purpose) { item in
                        SectorMark(
                            angle: .value("Count", item.count),
                            innerRadius: .ratio(0.618),
                            angularInset: 1.5
                        )
                        .foregroundStyle(Theme.primaryRed)
                    }
                    .frame(height: 200)
                    .padding()
                    .background(Theme.cardBackground)
                    .cornerRadius(Theme.cornerRadius)
                }
                
                // Price Distribution
                VStack(alignment: .leading, spacing: Theme.smallPadding) {
                    Text("price_distribution".localized)
                        .font(Theme.Typography.heading)
                        .foregroundColor(Theme.textWhite)
                    
                    VStack(spacing: Theme.smallPadding) {
                        FeatureRow(
                            title: "min_price".localized,
                            value: currencyManager.formatPrice(priceRange.min)
                        )
                        
                        FeatureRow(
                            title: "max_price".localized,
                            value: currencyManager.formatPrice(priceRange.max)
                        )
                    }
                    .padding()
                    .background(Theme.cardBackground)
                    .cornerRadius(Theme.cornerRadius)
                }
                
                // Property Features
                VStack(alignment: .leading, spacing: Theme.smallPadding) {
                    Text("property_features".localized)
                        .font(Theme.Typography.heading)
                        .foregroundColor(Theme.textWhite)
                    
                    VStack(spacing: Theme.smallPadding) {
                        FeatureRow(
                            title: "average_area".localized,
                            value: String(format: "%.1f m²", averageArea)
                        )
                        
                        FeatureRow(
                            title: "average_bedrooms".localized,
                            value: String(format: "%.1f", averageBedrooms)
                        )
                        
                        FeatureRow(
                            title: "average_bathrooms".localized,
                            value: String(format: "%.1f", averageBathrooms)
                        )
                    }
                    .padding()
                    .background(Theme.cardBackground)
                    .cornerRadius(Theme.cornerRadius)
                }
            }
            .padding()
        }
        .navigationTitle("analytics_dashboard".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.backgroundBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Helper Views
private struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.smallPadding) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(Theme.primaryRed)
                
                Text(title)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.textWhite.opacity(0.7))
            }
            
            Text(value)
                .font(Theme.Typography.heading)
                .foregroundColor(Theme.textWhite)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cornerRadius)
    }
}

private struct FeatureRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.textWhite.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.textWhite)
        }
    }
}

#Preview {
    NavigationView {
        AnalyticsDashboardView()
            .environmentObject(FirebaseManager.shared)
            .environmentObject(LocalizationManager.shared)
            .environmentObject(CurrencyManager.shared)
    }
} 