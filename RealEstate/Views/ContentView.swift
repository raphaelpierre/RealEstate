//
//  ContentView.swift
//  RealEstate
//
//  Created by Raphael PIERRE on 15.01.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var firebaseManager = FirebaseManager.shared
    @StateObject private var authManager = AuthManager.shared
    @State private var showingAdminView = false
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationView {
                LandingView()
                    .environmentObject(firebaseManager)
                    .environmentObject(authManager)
            }
            .tabItem {
                Label {
                    Text("Home")
                } icon: {
                    Image(systemName: "house.fill")
                        .environment(\.symbolVariants, selectedTab == 0 ? .fill : .none)
                }
            }
            .tint(Theme.primaryRed)
            .tag(0)
            
            // Favorites Tab
            NavigationView {
                FavoritesView()
                    .environmentObject(firebaseManager)
                    .environmentObject(authManager)
            }
            .tabItem {
                Label {
                    Text("Favorites")
                } icon: {
                    Image(systemName: "heart.fill")
                        .environment(\.symbolVariants, selectedTab == 1 ? .fill : .none)
                }
            }
            .tag(1)
            
            // Admin Tab (Only shown for admin users)
            if firebaseManager.isAdmin {
                NavigationView {
                    AdminView()
                        .environmentObject(firebaseManager)
                }
                .tabItem {
                    Label {
                        Text("Manage")
                    } icon: {
                        Image(systemName: "square.and.pencil")
                            .environment(\.symbolVariants, selectedTab == 2 ? .fill : .none)
                    }
                }
                .tag(2)
            }
            
            // Profile Tab
            NavigationView {
                ProfileView()
                    .environmentObject(firebaseManager)
                    .environmentObject(authManager)
            }
            .tabItem {
                Label {
                    Text("Profile")
                } icon: {
                    Image(systemName: "person.fill")
                        .environment(\.symbolVariants, selectedTab == (firebaseManager.isAdmin ? 3 : 2) ? .fill : .none)
                }
            }
            .tag(firebaseManager.isAdmin ? 3 : 2)
        }
        .tint(Theme.primaryRed)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = UIColor.black
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
