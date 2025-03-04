//
//  RealEstateApp.swift
//  RealEstate
//
//  Created by Raphael PIERRE on 15.01.2025.
//
import SwiftUI
import FirebaseCore

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    @StateObject private var currencyManager = CurrencyManager.shared
           
    var body: some View {
        if isActive {
            ContentView()
                .environmentObject(localizationManager)
                .environmentObject(currencyManager)
        } else {
            ZStack {
                Theme.backgroundBlack
                    .ignoresSafeArea()
                
                VStack {
                    Image("AppLogo") // Make sure to add this image to your assets
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                    
                    Text("Real Estate")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Theme.textWhite)
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

@main
struct RealEstateApp: App {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var firebaseManager = FirebaseManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var currencyManager = CurrencyManager.shared
    
    init() {
        FirebaseApp.configure()
        // Initialize localization
        LocalizationSetup.initialize()
    }
    
    var body: some Scene {
        WindowGroup {
            VideoSplashView()
                .environmentObject(authManager)
                .environmentObject(firebaseManager)
                .environmentObject(localizationManager)
                .environmentObject(currencyManager)
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
            .environmentObject(AuthManager.shared)
            .environmentObject(FirebaseManager.shared)
            .environmentObject(LocalizationManager.shared)
            .environmentObject(CurrencyManager.shared)
    }
}
