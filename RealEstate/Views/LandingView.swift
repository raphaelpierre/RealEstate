//
//  LandingView.swift
//  RealEstate
//
//  Created by Raphael PIERRE on 15.01.2025.
//

import SwiftUI

enum PriceRange: String, CaseIterable {
    case all = "all_prices"
    case under200k = "under_200k"
    case under500k = "under_500k"
    case over500k = "over_500k"
    
    var range: ClosedRange<Double>? {
        switch self {
        case .all: return nil
        case .under200k: return 0...200_000
        case .under500k: return 200_001...500_000
        case .over500k: return 500_001...Double.infinity
        }
    }
    
    var localizedString: String {
        return self.rawValue.localized
    }
    
    // Get the localized string with the correct currency symbol
    func localizedStringWithCurrency(_ currencyManager: CurrencyManager) -> String {
        let isEuro = currencyManager.selectedCurrency == .eur
        let isCFA = currencyManager.selectedCurrency == .cfa
        
        switch self {
        case .all:
            return self.localizedString
        case .under200k:
            if isEuro {
                return "Moins de 200k€".localized
            } else if isCFA {
                return "Moins de 200k CFA".localized
            } else {
                return "Under $200k".localized
            }
        case .under500k:
            if isEuro {
                return "200k-500k€".localized
            } else if isCFA {
                return "200k-500k CFA".localized
            } else {
                return "$200k-$500k".localized
            }
        case .over500k:
            if isEuro {
                return "Plus de 500k€".localized
            } else if isCFA {
                return "Plus de 500k CFA".localized
            } else {
                return "Over $500k".localized
            }
        }
    }
}

enum PropertyType: String, CaseIterable {
    case all = "all_types"
    case house = "house"
    case apartment = "apartment"
    case villa = "villa"
    case land = "land"
    
    var localizedString: String {
        return self.rawValue.localized
    }
}

enum PropertyPurpose: String, CaseIterable {
    case all = "all_purpose"
    case buy = "buy"
    case rent = "rent"
    case seasonal = "seasonal"
    
    var localizedString: String {
        return self.rawValue.localized
    }
}

enum AreaRange: String, CaseIterable {
    case all = "any_size"
    case small = "small_area"
    case medium = "medium_area"
    case large = "large_area"
    case xlarge = "xlarge_area"
    
    var range: ClosedRange<Double>? {
        switch self {
        case .all: return nil
        case .small: return 0...100
        case .medium: return 100...200
        case .large: return 200...500
        case .xlarge: return 500...Double.infinity
        }
    }
    
    var localizedString: String {
        return self.rawValue.localized
    }
}

