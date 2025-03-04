import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var showingSignIn = false
    
    var body: some View {
        ZStack {
            Theme.backgroundBlack
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    Text("sign_up".localized)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Theme.textWhite)
                        .padding(.top)
                    
                    // Sign Up Form
                    VStack(alignment: .leading, spacing: 16) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("email".localized)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Theme.textWhite)
                            
                            TextField("email_placeholder".localized, text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("password".localized)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Theme.textWhite)
                            
                            SecureField("password_placeholder".localized, text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .textContentType(.newPassword)
                        }
                        
                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("confirm_password".localized)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Theme.textWhite)
                            
                            SecureField("confirm_password_placeholder".localized, text: $confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .textContentType(.newPassword)
                        }
                        
                        // Password Requirements
                        VStack(alignment: .leading, spacing: 4) {
                            Text("password_requirements".localized)
                                .font(.system(size: 12))
                                .foregroundColor(Theme.textWhite.opacity(0.7))
                            
                            Text("• \("password_requirement_length".localized)")
                                .font(.system(size: 12))
                                .foregroundColor(Theme.textWhite.opacity(0.7))
                            Text("• \("password_requirement_letter".localized)")
                                .font(.system(size: 12))
                                .foregroundColor(Theme.textWhite.opacity(0.7))
                            Text("• \("password_requirement_number".localized)")
                                .font(.system(size: 12))
                                .foregroundColor(Theme.textWhite.opacity(0.7))
                        }
                        .padding(.vertical, 8)
                        
                        // Sign Up Button
                        Button(action: signUp) {
                            if isLoading {
                                ProgressView()
                                    .tint(Theme.textWhite)
                            } else {
                                Text("sign_up".localized)
                                    .font(.system(size: 16, weight: .medium))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.primaryRed)
                        .foregroundColor(Theme.textWhite)
                        .cornerRadius(8)
                        .disabled(isLoading || !isFormValid)
                        
                        // Sign In Link
                        Button(action: {
                            showingSignIn = true
                        }) {
                            Text("already_have_account".localized)
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
        .sheet(isPresented: $showingSignIn) {
            SignInView()
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        password == confirmPassword &&
        password.count >= 8 &&
        password.contains(where: { $0.isNumber }) &&
        password.contains(where: { $0.isUppercase })
    }
    
    private func signUp() {
        guard isFormValid else {
            alertMessage = "invalid_form".localized
            showingAlert = true
            return
        }
        
        isLoading = true
        
        Task {
            do {
                try await authManager.signUp(email: email, password: password)
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
    SignUpView()
        .environmentObject(AuthManager.shared)
        .environmentObject(LocalizationManager.shared)
} 