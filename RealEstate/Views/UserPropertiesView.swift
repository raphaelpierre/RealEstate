import SwiftUI

struct UserPropertiesView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var showingAddProperty = false
    @State private var propertyToEdit: Property?
    @State private var showingDeleteAlert = false
    @State private var propertyToDelete: Property?
    @State private var isLoading = false
    @State private var error: Error?
    
    private var userProperties: [Property] {
        guard let userId = authManager.currentUser?.id else { return [] }
        return firebaseManager.properties.filter { property in
            property.userId == userId
        }
    }
    
    private var addPropertyButton: some View {
        Button {
            showingAddProperty = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                Text("add_property".localized)
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
            
            ForEach(userProperties) { property in
                PropertyCard(property: property)
                    .overlay(
                        UserPropertyActions(
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
                        // Header
                        Text("my_properties".localized)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Theme.textWhite)
                            .padding(.top)
                        
                        propertyGrid
                    }
                }
            }
        }
        .navigationTitle("my_properties".localized)
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
        .alert("delete_property".localized, isPresented: $showingDeleteAlert) {
            Button("cancel".localized, role: .cancel) { }
            Button("delete".localized, role: .destructive) {
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
        .alert("error".localized, isPresented: .init(
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

// MARK: - User Property Actions View
struct UserPropertyActions: View {
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
                        Label("edit".localized, systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        propertyToDelete = property
                        showingDeleteAlert = true
                    } label: {
                        Label("delete".localized, systemImage: "trash")
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

#Preview {
    UserPropertiesView()
        .environmentObject(FirebaseManager.shared)
        .environmentObject(AuthManager.shared)
        .environmentObject(LocalizationManager.shared)
} 