struct LandingView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var currencyManager: CurrencyManager
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
        @EnvironmentObject private var localizationManager: LocalizationManager
        
        var body: some View {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Theme.primaryRed)
                TextField("search_properties".localized, text: $searchText)
                    .foregroundColor(Theme.textWhite)
                    .accentColor(Theme.primaryRed)
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Theme.primaryRed)
                    }
                }
            }
            .padding()
            .background(Theme.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Theme.primaryRed.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(10)
            .id(localizationManager.refreshToggle)
        }
    }
    
    private struct FiltersView: View {
        @Binding var selectedPropertyType: PropertyType
        @Binding var selectedPurpose: PropertyPurpose
        @Binding var selectedBedrooms: Int?
        @Binding var showingFilters: Bool
        @EnvironmentObject private var localizationManager: LocalizationManager
        @EnvironmentObject private var currencyManager: CurrencyManager
        @State private var hoveredFilter: String?
        
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
                                    Text(type.localizedString)
                                    if selectedPropertyType == type {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(Theme.primaryRed)
                                    }
                                }
                                .foregroundColor(Theme.textWhite)
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedPropertyType.localizedString)
                            Image(systemName: "chevron.down")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                .fill(selectedPropertyType != .all ? Theme.primaryRed : Theme.cardBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                        .stroke(Theme.primaryRed, lineWidth: 1)
                                )
                        )
                        .foregroundColor(selectedPropertyType != .all ? Theme.textWhite : Theme.primaryRed)
                    }
                    .id(localizationManager.refreshToggle)
                    
                    // Purpose Filter
                    Menu {
                        ForEach(PropertyPurpose.allCases, id: \.self) { purpose in
                            Button {
                                selectedPurpose = purpose
                            } label: {
                                HStack {
                                    Text(purpose.localizedString)
                                    if selectedPurpose == purpose {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(Theme.primaryRed)
                                    }
                                }
                                .foregroundColor(Theme.textWhite)
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedPurpose.localizedString)
                            Image(systemName: "chevron.down")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                .fill(selectedPurpose != .all ? Theme.primaryRed : Theme.cardBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                        .stroke(Theme.primaryRed, lineWidth: 1)
                                )
                        )
                        .foregroundColor(selectedPurpose != .all ? Theme.textWhite : Theme.primaryRed)
                    }
                    .id(localizationManager.refreshToggle)
                    
                    // More Filters Button
                    Button {
                        showingFilters = true
                    } label: {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(Theme.primaryRed)
                            Text("more_filters".localized)
                                .foregroundColor(Theme.primaryRed)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                .fill(Theme.cardBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                        .stroke(Theme.primaryRed, lineWidth: 1)
                                )
                        )
                    }
                    .id(localizationManager.refreshToggle)
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
                AppBanner()
                    .padding(.top, 4)
                
                // Fixed Hero Section with Search and Filter Bar
                VStack(spacing: 12) {
                    SearchBarView(searchText: $searchText)
                        .padding(.horizontal)
                    
                    FiltersView(
                        selectedPropertyType: $selectedPropertyType,
                        selectedPurpose: $selectedPurpose,
                        selectedBedrooms: $selectedBedrooms,
                        showingFilters: $showingFilters
                    )
                }
                .padding(.vertical, 8)
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
            .environmentObject(currencyManager)
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
            Text("no_properties_found".localized)
                .font(Theme.Typography.heading)
                .foregroundColor(Theme.textWhite.opacity(0.8))
        }
        .padding(.top, 40)
        .id(localizationManager.refreshToggle)
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
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var currencyManager: CurrencyManager
    
    var body: some View {
        ZStack {
            Theme.backgroundBlack
                .ignoresSafeArea()
            
            VStack(spacing: Theme.padding) {
                // Currency Selection
                VStack(alignment: .leading, spacing: Theme.smallPadding) {
                    Text("select_currency".localized)
                        .font(Theme.Typography.heading)
                        .foregroundColor(Theme.textWhite)
                    
                    HStack(spacing: 12) {
                        ForEach(Currency.allCases) { currency in
                            Button(action: {
                                currencyManager.changeCurrency(to: currency)
                            }) {
                                HStack {
                                    Text(currency.symbol)
                                    Text(currency.name)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                        .fill(currencyManager.selectedCurrency == currency ? Theme.primaryRed : Theme.cardBackground)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                                .stroke(currencyManager.selectedCurrency == currency ? Theme.primaryRed : Color.clear, lineWidth: 1)
                                        )
                                )
                                .foregroundColor(Theme.textWhite)
                            }
                        }
                    }
                    
                    Text("currency_info".localized)
                        .font(.system(size: 14))
                        .foregroundColor(Theme.textWhite.opacity(0.7))
                        .padding(.top, 4)
                }
                .padding()
                .background(Theme.cardBackground)
                .cornerRadius(Theme.cornerRadius)
                .id(currencyManager.refreshToggle)
                
                // Price Range
                VStack(alignment: .leading, spacing: Theme.smallPadding) {
                    Text("price_range".localized)
                        .font(Theme.Typography.heading)
                        .foregroundColor(Theme.textWhite)
                    
                    ForEach(PriceRange.allCases, id: \.self) { range in
                        Button(action: { selectedPriceRange = range }) {
                            HStack {
                                Text(range.localizedString)
                                    .foregroundColor(Theme.textWhite)
                                Spacer()
                                if selectedPriceRange == range {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Theme.primaryRed)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                .fill(selectedPriceRange == range ? Theme.primaryRed.opacity(0.2) : Theme.cardBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                        .stroke(selectedPriceRange == range ? Theme.primaryRed : Color.clear, lineWidth: 1)
                                )
                        )
                    }
                }
                
                // Bedrooms
                VStack(alignment: .leading, spacing: Theme.smallPadding) {
                    Text("bedrooms".localized)
                        .font(Theme.Typography.heading)
                        .foregroundColor(Theme.textWhite)
                    
                    HStack {
                        ForEach(1...5, id: \.self) { number in
                            Button(action: { selectedBedrooms = number }) {
                                Text("\(number)")
                                    .font(Theme.Typography.body)
                                    .foregroundColor(selectedBedrooms == number ? Theme.textWhite : Theme.textWhite.opacity(0.6))
                                    .frame(width: 44, height: 44)
                                    .background(
                                        RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                            .fill(selectedBedrooms == number ? Theme.primaryRed : Theme.cardBackground)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                                    .stroke(selectedBedrooms == number ? Theme.primaryRed : Color.clear, lineWidth: 1)
                                            )
                                    )
                            }
                        }
                        
                        Button(action: { selectedBedrooms = nil }) {
                            Text("any".localized)
                                .font(Theme.Typography.body)
                                .foregroundColor(selectedBedrooms == nil ? Theme.textWhite : Theme.textWhite.opacity(0.6))
                                .frame(width: 44, height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                        .fill(selectedBedrooms == nil ? Theme.primaryRed : Theme.cardBackground)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                                .stroke(selectedBedrooms == nil ? Theme.primaryRed : Color.clear, lineWidth: 1)
                                        )
                                )
                        }
                    }
                }
                
                Spacer()
                
                // Apply Button
                Button(action: { dismiss() }) {
                    Text("apply_filters".localized)
                        .font(Theme.Typography.heading)
                        .foregroundColor(Theme.textWhite)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.primaryRed)
                        .cornerRadius(Theme.cornerRadius)
                }
                .id(localizationManager.refreshToggle)
            }
            .padding()
        }
        .toolbarBackground(Theme.backgroundBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("done".localized) {
                    dismiss()
                }
                .foregroundColor(Theme.primaryRed)
                .id(localizationManager.refreshToggle)
            }
        }
    }
}

struct FilterButton: View {
    let icon: String
    let text: String
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(text.localized)
            Image(systemName: "chevron.down")
        }
        .foregroundColor(Theme.textWhite)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cornerRadius)
        .id(localizationManager.refreshToggle)
    }
}

#Preview {
    NavigationView {
        LandingView()
            .environmentObject(FirebaseManager.shared)
            .environmentObject(AuthManager.shared)
            .environmentObject(LocalizationManager.shared)
            .environmentObject(CurrencyManager.shared)
    }
}
