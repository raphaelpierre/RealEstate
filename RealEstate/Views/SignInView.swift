import SwiftUI
import FirebaseAuth
import GoogleSignInSwift

struct SignInView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var showingSignUp = false
    
    var body: some View {
        ZStack {
            Theme.backgroundBlack
                .ignoresSafeArea()
            
            ScrollView {
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
                        
                        // Sign Up Link
                        Button(action: {
                            showingSignUp = true
                        }) {
                            Text("Don't have an account?".localized)
                                .font(.system(size: 14))
                                .foregroundColor(Theme.primaryRed)
                        }
                        .disabled(isLoading)
                    }
                    .padding()
                    .background(Theme.cardBackground)
                    .cornerRadius(12)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("error".localized, isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingSignUp) {
            SignUpView()
        }
    }
    
    private func signIn() {
        isLoading = true
        
        Task {
            do {
                try await authManager.signIn(email: email, password: password)
                dismiss()
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
                dismiss()
            } catch {
                alertMessage = error.localizedDescription
                showingAlert = true
            }
            isLoading = false
        }
    }
}

#Preview {
    SignInView()
        .environmentObject(AuthManager.shared)
        .environmentObject(LocalizationManager.shared)
} 