//
//  LandingView.swift
//  RealEstate
//
//  Created by Raphael PIERRE on 15.01.2025.
//

import SwiftUI

enum PriceRange: String, CaseIterable {
    case all = "All Prices"
    case under500k = "Under $500k"
    case under1m = "Under $1M"
    case over1m = "Over $1M"
    
    var range: ClosedRange<Double>? {
        switch self {
        case .all: return nil
        case .under500k: return 0...500_000
        case .under1m: return 500_001...1_000_000
        case .over1m: return 1_000_001...Double.infinity
        }
    }
}

enum PropertyType: String, CaseIterable {
    case all = "All Types"
    case house = "House"
    case apartment = "Apartment"
    case villa = "Villa"
    case land = "Land"
}

enum PropertyPurpose: String, CaseIterable {
    case all = "All Purpose"
    case buy = "Buy"
    case rent = "Rent"
}

enum AreaRange: String, CaseIterable {
    case all = "Any Size"
    case small = "< 100m²"
    case medium = "100-200m²"
    case large = "200-500m²"
    case xlarge = "> 500m²"
    
    var range: ClosedRange<Double>? {
        switch self {
        case .all: return nil
        case .small: return 0...100
        case .medium: return 100...200
        case .large: return 200...500
        case .xlarge: return 500...Double.infinity
        }
    }
}

