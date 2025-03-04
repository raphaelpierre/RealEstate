//
//  AdminView.swift
//  RealEstate
//
//  Created by Raphael PIERRE on 15.01.2025.
//

import SwiftUI

struct AdminView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var authManager: AuthManager
    @State private var showingAddProperty = false
    @State private var propertyToEdit: Property?
    @State private var showingDeleteAlert = false
    @State private var propertyToDelete: Property?
    @State private var isLoading = false
    @State private var error: Error?
    
    private var addPropertyButton: some View {
        Button {
            showingAddProperty = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                Text("Add Property")
                    .font(Theme.Typography.body)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Theme.cardBackground)
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Theme.primaryRed.opacity(0.3), lineWidth: 1)
            )
            .foregroundColor(Theme.primaryRed)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .padding(.bottom, 8)
    }
    
    private var propertyGrid: some View {
        LazyVGrid(columns: [
            GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 20)
        ], spacing: Theme.padding) {
            addPropertyButton
            
            ForEach(firebaseManager.properties) { property in
                PropertyCard(property: property)
                    .overlay(
                        AdminPropertyActions(
                            property: property,
                            propertyToEdit: $propertyToEdit,
                            showingDeleteAlert: $showingDeleteAlert,
                            propertyToDelete: $propertyToDelete
                        )
                    )
            }
        }
        .padding(.horizontal)
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundBlack
                .ignoresSafeArea()
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Theme.primaryRed)
                    .scaleEffect(1.5)
            } else {
                ScrollView {
                    VStack(spacing: Theme.padding) {
                        propertyGrid
                    }
                }
            }
        }
        .navigationTitle("Property Management")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddProperty) {
            NavigationView {
                AdminPropertyFormView(property: nil)
                    .environmentObject(firebaseManager)
                    .environmentObject(localizationManager)
                    .environmentObject(authManager)
            }
        }
        .sheet(item: $propertyToEdit) { property in
            NavigationView {
                AdminPropertyFormView(property: property)
                    .environmentObject(firebaseManager)
                    .environmentObject(localizationManager)
                    .environmentObject(authManager)
            }
        }
        .alert("Delete Property", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let propertyToDelete {
                    Task {
                        isLoading = true
                        do {
                            try await firebaseManager.deleteProperty(propertyToDelete)
                            self.propertyToDelete = nil
                        } catch {
                            self.error = error
                        }
                        isLoading = false
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this property? This action cannot be undone.")
        }
        .alert("Error", isPresented: .init(
            get: { error != nil },
            set: { if !$0 { error = nil } }
        )) {
            Button("OK") { error = nil }
        } message: {
            if let error {
                Text(error.localizedDescription)
            }
        }
        .task {
            isLoading = true
            do {
                try await firebaseManager.fetchProperties()
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
}

// MARK: - Admin Property Actions View
struct AdminPropertyActions: View {
    let property: Property
    @Binding var propertyToEdit: Property?
    @Binding var showingDeleteAlert: Bool
    @Binding var propertyToDelete: Property?
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Menu {
                    Button {
                        propertyToEdit = property
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        propertyToDelete = property
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.title2)
                        .foregroundColor(Theme.primaryRed)
                        .padding(8)
                        .background(Theme.cardBackground)
                        .clipShape(Circle())
                }
            }
            .padding(8)
            
            Spacer()
        }
    }
}

// MARK: - Edit Button View
struct EditButton: View {
    let property: Property
    @Binding var propertyToEdit: Property?
    
    var body: some View {
        Button {
            propertyToEdit = property
        } label: {
            HStack {
                Image(systemName: "pencil")
                Text("Edit")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Theme.primaryRed)
            .foregroundColor(Theme.textWhite)
            .cornerRadius(Theme.cornerRadius)
            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Delete Button View
struct DeleteButton: View {
    let property: Property
    @Binding var showingDeleteAlert: Bool
    @Binding var propertyToDelete: Property?
    
    var body: some View {
        Button {
            propertyToDelete = property
            showingDeleteAlert = true
        } label: {
            HStack {
                Image(systemName: "trash")
                Text("Delete")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.red)
            .foregroundColor(Theme.textWhite)
            .cornerRadius(Theme.cornerRadius)
            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct PropertyAdminRow: View {
    let property: Property
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(property.title)
                .font(Theme.Typography.heading)
                .foregroundColor(Theme.textWhite)
            Text(property.address)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.textWhite.opacity(0.8))
            Text("$\(Int(property.price))")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.primaryRed)
        }
        .padding(.vertical, Theme.smallPadding)
        .listRowBackground(Theme.cardBackground)
    }
}

// MARK: - Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    AdminView()
        .environmentObject(FirebaseManager.shared)
}
