//
//  AuthManager.swift
//  RealEstate
//
//  Created by Raphael PIERRE on 15.01.2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift

@MainActor
final class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published private(set) var currentUser: User?
    @Published private(set) var isAuthenticated = false
    @Published private(set) var isAdmin = false
    @Published var errorMessage: String?
    @Published var showMessage = false
    @Published var message = ""
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private let firebaseManager = FirebaseManager.shared
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    private init() {
        setupAuthStateListener()
    }
    
    deinit {
        if let handler = authStateHandler {
            auth.removeStateDidChangeListener(handler)
        }
    }
    
    private func setupAuthStateListener() {
        authStateHandler = auth.addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            
            Task {
                if let user = user {
                    self.isAuthenticated = true
                    await self.fetchUserData(userId: user.uid)
                } else {
                    self.isAuthenticated = false
                    self.currentUser = nil
                    self.isAdmin = false
                }
            }
        }
    }
    
    private func fetchUserData(userId: String) async {
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            if let user = User.fromFirestore(document) {
                self.currentUser = user
                self.isAdmin = user.isAdmin
            }
        } catch {
            print("Error fetching user data: \(error)")
            self.errorMessage = error.localizedDescription
        }
    }
    
    func signIn(email: String, password: String) async throws {
        let result = try await auth.signIn(withEmail: email, password: password)
        await fetchUserData(userId: result.user.uid)
    }
    
    func signUp(email: String, password: String) async throws {
        let result = try await auth.createUser(withEmail: email, password: password)
        
        // Create user document in Firestore
        let user = User(id: result.user.uid, email: email)
        try await db.collection("users").document(user.id).setData(user.toFirestoreData())
        
        await fetchUserData(userId: result.user.uid)
    }
    
    func signOut() async throws {
        // Clean up favorites before signing out
        await firebaseManager.cleanupUserData()
        try auth.signOut()
        message = "You have been successfully signed out"
        showMessage = true
    }
    
    func resetPassword(email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }
    
    func deleteAccount() async throws {
        guard let user = auth.currentUser else {
            throw AuthError.userNotAuthenticated
        }
        
        // Delete all favorites first
        try await firebaseManager.deleteAllFavorites()
        
        // Delete user document from Firestore
        try await db.collection("users").document(user.uid).delete()
        
        // Delete user account
        try await user.delete()
        
        // Clean up local data
        await firebaseManager.cleanupUserData()
    }
    
    private func updateAdminStatus(for userId: String, isAdmin: Bool) async throws {
        let data: [String: Any] = ["isAdmin": isAdmin]
        try await db.collection("users").document(userId).updateData(data)
    }
    
    func makeAdmin(userId: String) async throws {
        guard isAdmin else {
            throw AuthError.adminRequired
        }
        try await updateAdminStatus(for: userId, isAdmin: true)
    }
    
    func removeAdmin(userId: String) async throws {
        guard isAdmin else {
            throw AuthError.adminRequired
        }
        try await updateAdminStatus(for: userId, isAdmin: false)
    }
    
    func signInWithGoogle() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.noClientId
        }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            throw AuthError.noRootViewController
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.userNotAuthenticated
        }
        
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )
        
        let authResult = try await auth.signIn(with: credential)
        
        // Check if this is a new user
        let userDoc = try? await db.collection("users").document(authResult.user.uid).getDocument()
        if userDoc == nil || !userDoc!.exists {
            // Create new user document
            let user = User(
                id: authResult.user.uid,
                email: authResult.user.email ?? "",
                displayName: authResult.user.displayName
            )
            try await db.collection("users").document(user.id).setData(user.toFirestoreData())
        }
        
        await fetchUserData(userId: authResult.user.uid)
    }
}

enum AuthError: LocalizedError {
    case adminRequired
    case noClientId
    case noRootViewController
    case userNotAuthenticated
    
    var errorDescription: String? {
        switch self {
        case .adminRequired:
            return "Only admins can demote users"
        case .noClientId:
            return "No client ID found"
        case .noRootViewController:
            return "No root view controller found"
        case .userNotAuthenticated:
            return "User is not authenticated"
        }
    }
}