struct LandingView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @EnvironmentObject private var authManager: AuthManager
    @State private var showingLoginSheet = false
    @State private var selectedPriceRange: PriceRange = .all
    @State private var selectedPropertyType: PropertyType = .all
    @State private var selectedPurpose: PropertyPurpose = .all
    @State private var selectedAreaRange: AreaRange = .all
    @State private var selectedBedrooms: Int?
    @State private var showingFilters = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var searchText = ""
    
    private func applyPriceFilter(_ properties: [Property]) -> [Property] {
        guard let priceRange = selectedPriceRange.range else { return properties }
        return properties.filter { priceRange.contains($0.price) }
    }
    
    private func applyAreaFilter(_ properties: [Property]) -> [Property] {
        guard let areaRange = selectedAreaRange.range else { return properties }
        return properties.filter { areaRange.contains($0.area) }
    }
    
    private func applyBedroomsFilter(_ properties: [Property]) -> [Property] {
        guard let bedrooms = selectedBedrooms else { return properties }
        return properties.filter { $0.bedrooms == bedrooms }
    }
    
    private func applyTypeFilter(_ properties: [Property]) -> [Property] {
        guard selectedPropertyType != .all else { return properties }
        return properties.filter { $0.type == selectedPropertyType.rawValue }
    }
    
    private func applyPurposeFilter(_ properties: [Property]) -> [Property] {
        guard selectedPurpose != .all else { return properties }
        return properties.filter { $0.purpose == selectedPurpose.rawValue }
    }
    
    private func applySearchFilter(_ properties: [Property]) -> [Property] {
        guard !searchText.isEmpty else { return properties }
        return properties.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText) ||
            $0.address.localizedCaseInsensitiveContains(searchText) ||
            $0.city.localizedCaseInsensitiveContains(searchText) ||
            $0.country.localizedCaseInsensitiveContains(searchText) ||
            $0.zipCode.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private func applyAllFilters(_ properties: [Property]) -> [Property] {
        let step1 = applyPriceFilter(properties)
        let step2 = applyAreaFilter(step1)
        let step3 = applyBedroomsFilter(step2)
        let step4 = applyTypeFilter(step3)
        let step5 = applyPurposeFilter(step4)
        let step6 = applySearchFilter(step5)
        return step6
    }
    
    var filteredProperties: [Property] {
        applyAllFilters(firebaseManager.properties)
    }
    
    private func filterByPrice(properties: [Property]) -> [Property] {
        guard let range = selectedPriceRange.range else { return properties }
        return properties.filter { range.contains($0.price) }
    }
    
    private func filterByBedrooms(properties: [Property]) -> [Property] {
        guard let bedrooms = selectedBedrooms else { return properties }
        return properties.filter { $0.bedrooms == bedrooms }
    }
    
    private struct SearchBarView: View {
        @Binding var searchText: String
        
        var body: some View {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Theme.textWhite.opacity(0.6))
                TextField("Search properties...", text: $searchText)
                    .foregroundColor(Theme.textWhite)
                    .accentColor(Theme.primaryRed)
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Theme.textWhite.opacity(0.6))
                    }
                }
            }
            .padding()
            .background(Color.black.opacity(0.3))
            .cornerRadius(10)
        }
    }
    
    private struct FiltersView: View {
        @Binding var selectedPropertyType: PropertyType
        @Binding var selectedPurpose: PropertyPurpose
        @Binding var selectedBedrooms: Int?
        @Binding var showingFilters: Bool
        
        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Property Type Filter
                    Menu {
                        ForEach(PropertyType.allCases, id: \.self) { type in
                            Button {
                                selectedPropertyType = type
                            } label: {
                                HStack {
                                    Text(type.rawValue)
                                    if selectedPropertyType == type {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedPropertyType.rawValue)
                            Image(systemName: "chevron.down")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Theme.cardBackground)
                        .cornerRadius(Theme.cornerRadius)
                    }
                    
                    // Purpose Filter
                    Menu {
                        ForEach(PropertyPurpose.allCases, id: \.self) { purpose in
                            Button {
                                selectedPurpose = purpose
                            } label: {
                                HStack {
                                    Text(purpose.rawValue)
                                    if selectedPurpose == purpose {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedPurpose.rawValue)
                            Image(systemName: "chevron.down")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Theme.cardBackground)
                        .cornerRadius(Theme.cornerRadius)
                    }
                    
                    // More Filters Button
                    Button {
                        showingFilters = true
                    } label: {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                            Text("More Filters")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Theme.cardBackground)
                        .cornerRadius(Theme.cornerRadius)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundBlack
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Fixed Hero Section with Search and Filter Bar
                VStack(spacing: 16) {
                    SearchBarView(searchText: $searchText)
                        .padding(.horizontal)
                    
                    FiltersView(
                        selectedPropertyType: $selectedPropertyType,
                        selectedPurpose: $selectedPurpose,
                        selectedBedrooms: $selectedBedrooms,
                        showingFilters: $showingFilters
                    )
                }
                .padding(.vertical)
                .background(Theme.backgroundBlack)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                
                // Scrollable Content
                ScrollView {
                    // Properties Grid
                    if isLoading {
                        ProgressView()
                            .tint(Theme.primaryRed)
                            .padding()
                    } else if let error = errorMessage {
                        Text(error)
                            .foregroundColor(Theme.textWhite)
                            .padding()
                    } else {
                        if filteredProperties.isEmpty {
                            emptyStateView
                        } else {
                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 250, maximum: 350), spacing: 12)
                            ], spacing: 12) {
                                ForEach(filteredProperties) { property in
                                    NavigationLink(destination: PropertyDetailView(property: property)) {
                                        PropertyCard(property: property)
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .simultaneousGesture(TapGesture().onEnded {
                                        // Empty gesture to prevent navigation when tapping the heart
                                    })
                                    .id(property.id + (property.isFavorite ? "-fav" : ""))
                                }
                            }
                            .padding(Theme.smallPadding)
                        }
                    }
                }
            }
        }
        .toolbarBackground(Theme.backgroundBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showingFilters) {
            FilterView(
                selectedPriceRange: $selectedPriceRange,
                selectedBedrooms: $selectedBedrooms
            )
        }
        .alert(authManager.message, isPresented: $authManager.showMessage) {
            Button("OK", role: .cancel) { }
        }
        .sheet(isPresented: $showingLoginSheet) {
            LoginView()
        }
        .task {
            await loadProperties()
        }
        .refreshable {
            await loadProperties()
        }
    }
    
    private var loadingView: some View {
        ProgressView()
            .tint(Theme.primaryRed)
            .padding(.top, 40)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: Theme.padding) {
            Image(systemName: "house")
                .font(.system(size: 50))
                .foregroundColor(Theme.textWhite.opacity(0.6))
            Text("No properties available")
                .font(Theme.Typography.heading)
                .foregroundColor(Theme.textWhite.opacity(0.8))
        }
        .padding(.top, 40)
    }
    
    private var propertiesGrid: some View {
        LazyVGrid(columns: [
            GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 20)
        ], spacing: Theme.padding) {
            ForEach(filteredProperties) { property in
                NavigationLink(destination: PropertyDetailView(property: property)) {
                    PropertyCard(property: property)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
    }
    
    private func loadProperties() async {
        isLoading = true
        do {
            try await firebaseManager.fetchProperties()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedPriceRange: PriceRange
    @Binding var selectedBedrooms: Int?
    
    var body: some View {
        ZStack {
            Theme.backgroundBlack
                .ignoresSafeArea()
            
            VStack(spacing: Theme.padding) {
                // Price Range
                VStack(alignment: .leading, spacing: Theme.smallPadding) {
                    Text("Price Range")
                        .font(Theme.Typography.heading)
                        .foregroundColor(Theme.textWhite)
                    
                    ForEach(PriceRange.allCases, id: \.self) { range in
                        Button(action: { selectedPriceRange = range }) {
                            HStack {
                                Text(range.rawValue)
                                    .foregroundColor(Theme.textWhite)
                                Spacer()
                                if selectedPriceRange == range {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Theme.primaryRed)
                                }
                            }
                        }
                        .padding()
                        .background(Theme.cardBackground)
                        .cornerRadius(Theme.cornerRadius)
                    }
                }
                
                // Bedrooms
                VStack(alignment: .leading, spacing: Theme.smallPadding) {
                    Text("Bedrooms")
                        .font(Theme.Typography.heading)
                        .foregroundColor(Theme.textWhite)
                    
                    HStack {
                        ForEach(1...5, id: \.self) { number in
                            Button(action: { selectedBedrooms = number }) {
                                Text("\(number)")
                                    .font(Theme.Typography.body)
                                    .foregroundColor(selectedBedrooms == number ? Theme.textWhite : Theme.textWhite.opacity(0.6))
                                    .frame(width: 44, height: 44)
                                    .background(selectedBedrooms == number ? Theme.primaryRed : Theme.cardBackground)
                                    .cornerRadius(Theme.cornerRadius)
                            }
                        }
                        
                        Button(action: { selectedBedrooms = nil }) {
                            Text("Any")
                                .font(Theme.Typography.body)
                                .foregroundColor(selectedBedrooms == nil ? Theme.textWhite : Theme.textWhite.opacity(0.6))
                                .frame(width: 44, height: 44)
                                .background(selectedBedrooms == nil ? Theme.primaryRed : Theme.cardBackground)
                                .cornerRadius(Theme.cornerRadius)
                        }
                    }
                }
                
                Spacer()
                
                // Apply Button
                Button(action: { dismiss() }) {
                    Text("Apply Filters")
                        .font(Theme.Typography.heading)
                        .foregroundColor(Theme.textWhite)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.primaryRed)
                        .cornerRadius(Theme.cornerRadius)
                }
            }
            .padding()
        }
        .toolbarBackground(Theme.backgroundBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(Theme.primaryRed)
            }
        }
    }
}

struct FilterButton: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(text)
            Image(systemName: "chevron.down")
        }
        .foregroundColor(Theme.textWhite)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cornerRadius)
    }
}

#Preview {
    NavigationView {
        LandingView()
            .environmentObject(FirebaseManager.shared)
            .environmentObject(AuthManager.shared)
    }
}
