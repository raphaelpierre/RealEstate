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
    @State private var searchText = ""
    @State private var showingLoginSheet = false
    @State private var selectedPriceRange: PriceRange = .all
    @State private var selectedBedrooms: Int?
    @State private var showingFilters = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var filteredProperties: [Property] {
        var filtered = firebaseManager.properties
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { property in
                property.title.localizedCaseInsensitiveContains(searchText) ||
                property.description.localizedCaseInsensitiveContains(searchText) ||
                property.address.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply price range filter
        if let range = selectedPriceRange.range {
            filtered = filtered.filter { range.contains($0.price) }
        }
        
        // Apply bedrooms filter
        if let bedrooms = selectedBedrooms {
            filtered = filtered.filter { $0.bedrooms == bedrooms }
        }
        
        return filtered
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Section
                heroSection
                
                // Filters Section
                filtersSection
                
                if isLoading {
                    ProgressView()
                        .padding(.top, 40)
                } else if firebaseManager.properties.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "house")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No properties available")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)
                } else {
                    // Properties Grid
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 20)
                    ], spacing: 20) {
                        ForEach(filteredProperties) { property in
                            PropertyCard(property: property)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !authManager.isAuthenticated {
                    Button("Sign In") {
                        showingLoginSheet = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingLoginSheet) {
            LoginView()
        }
        .sheet(isPresented: $showingFilters) {
            FilterView(selectedPriceRange: $selectedPriceRange,
                      selectedBedrooms: $selectedBedrooms)
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
        .task {
            await loadProperties()
        }
        .refreshable {
            await loadProperties()
        }
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
    
    private var heroSection: some View {
        ZStack {
            // Background Image
            Image(systemName: "house.fill")
                .resizable()
                .scaledToFill()
                .frame(height: 400)
                .clipped()
                .overlay(Color.black.opacity(0.4))
            
            VStack(spacing: 20) {
                Text("Find Your Dream Home")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Explore our curated selection of premium properties")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search properties...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .padding()
        }
    }
    
    private var filtersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(PriceRange.allCases, id: \.self) { range in
                    Button(action: {
                        selectedPriceRange = range
                    }) {
                        Text(range.rawValue)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedPriceRange == range ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedPriceRange == range ? .white : .primary)
                            .cornerRadius(20)
                    }
                }
                
                Button(action: {
                    showingFilters = true
                }) {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                        Text("More Filters")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(20)
                }
            }
            .padding()
        }
    }
}

struct PropertyCard: View {
    let property: Property
    
    var body: some View {
        NavigationLink(destination: PropertyDetailView(property: property)) {
            VStack(alignment: .leading, spacing: 8) {
                // Property Image
                if let firstImage = property.imageURLs.first {
                    AsyncImage(url: URL(string: firstImage)) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .foregroundColor(.gray.opacity(0.2))
                                .overlay(ProgressView())
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure(_):
                            Rectangle()
                                .foregroundColor(.gray.opacity(0.2))
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(property.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(property.address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Text("$\(Int(property.price))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    HStack(spacing: 15) {
                        Label("\(property.bedrooms)", systemImage: "bed.double")
                        Label("\(property.bathrooms)", systemImage: "shower")
                        Label("\(Int(property.area))m²", systemImage: "square")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 12)
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 5)
        }
    }
}

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedPriceRange: PriceRange
    @Binding var selectedBedrooms: Int?
    
    var body: some View {
        NavigationView {
            Form {
                Section("Price Range") {
                    Picker("Price Range", selection: $selectedPriceRange) {
                        ForEach(PriceRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Bedrooms") {
                    ForEach([nil] + Array(1...5), id: \.self) { number in
                        HStack {
                            Text(number == nil ? "Any" : "\(number!)")
                            Spacer()
                            if selectedBedrooms == number {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedBedrooms = number
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
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
