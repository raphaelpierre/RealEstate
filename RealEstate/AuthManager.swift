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
    #if DEBUG
    @Published var isAdmin = false // Writable for testing
    #else
    @Published private(set) var isAdmin = false
    #endif
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
        print("Starting Google Sign-In process...")
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Error: No client ID found in Firebase configuration")
            throw AuthError.noClientId
        }
        print("Found client ID: \(clientID)")
        
        // Configure Google Sign-In
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        print("Configured GIDSignIn")
        
        // Get the root view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("Error: No root view controller found")
            throw AuthError.noRootViewController
        }
        print("Found root view controller")
        
        do {
            // Start the sign-in process
            print("Starting Google Sign-In UI...")
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            print("Got Google Sign-In result")
            
            // Get the ID token
            guard let idToken = result.user.idToken?.tokenString else {
                print("Error: No ID token received from Google")
                throw AuthError.userNotAuthenticated
            }
            print("Got ID token from Google")
            
            // Create Firebase credential
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            print("Created Firebase credential")
            
            // Sign in with Firebase
            print("Signing in with Firebase...")
            let authResult = try await auth.signIn(with: credential)
            print("Successfully signed in with Firebase")
            
            // Get user profile information
            let photoURL = result.user.profile?.imageURL(withDimension: 200)?.absoluteString
            print("Got photo URL: \(photoURL ?? "nil")")
            
            // Check if this is a new user
            print("Checking if user exists in Firestore...")
            let userDoc = try? await db.collection("users").document(authResult.user.uid).getDocument()
            
            if userDoc == nil || !userDoc!.exists {
                print("Creating new user document...")
                let user = User(
                    id: authResult.user.uid,
                    email: authResult.user.email ?? "",
                    displayName: authResult.user.displayName,
                    photoURL: photoURL
                )
                try await db.collection("users").document(user.id).setData(user.toFirestoreData())
                print("Created new user document")
            } else {
                print("Updating existing user document...")
                if let photoURL = photoURL {
                    let updateData: [String: String] = ["photoURL": photoURL]
                    try await db.collection("users").document(authResult.user.uid).updateData(updateData)
                    print("Updated user photo URL")
                }
            }
            
            print("Fetching user data...")
            await fetchUserData(userId: authResult.user.uid)
            print("Google Sign-In process completed successfully")
            
        } catch {
            print("Google Sign-In error: \(error)")
            print("Error description: \(error.localizedDescription)")
            
            // Handle specific Google Sign-In errors
            if let gidError = error as? GIDSignInError {
                print("GIDSignIn error code: \(gidError.code)")
                switch gidError.code {
                case .hasNoAuthInKeychain:
                    print("No auth in keychain")
                    throw AuthError.noClientId
                case .unknown:
                    print("Unknown error")
                    throw AuthError.unknown
                case .keychain:
                    print("Keychain error")
                    throw AuthError.keychain
                @unknown default:
                    print("Unknown error code")
                    throw AuthError.unknown
                }
            }
            
            // Handle Firebase errors
            if let firebaseError = error as? AuthErrorCode {
                print("Firebase error code: \(firebaseError)")
                switch firebaseError {
                case .invalidAPIKey:
                    throw AuthError.noClientId
                case .networkError:
                    throw AuthError.networkError
                case .userDisabled:
                    throw AuthError.userDisabled
                case .invalidEmail:
                    throw AuthError.userNotAuthenticated
                case .wrongPassword:
                    throw AuthError.userNotAuthenticated
                case .userNotFound:
                    throw AuthError.userNotAuthenticated
                case .accountExistsWithDifferentCredential:
                    throw AuthError.userNotAuthenticated
                case .requiresRecentLogin:
                    throw AuthError.userNotAuthenticated
                case .providerAlreadyLinked:
                    throw AuthError.userNotAuthenticated
                case .noSuchProvider:
                    throw AuthError.userNotAuthenticated
                case .invalidCredential:
                    throw AuthError.userNotAuthenticated
                case .invalidUserToken:
                    throw AuthError.userNotAuthenticated
                case .tooManyRequests:
                    throw AuthError.networkError
                case .operationNotAllowed:
                    throw AuthError.userNotAuthenticated
                case .emailAlreadyInUse:
                    throw AuthError.userNotAuthenticated
                case .weakPassword:
                    throw AuthError.userNotAuthenticated
                case .appNotAuthorized:
                    throw AuthError.noClientId
                case .expiredActionCode:
                    throw AuthError.userNotAuthenticated
                case .invalidActionCode:
                    throw AuthError.userNotAuthenticated
                case .invalidMessagePayload:
                    throw AuthError.userNotAuthenticated
                case .invalidSender:
                    throw AuthError.userNotAuthenticated
                case .invalidRecipientEmail:
                    throw AuthError.userNotAuthenticated
                case .missingEmail:
                    throw AuthError.userNotAuthenticated
                case .missingIosBundleID:
                    throw AuthError.noClientId
                case .missingAndroidPackageName:
                    throw AuthError.noClientId
                case .unauthorizedDomain:
                    throw AuthError.noClientId
                case .invalidContinueURI:
                    throw AuthError.noClientId
                case .missingContinueURI:
                    throw AuthError.noClientId
                case .missingPhoneNumber:
                    throw AuthError.userNotAuthenticated
                case .invalidPhoneNumber:
                    throw AuthError.userNotAuthenticated
                case .missingVerificationCode:
                    throw AuthError.userNotAuthenticated
                case .invalidVerificationCode:
                    throw AuthError.userNotAuthenticated
                case .missingVerificationID:
                    throw AuthError.userNotAuthenticated
                case .invalidVerificationID:
                    throw AuthError.userNotAuthenticated
                case .missingAppCredential:
                    throw AuthError.noClientId
                case .invalidAppCredential:
                    throw AuthError.noClientId
                case .sessionExpired:
                    throw AuthError.userNotAuthenticated
                case .quotaExceeded:
                    throw AuthError.networkError
                case .keychainError:
                    throw AuthError.keychain
                case .internalError:
                    throw AuthError.unknown
                case .invalidCustomToken:
                    throw AuthError.userNotAuthenticated
                case .customTokenMismatch:
                    throw AuthError.userNotAuthenticated
                case .captchaCheckFailed:
                    throw AuthError.userNotAuthenticated
                case .webContextAlreadyPresented:
                    throw AuthError.userNotAuthenticated
                case .webContextCancelled:
                    throw AuthError.userNotAuthenticated
                case .appVerificationUserInteractionFailure:
                    throw AuthError.userNotAuthenticated
                case .invalidClientID:
                    throw AuthError.noClientId
                case .webNetworkRequestFailed:
                    throw AuthError.networkError
                case .webSignInUserInteractionFailure:
                    throw AuthError.userNotAuthenticated
                case .localPlayerNotAuthenticated:
                    throw AuthError.userNotAuthenticated
                case .nullUser:
                    throw AuthError.userNotAuthenticated
                case .dynamicLinkNotActivated:
                    throw AuthError.userNotAuthenticated
                case .invalidProviderID:
                    throw AuthError.userNotAuthenticated
                case .tenantIDMismatch:
                    throw AuthError.userNotAuthenticated
                case .unsupportedTenantOperation:
                    throw AuthError.userNotAuthenticated
                case .invalidDynamicLinkDomain:
                    throw AuthError.noClientId
                case .rejectedCredential:
                    throw AuthError.userNotAuthenticated
                case .gameKitNotLinked:
                    throw AuthError.userNotAuthenticated
                case .secondFactorRequired:
                    throw AuthError.userNotAuthenticated
                case .missingMultiFactorSession:
                    throw AuthError.userNotAuthenticated
                case .missingMultiFactorInfo:
                    throw AuthError.userNotAuthenticated
                case .invalidMultiFactorSession:
                    throw AuthError.userNotAuthenticated
                case .multiFactorInfoNotFound:
                    throw AuthError.userNotAuthenticated
                case .adminRestrictedOperation:
                    throw AuthError.adminRequired
                case .unverifiedEmail:
                    throw AuthError.userNotAuthenticated
                case .secondFactorAlreadyEnrolled:
                    throw AuthError.userNotAuthenticated
                case .maximumSecondFactorCountExceeded:
                    throw AuthError.userNotAuthenticated
                case .unsupportedFirstFactor:
                    throw AuthError.userNotAuthenticated
                case .emailChangeNeedsVerification:
                    throw AuthError.userNotAuthenticated
                case .missingOrInvalidNonce:
                    throw AuthError.userNotAuthenticated
                @unknown default:
                    throw AuthError.unknown
                }
            }
            
            throw error
        }
    }
}

enum AuthError: LocalizedError {
    case adminRequired
    case noClientId
    case noRootViewController
    case userNotAuthenticated
    case unknown
    case keychain
    case networkError
    case userDisabled
    
    var errorDescription: String? {
        switch self {
        case .adminRequired:
            return "Only admins can demote users"
        case .noClientId:
            return "Google Sign-In is not properly configured. Please check your GoogleService-Info.plist file."
        case .noRootViewController:
            return "Unable to present Google Sign-In. Please try again."
        case .userNotAuthenticated:
            return "Failed to authenticate with Google"
        case .unknown:
            return "An unknown error occurred during Google Sign-In"
        case .keychain:
            return "Unable to access keychain. Please check your device settings."
        case .networkError:
            return "Network error. Please check your internet connection."
        case .userDisabled:
            return "This account has been disabled. Please contact support."
        }
    }
}
