//
//  LoginView.swift
//  RealEstate
//
//  Created by Raphael PIERRE on 15.01.2025.
//

import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isRegistering = false
    
    private var isFormValid: Bool {
        if isRegistering {
            return !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty &&
                   password == confirmPassword && password.count >= 6
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundBlack
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Theme.padding * 2) {
                    // Banner Image
                    Image("banner")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(Theme.cornerRadius)
                        .padding(.horizontal, Theme.padding)
                        .padding(.top, 60)
                    
                    // Login/Register Form
                    VStack(spacing: Theme.padding) {
                        // Email Field
                        TextFormField(
                            label: "Email",
                            placeholder: "Email",
                            text: $email
                        )
                        
                        // Password Field
                        TextFormField(
                            label: "Password",
                            placeholder: "Enter your password".localized,
                            text: $password,
                            isSecure: true
                        )
                        
                        // Confirm Password Field (Registration only)
                        if isRegistering {
                            TextFormField(
                                label: "Confirm Password",
                                placeholder: "Confirm Password",
                                text: $confirmPassword,
                                isSecure: true
                            )
                        }
                        
                        // Login/Register Button
                        Button {
                            Task {
                                if isRegistering {
                                    await register()
                                } else {
                                    await login()
                                }
                            }
                        } label: {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(Theme.textWhite)
                                } else {
                                    Text(isRegistering ? "Create Account" : "Login")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                        }
                        .primaryButton()
                        .disabled(!isFormValid || isLoading)
                        
                        // Toggle Login/Register
                        Button {
                            withAnimation {
                                isRegistering.toggle()
                                // Clear fields when switching modes
                                password = ""
                                confirmPassword = ""
                                errorMessage = ""
                                showError = false
                            }
                        } label: {
                            Text(isRegistering ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                                .foregroundColor(Theme.primaryRed)
                        }
                    }
                    .padding(.horizontal, Theme.padding)
                    
                    if !isRegistering {
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
                        .padding(.horizontal, Theme.padding)
                        
                        // Custom Google Sign In button
                        Button {
                            signInWithGoogle()
                        } label: {
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
                        .padding(.horizontal, Theme.padding)
                    }
                    
                    Spacer()
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func register() async {
        isLoading = true
        do {
            try await authManager.signUp(email: email, password: password)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
    
    private func login() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            showError = true
            return
        }
        
        isLoading = true
        do {
            try await authManager.signIn(email: email, password: password)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
    
    private func signInWithGoogle() {
        Task {
            do {
                try await authManager.signInWithGoogle()
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

struct ResetPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authManager: AuthManager
    @State private var email = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Reset Password")
                    .font(.title)
                    .padding(.top)
                
                Text("Enter your email address and we'll send you a link to reset your password.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                TextFormField(
                    label: "Email",
                    placeholder: "Email",
                    text: $email
                )
                .padding(.top)
                
                Button(action: {
                    Task {
                        await handleResetPassword()
                    }
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .tint(Theme.textWhite)
                        } else {
                            Text("Send Reset Link")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                }
                .primaryButton()
                .disabled(isLoading || email.isEmpty)
                
                Spacer()
            }
            .padding()
            .alert("Password Reset", isPresented: $showingAlert) {
                Button("OK") { 
                    if !alertMessage.contains("Error") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
    
    private func handleResetPassword() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await authManager.resetPassword(email: email)
            alertMessage = "Password reset email sent. Please check your inbox."
            showingAlert = true
        } catch {
            alertMessage = "Error: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

#Preview {
    LoginView()
}
