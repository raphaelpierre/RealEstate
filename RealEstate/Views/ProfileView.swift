import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @EnvironmentObject private var authManager: AuthManager
    @State private var showingAdminView = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingLoginSheet = false
    
    var body: some View {
        ZStack {
            Theme.backgroundBlack
                .ignoresSafeArea()
            
            if authManager.isAuthenticated {
                VStack(spacing: Theme.padding) {
                    // Profile Header
                    VStack(spacing: Theme.smallPadding) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Theme.primaryRed)
                        
                        if let email = authManager.currentUser?.email {
                            Text(email)
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.textWhite)
                        }
                    }
                    .padding(.top, Theme.padding)
                    
                    // Menu Options
                    VStack(spacing: Theme.smallPadding) {
                        if authManager.isAdmin {
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
                        }
                        
                        NavigationLink {
                            FavoritesView()
                        } label: {
                            ProfileMenuButton(
                                icon: "heart.fill",
                                text: "Favorites",
                                description: "View your favorite properties"
                            )
                        }
                        
                        Button {
                            signOut()
                        } label: {
                            ProfileMenuButton(
                                icon: "rectangle.portrait.and.arrow.right",
                                text: "Sign Out",
                                description: "Sign out of your account"
                            )
                        }
                    }
                    .padding(.top, Theme.padding)
                    
                    Spacer()
                }
                .padding()
            } else {
                VStack(spacing: Theme.padding) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Theme.primaryRed)
                    
                    Text("Not Signed In")
                        .font(Theme.Typography.heading)
                        .foregroundColor(Theme.textWhite)
                    
                    Button("Sign In") {
                        showingLoginSheet = true
                    }
                    .foregroundColor(Theme.primaryRed)
                    .padding()
                    .background(Theme.cardBackground)
                    .cornerRadius(Theme.cornerRadius)
                }
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
        .sheet(isPresented: $showingLoginSheet) {
            LoginView()
        }
        .alert("Profile", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func signOut() {
        do {
            try authManager.signOut()
            alertMessage = "Successfully signed out"
            showingAlert = true
        } catch {
            alertMessage = "Error signing out: \(error.localizedDescription)"
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
            
            VStack(alignment: .leading, spacing: 2) {
                Text(text)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.textWhite)
                
                Text(description)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.textWhite.opacity(0.6))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Theme.textWhite.opacity(0.6))
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cornerRadius)
    }
}