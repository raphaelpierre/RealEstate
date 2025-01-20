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

struct LandingView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @EnvironmentObject private var authManager: AuthManager
    @State private var showingLoginSheet = false
    @State private var selectedPriceRange: PriceRange = .all
    @State private var selectedBedrooms: Int?
    @State private var showingFilters = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var filteredProperties: [Property] {
        let filtered = filterByPrice(properties: firebaseManager.properties)
        return filterByBedrooms(properties: filtered)
    }
    
    private func filterByPrice(properties: [Property]) -> [Property] {
        guard let range = selectedPriceRange.range else { return properties }
        return properties.filter { range.contains($0.price) }
    }
    
    private func filterByBedrooms(properties: [Property]) -> [Property] {
        guard let bedrooms = selectedBedrooms else { return properties }
        return properties.filter { $0.bedrooms == bedrooms }
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundBlack
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Fixed Hero Section with Filter Bar
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        Text("Filter by:")
                            .foregroundColor(Theme.textWhite)
                            .font(.system(size: 14, weight: .medium))
                        
                        Menu {
                            ForEach(PriceRange.allCases, id: \.self) { range in
                                Button {
                                    selectedPriceRange = range
                                } label: {
                                    HStack {
                                        Text(range.rawValue)
                                        if selectedPriceRange == range {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedPriceRange.rawValue)
                                Image(systemName: "chevron.down")
                            }
                            .foregroundColor(Theme.textWhite)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(6)
                        }
                        
                        Menu {
                            Button {
                                selectedBedrooms = nil
                            } label: {
                                HStack {
                                    Text("Any")
                                    if selectedBedrooms == nil {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            ForEach(1...5, id: \.self) { count in
                                Button {
                                    selectedBedrooms = count
                                } label: {
                                    HStack {
                                        Text("\(count) \(count == 1 ? "Bedroom" : "Bedrooms")")
                                        if selectedBedrooms == count {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedBedrooms.map { "\($0) \($0 == 1 ? "Bedroom" : "Bedrooms")" } ?? "Bedrooms")
                                Image(systemName: "chevron.down")
                            }
                            .foregroundColor(Theme.textWhite)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(6)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 10)
                }
                .background(Color.black)
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
            FilterView(selectedPriceRange: $selectedPriceRange, selectedBedrooms: $selectedBedrooms)
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

#Preview {
    NavigationView {
        LandingView()
            .environmentObject(FirebaseManager.shared)
            .environmentObject(AuthManager.shared)
    }
}
