import SwiftUI
import FirebaseAuth
import GoogleSignInSwift

struct ProfileView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var currencyManager: CurrencyManager
    @State private var showingAdminView = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showLanguageOptions = false
    @State private var alertType = AlertType.error
    @State private var isUpdatingLocations = false
    @State private var selectedLanguage = Locale.current.language.languageCode?.identifier ?? "en"
    @State private var properties: [Property] = []
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showingLanguageRestartAlert = false
    
    private let languages = [
        Language(code: "en", name: "English"),
        Language(code: "fr", name: "Français")
    ]
    
    private struct Language: Identifiable {
        let id = UUID()
        let code: String
        let name: String
    }
    
    private enum AlertType {
        case error
        case confirmation
    }
    
    private var currentLanguage: String {
        Locale.current.language.languageCode?.identifier ?? "en"
    }
    
    private var profileHeader: some View {
        VStack(spacing: Theme.smallPadding) {
            if let user = authManager.currentUser {
                if let photoURLString = user.photoURL, let photoURL = URL(string: photoURLString) {
                    // User has a profile photo from Google
                    AsyncImage(url: photoURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 70, height: 70)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 70, height: 70)
                                .clipShape(Circle())
                        case .failure:
                            defaultProfileImage
                        @unknown default:
                            defaultProfileImage
                        }
                    }
                } else {
                    // No profile photo, show default icon with Google logo if available
                    ZStack {
                        defaultProfileImage
                        
                        if let firebaseUser = Auth.auth().currentUser,
                           let providerID = firebaseUser.providerData.first?.providerID,
                           providerID == GoogleAuthProviderID {
                            Image("google_logo")
                .resizable()
                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .offset(x: 25, y: 25)
                        }
                    }
                }
            } else {
                // No user, show default icon
                defaultProfileImage
            }
            
            if let email = authManager.currentUser?.email {
                Text(email)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.textWhite.opacity(0.7))
                    .padding(.bottom, Theme.smallPadding / 2)
            }
        }
        .padding(.vertical, Theme.smallPadding / 2)
        .frame(maxWidth: .infinity)
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cornerRadius)
    }
    
    private var defaultProfileImage: some View {
        Image(systemName: "person.circle.fill")
            .font(.system(size: 70))
            .foregroundColor(Theme.primaryRed)
            .padding(.top, Theme.smallPadding / 2)
    }
    
    private var propertyManagementSection: some View {
        VStack(alignment: .leading, spacing: Theme.smallPadding / 2) {
            Text("property_management".localized)
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.bottom, Theme.smallPadding / 4)
            
            NavigationLink {
                AdminPropertyFormView(property: nil)
                    .environmentObject(firebaseManager)
                    .environmentObject(authManager)
            } label: {
                ProfileMenuButton(
                    icon: "plus.circle.fill",
                    text: "add_property".localized,
                    description: "add_property_description".localized,
                    compact: true
                )
            }
            
            NavigationLink {
                AdminView()
                    .environmentObject(firebaseManager)
            } label: {
                ProfileMenuButton(
                    icon: "list.bullet",
                    text: "manage_properties".localized,
                    description: "manage_properties_description".localized,
                    compact: true
                )
            }
        }
        .padding(Theme.smallPadding)
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cornerRadius)
    }
    
    private var menuSection: some View {
        VStack(alignment: .leading, spacing: Theme.smallPadding) {
            Text("menu".localized)
                .font(Theme.Typography.heading)
                .foregroundColor(Theme.textWhite)
                .fontWeight(.semibold)
                .padding(.bottom, Theme.smallPadding / 4)
            
            VStack(spacing: Theme.smallPadding / 2) {
                // Section 1: Property Management (for all users)
                VStack(alignment: .leading, spacing: Theme.smallPadding / 2) {
                    Text("property_management".localized)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, Theme.smallPadding / 4)
                    
                    NavigationLink {
                        AdminPropertyFormView(property: nil)
                            .environmentObject(firebaseManager)
                            .environmentObject(authManager)
                    } label: {
                        ProfileMenuButton(
                            icon: "plus.circle.fill",
                            text: "add_property".localized,
                            description: "add_property_description".localized,
                            compact: true
                        )
                    }
                    
                    NavigationLink {
                        UserPropertiesView()
                            .environmentObject(firebaseManager)
                            .environmentObject(authManager)
                    } label: {
                        ProfileMenuButton(
                            icon: "list.bullet",
                            text: "my_properties".localized,
                            description: "manage_my_properties_description".localized,
                            compact: true
                        )
                    }
                    
                if authManager.isAdmin {
                        NavigationLink {
                            AdminView()
                                .environmentObject(firebaseManager)
                        } label: {
                            ProfileMenuButton(
                                icon: "building.2",
                                text: "manage_all_properties".localized,
                                description: "manage_all_properties_description".localized,
                                compact: true
                            )
                        }
                    }
                }
                .padding(Theme.smallPadding)
                .background(Theme.cardBackground)
                .cornerRadius(Theme.cornerRadius)
                
                // Section 2: Admin Tools (if applicable)
                if authManager.isAdmin {
                    VStack(alignment: .leading, spacing: Theme.smallPadding / 2) {
                        Text("admin_section".localized)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.bottom, Theme.smallPadding / 4)
                        
                        NavigationLink {
                            UserManagementView()
                                .environmentObject(firebaseManager)
                                .environmentObject(authManager)
                                .environmentObject(localizationManager)
                        } label: {
                            ProfileMenuButton(
                                icon: "person.2",
                                text: "user_management".localized,
                                description: "user_management_description".localized,
                                compact: true
                            )
                        }
                        
                        NavigationLink {
                            // This would navigate to a system settings view
                            // Replace with actual view when implemented
                            Text("System Settings View")
                                .environmentObject(firebaseManager)
                        } label: {
                            ProfileMenuButton(
                                icon: "gearshape.2",
                                text: "system_settings".localized,
                                description: "system_settings_description".localized,
                                compact: true
                            )
                        }
                        
                        NavigationLink {
                            // This would navigate to an admin dashboard
                            // Replace with actual view when implemented
                            AnalyticsDashboardView()
                                .environmentObject(firebaseManager)
                                .environmentObject(localizationManager)
                                .environmentObject(currencyManager)
                        } label: {
                            ProfileMenuButton(
                                icon: "chart.bar.xaxis",
                                text: "analytics_dashboard".localized,
                                description: "analytics_dashboard_description".localized,
                                compact: true
                            )
                        }
                    }
                    .padding(Theme.smallPadding)
                    .background(Theme.cardBackground)
                    .cornerRadius(Theme.cornerRadius)
                }
                
                // Section 3: User Actions
                VStack(alignment: .leading, spacing: Theme.smallPadding / 2) {
                    Text("my_account".localized)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, Theme.smallPadding / 4)
                    
                    NavigationLink {
                        FavoritesView()
                            .environmentObject(firebaseManager)
                            .environmentObject(authManager)
                            .environmentObject(localizationManager)
                            .environmentObject(currencyManager)
                    } label: {
                        ProfileMenuButton(
                            icon: "heart.fill",
                            text: "favorites".localized,
                            description: "view_favorite_properties".localized,
                            compact: true
                        )
                    }
                    
                    NavigationLink {
                        CurrencySettingsView()
                            .environmentObject(currencyManager)
                    } label: {
                        ProfileMenuButton(
                            icon: "dollarsign.circle.fill",
                            text: "currency_settings".localized,
                            description: "currency_settings_description".localized,
                            compact: true
                        )
                    }
                    
                    // Temporary admin toggle for testing
                    #if DEBUG
                    Button {
                        toggleAdminStatus()
                    } label: {
                        ProfileMenuButton(
                            icon: "person.badge.key",
                            text: authManager.isAdmin ? "Disable Admin Mode" : "Enable Admin Mode",
                            description: "Toggle admin status for testing",
                            compact: true
                        )
                    }
                    #endif
                    
                    Button {
                        showLanguageOptions = true
                    } label: {
                        ProfileMenuButton(
                            icon: "globe",
                            text: "language".localized,
                            description: "change_language_description".localized,
                            compact: true
                        )
                    }
                    .actionSheet(isPresented: $showLanguageOptions) {
                        ActionSheet(
                            title: Text("select_language".localized),
                            buttons: [
                                .default(Text("English")) {
                                    changeLanguage(to: "en")
                                },
                                .default(Text("Français")) {
                                    changeLanguage(to: "fr")
                                },
                                .cancel(Text("cancel".localized))
                            ]
                        )
                    }
                    
                    NavigationLink {
                        MonetizationView()
                            .environmentObject(localizationManager)
                    } label: {
                        ProfileMenuButton(
                            icon: "crown.fill",
                            text: "Upgrade Options",
                            description: "Explore subscription plans and premium features",
                            compact: true
                        )
                    }
                }
                .padding(Theme.smallPadding)
                .background(Theme.cardBackground)
                .cornerRadius(Theme.cornerRadius)
                
                // Section 4: Session Management
                VStack(alignment: .leading, spacing: Theme.smallPadding / 2) {
                    Text("session".localized)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, Theme.smallPadding / 4)
                
                    Button {
                        Task {
                            await signOut()
                        }
                    } label: {
                        ProfileMenuButton(
                            icon: "rectangle.portrait.and.arrow.right",
                            text: "sign_out".localized,
                            description: "sign_out_description".localized,
                            compact: true
                        )
                    }
                }
            }
        }
        .padding(Theme.smallPadding / 2)
        .background(Theme.cardBackground)
    }
    
    private var adminSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lock.shield")
                    .font(.system(size: 24))
                    .foregroundColor(Theme.primaryRed)
                
                Text("admin_section".localized)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Theme.textWhite)
            }
            
            // Admin Actions
            adminActionsSection
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(12)
    }
    
    private var adminActionsSection: some View {
        VStack(spacing: 12) {
            NavigationLink(destination: AdminPropertyFormView(property: Property(
                title: "",
                price: 0,
                description: "",
                address: "",
                bedrooms: 0,
                bathrooms: 0,
                area: 0,
                imageURLs: []
            ))) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                    Text("add_property".localized)
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(Theme.textWhite)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Theme.primaryRed)
                .cornerRadius(8)
            }
            .environmentObject(firebaseManager)
            .environmentObject(authManager)
            
            NavigationLink(destination: AdminView()) {
                HStack {
                    Image(systemName: "gear")
                        .font(.system(size: 20))
                    Text("admin_panel".localized)
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(Theme.textWhite)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Theme.primaryRed)
                .cornerRadius(8)
            }
        }
    }
    
    private var userInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if authManager.currentUser != nil {
                    if let firebaseUser = Auth.auth().currentUser,
                       let providerID = firebaseUser.providerData.first?.providerID,
                       providerID == GoogleAuthProviderID {
                        Image("google_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Theme.primaryRed)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Theme.primaryRed)
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Theme.primaryRed)
                }
                
                Text(authManager.currentUser?.email ?? "guest".localized)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Theme.textWhite)
            }
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(12)
    }
    
    private var signInForm: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            Text("Sign In".localized)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Theme.textWhite)
                .padding(.top)
            
            // Sign In Form
            VStack(alignment: .leading, spacing: 16) {
                // Email Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email".localized)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Theme.textWhite)
                    
                    TextField("Enter your email".localized, text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                // Password Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password".localized)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Theme.textWhite)
                    
                    SecureField("Enter your password".localized, text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.password)
                }
                
                // Sign In Button
                Button(action: signIn) {
                    if isLoading {
                        ProgressView()
                            .tint(Theme.textWhite)
                    } else {
                        Text("Sign In".localized)
                            .font(.system(size: 16, weight: .medium))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Theme.primaryRed)
                .foregroundColor(Theme.textWhite)
                .cornerRadius(8)
                .disabled(isLoading)
                
                // Divider
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Theme.textWhite.opacity(0.2))
                    Text("or")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.textWhite.opacity(0.8))
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Theme.textWhite.opacity(0.2))
                }
                
                // Google Sign In Button
                Button(action: signInWithGoogle) {
                    HStack(spacing: 12) {
                        Image("google_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        
                        Text("Sign in with Google")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.textWhite)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Theme.cardBackground)
                    .cornerRadius(Theme.cornerRadius)
                }
                .disabled(isLoading)
            }
            .padding()
            .background(Theme.cardBackground)
            .cornerRadius(12)
        }
        .padding()
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundBlack
                .ignoresSafeArea()
            
            if authManager.isAuthenticated {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        Text("profile".localized)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Theme.textWhite)
                            .padding(.top)
                        
                        // User Info Section
                        userInfoSection
                        
                        // Menu Section
                        menuSection
                        
                        // Admin Tools Section
                        if authManager.isAdmin {
                            adminSection
                        }
                    }
                    .padding()
                }
                .environmentObject(currencyManager)
            } else {
                signInForm
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAdminView) {
            AdminView()
        }
        .alert(alertType == .error ? "error".localized : "update_property_locations".localized, isPresented: $showingAlert) {
            if alertType == .confirmation {
                Button("cancel".localized, role: .cancel) { }
                Button("update".localized) {
                    Task {
                        isUpdatingLocations = true
                        await firebaseManager.triggerGeolocationUpdate()
                        isUpdatingLocations = false
                        
                        alertType = .error
                        alertMessage = "Property locations update initiated."
                        showingAlert = true
                    }
                }
            } else {
                Button("OK") { }
            }
        } message: {
            Text(alertMessage)
        }
        .alert("language_restart_message".localized, isPresented: $showingLanguageRestartAlert) {
            Button("OK", role: .cancel) { }
        }
        .id(localizationManager.refreshToggle)
    }
    
    private func signOut() async {
        do {
            try await authManager.signOut()
        } catch {
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
    
    private func changeLanguage(to languageCode: String) {
        localizationManager.updateLocale(Locale(identifier: languageCode))
        
        // Save the selected language preference
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Post notification for app-wide language change
        NotificationCenter.default.post(name: Notification.Name("LanguageChanged"), object: nil)
        
        // Show restart alert
        showingLanguageRestartAlert = true
    }
    
    private func updatePropertyLocations() {
        // Show a confirmation alert before proceeding
        alertType = .confirmation
        alertMessage = "update_property_locations_message".localized
        showingAlert = true
        
        // Note: The actual implementation would call firebaseManager.updatePropertyLocations()
        // when the user confirms in the alert dialog. The confirmation button action is already
        // set up in the alert dialog.
    }
    
    private func toggleAdminStatus() {
        authManager.isAdmin.toggle()
    }
    
    private func signIn() {
        isLoading = true
        
        Task {
            do {
                try await authManager.signIn(email: email, password: password)
            } catch {
                alertMessage = error.localizedDescription
                showingAlert = true
            }
            isLoading = false
        }
    }
    
    private func signInWithGoogle() {
        isLoading = true
        
        Task {
            do {
                try await authManager.signInWithGoogle()
            } catch {
                alertMessage = error.localizedDescription
                showingAlert = true
            }
            isLoading = false
        }
    }
}

struct ProfileMenuButton: View {
    let icon: String
    let text: String
    let description: String
    var compact: Bool = false // Default to false for backward compatibility
    
    var body: some View {
        HStack(spacing: compact ? 10 : 16) {
            Image(systemName: icon)
                .font(.system(size: compact ? 18 : 24))
                .foregroundColor(Theme.primaryRed)
                .frame(width: compact ? 24 : 32, height: compact ? 24 : 32)
            
            VStack(alignment: .leading, spacing: compact ? 1 : 4) {
                Text(text)
                    .font(compact ? Theme.Typography.subheading : Theme.Typography.body)
                    .foregroundColor(Theme.textWhite)
                
                Text(description)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.textWhite.opacity(0.7))
                    .lineLimit(compact ? 1 : 2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Theme.textWhite.opacity(0.5))
                .font(.system(size: compact ? 10 : 14))
        }
        .padding(compact ? Theme.smallPadding / 1.5 : Theme.padding)
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cornerRadius)
    }
}
