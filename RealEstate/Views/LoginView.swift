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
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            Theme.backgroundBlack
                .ignoresSafeArea()
            
            VStack(spacing: Theme.padding * 2) {
                // Logo or App Name
                VStack(spacing: Theme.smallPadding) {
                    Text("Real Estate")
                        .font(Theme.Typography.titleLarge)
                        .foregroundColor(Theme.textWhite)
                    Text("Find your dream home")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.textWhite.opacity(0.8))
                }
                .padding(.top, 60)
                
                // Login Form
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
                        placeholder: "Password",
                        text: $password,
                        isSecure: true
                    )
                    
                    // Login Button
                    Button {
                        Task {
                            await login()
                        }
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .tint(Theme.textWhite)
                            } else {
                                Text("Login")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                    }
                    .primaryButton()
                    .disabled(isLoading)
                }
                .padding(.horizontal, Theme.padding)
                
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
                
                // Google Sign In
                GoogleSignInButton(scheme: .dark, style: .wide) {
                    signInWithGoogle()
                }
                .frame(height: 50)
                .cornerRadius(Theme.cornerRadius)
                .padding(.horizontal, Theme.padding)
                
                Spacer()
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { showError = false }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            showError = true
            return
        }
        
        isLoading = true
        Task {
            do {
                try await authManager.signIn(email: email, password: password)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isLoading = false
        }
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
