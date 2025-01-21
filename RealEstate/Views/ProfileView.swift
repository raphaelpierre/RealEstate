import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @EnvironmentObject private var authManager: AuthManager
    @State private var showingAdminView = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private var profileHeader: some View {
        VStack(spacing: Theme.padding) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(Theme.primaryRed)
            
            if let email = authManager.currentUser?.email {
                Text(email)
                    .font(Theme.Typography.heading)
                    .foregroundColor(Theme.textWhite)
            }
        }
        .padding(.vertical, Theme.padding)
        .frame(maxWidth: .infinity)
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cornerRadius)
    }
    
    private var menuSection: some View {
        VStack(alignment: .leading, spacing: Theme.padding * 1.5) {
            Text("Menu")
                .font(Theme.Typography.heading)
                .foregroundColor(Theme.textWhite)
                .fontWeight(.semibold)
            
            VStack(spacing: Theme.padding) {
                // Section 1: Admin Tools (if applicable)
                if authManager.isAdmin {
                    Section {
                        NavigationLink {
                            AdminView()
                                .environmentObject(firebaseManager)
                        } label: {
                            ProfileMenuButton(
                                icon: "building.2",
                                text: "Property Management",
                                description: "Add, edit, or remove properties"
                            )
                        }
                    } header: {
                        Text("Admin Tools")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.bottom, Theme.smallPadding)
                    }
                }
                
                // Section 2: User Actions
                Section {
                    NavigationLink {
                        FavoritesView()
                    } label: {
                        ProfileMenuButton(
                            icon: "heart.fill",
                            text: "Favorites",
                            description: "View your favorite properties"
                        )
                    }
                } header: {
                    Text("My Account")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, Theme.smallPadding)
                }
                
                // Section 3: Session Management
                Section {
                    Button {
                        Task {
                            await signOut()
                        }
                    } label: {
                        ProfileMenuButton(
                            icon: "rectangle.portrait.and.arrow.right",
                            text: "Sign Out",
                            description: "Sign out of your account"
                        )
                    }
                } header: {
                    Text("Session")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, Theme.smallPadding)
                }
            }
            .padding(Theme.padding)
            .background(Theme.cardBackground)
            .cornerRadius(Theme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .stroke(Theme.primaryRed.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundBlack
                .ignoresSafeArea()
            
            if authManager.isAuthenticated {
                ScrollView {
                    VStack(spacing: Theme.padding) {
                        profileHeader
                        menuSection
                    }
                    .padding()
                }
            } else {
                LoginView()
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.backgroundBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Profile")
                    .font(Theme.Typography.heading)
                    .foregroundColor(Theme.textWhite)
            }
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func signOut() async {
        do {
            try await authManager.signOut()
        } catch {
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
}

struct ProfileMenuButton: View {
    let icon: String
    let text: String
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Theme.primaryRed)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(text)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.textWhite)
                
                Text(description)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.textWhite.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Theme.primaryRed)
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cornerRadius)
    }
}