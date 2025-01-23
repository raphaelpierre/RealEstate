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
    @State private var showingGeolocationUpdateAlert = false
    @State private var isUpdatingLocations = false
    
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
            
            // Map Tab
            NavigationView {
                PropertyListView(initialViewMode: .map)
                    .environmentObject(firebaseManager)
                    .environmentObject(authManager)
            }
            .tabItem {
                Label {
                    Text("Map")
                } icon: {
                    Image(systemName: "map.fill")
                        .environment(\.symbolVariants, selectedTab == 2 ? .fill : .none)
                }
            }
            .tag(2)
            
            // Admin Tab (Only shown for admin users)
            if authManager.currentUser?.isAdmin == true {
                NavigationView {
                    VStack {
                        List {
                            NavigationLink(destination: AdminView()) {
                                Label("Admin Panel", systemImage: "gear")
                            }
                            
                            Button(action: {
                                showingGeolocationUpdateAlert = true
                            }) {
                                Label("Update Property Locations", systemImage: "map")
                            }
                        }
                    }
                    .navigationTitle("Admin Tools")
                }
                .tabItem {
                    Label("Admin", systemImage: "person.crop.circle.badge.checkmark")
                }
                .tag(authManager.currentUser?.isAdmin ?? false ? 3 : 2)
                .alert(isPresented: $showingGeolocationUpdateAlert) {
                    Alert(
                        title: Text("Update Property Locations"),
                        message: Text("This will attempt to add geographic coordinates to all properties without location data. This may take a few minutes."),
                        primaryButton: .default(Text("Update")) {
                            Task {
                                isUpdatingLocations = true
                                await firebaseManager.triggerGeolocationUpdate()
                                isUpdatingLocations = false
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
                .overlay(
                    ProgressView()
                        .scaleEffect(1.5)
                        .opacity(isUpdatingLocations ? 1 : 0)
                )
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
                        .environment(\.symbolVariants, selectedTab == (authManager.currentUser?.isAdmin ?? false ? 4 : 3) ? .fill : .none)
                }
            }
            .tag(authManager.currentUser?.isAdmin ?? false ? 4 : 3)
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
