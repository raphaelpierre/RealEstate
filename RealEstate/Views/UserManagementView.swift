import SwiftUI
import FirebaseAuth

struct UserManagementView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    @State private var users: [User] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var showingEditUser = false
    @State private var selectedUser: User?
    @State private var searchText = ""
    
    private var filteredUsers: [User] {
        if searchText.isEmpty {
            return users
        }
        return users.filter { user in
            user.email.localizedCaseInsensitiveContains(searchText) ||
            (user.displayName?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            searchBar
            
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if users.isEmpty {
                emptyStateView
            } else {
                userList
            }
        }
        .navigationTitle("user_management".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.backgroundBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .alert("error".localized, isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "unknown_error".localized)
        }
        .sheet(item: $selectedUser) { user in
            EditUserView(user: user)
                .environmentObject(firebaseManager)
                .environmentObject(authManager)
        }
        .task {
            await loadUsers()
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Theme.textWhite.opacity(0.7))
            
            TextField("search_users".localized, text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(Theme.textWhite)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cornerRadius)
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: Theme.padding) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 50))
                .foregroundColor(Theme.textWhite.opacity(0.5))
            
            Text("no_users_found".localized)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.textWhite.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var userList: some View {
        List(filteredUsers) { user in
            UserRow(user: user)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedUser = user
                }
        }
        .listStyle(PlainListStyle())
        .background(Theme.backgroundBlack)
    }
    
    private func loadUsers() async {
        isLoading = true
        do {
            users = try await firebaseManager.fetchAllUsers()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
        isLoading = false
    }
}

struct UserRow: View {
    let user: User
    
    var body: some View {
        HStack(spacing: Theme.padding) {
            // User Avatar
            if let photoURLString = user.photoURL,
               let photoURL = URL(string: photoURLString) {
                AsyncImage(url: photoURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 40, height: 40)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    case .failure:
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Theme.primaryRed)
                    @unknown default:
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Theme.primaryRed)
                    }
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Theme.primaryRed)
            }
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Text(user.displayName ?? user.email)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.textWhite)
                
                Text(user.email)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.textWhite.opacity(0.7))
                
                if user.isAdmin {
                    Text("admin".localized)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.primaryRed)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Theme.textWhite.opacity(0.5))
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cornerRadius)
    }
}

struct EditUserView: View {
    let user: User
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    @State private var displayName: String
    @State private var isAdmin: Bool
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var showingDeleteConfirmation = false
    
    init(user: User) {
        self.user = user
        _displayName = State(initialValue: user.displayName ?? "")
        _isAdmin = State(initialValue: user.isAdmin)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("user_info".localized)) {
                    TextField("display_name".localized, text: $displayName)
                        .textContentType(.name)
                    
                    Text(user.email)
                        .foregroundColor(Theme.textWhite.opacity(0.7))
                }
                
                Section(header: Text("permissions".localized)) {
                    Toggle("admin_access".localized, isOn: $isAdmin)
                }
                
                Section {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("delete_user".localized)
                        }
                    }
                }
            }
            .navigationTitle("edit_user".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel".localized) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("save".localized) {
                        Task {
                            await saveChanges()
                        }
                    }
                    .disabled(isLoading)
                }
            }
            .alert("error".localized, isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage ?? "unknown_error".localized)
            }
            .alert("delete_user".localized, isPresented: $showingDeleteConfirmation) {
                Button("cancel".localized, role: .cancel) { }
                Button("delete_user".localized, role: .destructive) {
                    Task {
                        await deleteUser()
                    }
                }
            } message: {
                Text("delete_user_confirmation".localized)
            }
        }
    }
    
    private func saveChanges() async {
        isLoading = true
        do {
            var updatedUser = user
            updatedUser.displayName = displayName
            updatedUser.isAdmin = isAdmin
            try await firebaseManager.updateUser(updatedUser)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
        isLoading = false
    }
    
    private func deleteUser() async {
        isLoading = true
        do {
            try await firebaseManager.deleteUser(user.id)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
        isLoading = false
    }
}

#Preview {
    NavigationView {
        UserManagementView()
            .environmentObject(FirebaseManager.shared)
            .environmentObject(AuthManager.shared)
            .environmentObject(LocalizationManager.shared)
    }
} 