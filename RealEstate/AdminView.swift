//
//  AdminView.swift
//  RealEstate
//
//  Created by Raphael PIERRE on 15.01.2025.
//

import SwiftUI

struct AdminView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @State private var showingAddProperty = false
    @State private var propertyToEdit: Property?
    @State private var showingDeleteAlert = false
    @State private var propertyToDelete: Property?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(firebaseManager.properties) { property in
                    PropertyAdminRow(property: property)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                propertyToDelete = property
                                showingDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                propertyToEdit = property
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                }
            }
            .navigationTitle("Admin Panel")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddProperty = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddProperty) {
                AdminPropertyFormView()
            }
            .sheet(item: $propertyToEdit) { property in
                AdminPropertyFormView(property: property)
            }
            .alert("Delete Property", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let property = propertyToDelete {
                        Task {
                            try? await firebaseManager.deleteProperty(property)
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to delete this property? This action cannot be undone.")
            }
        }
    }
}

struct PropertyAdminRow: View {
    let property: Property
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(property.title)
                .font(.headline)
            Text(property.address)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("$\(Int(property.price))")
                .font(.subheadline)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AdminView()
        .environmentObject(FirebaseManager.shared)
}
