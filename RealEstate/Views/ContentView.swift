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
    @StateObject private var currencyManager = CurrencyManager.shared
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var showingAdminView = false
    @State private var selectedTab = 0
    @State private var showingGeolocationUpdateAlert = false
    @State private var isUpdatingLocations = false
    
    private var isAdmin: Bool {
        authManager.currentUser?.isAdmin == true
    }
    
    private var tabs: [(view: AnyView, label: String, icon: String, tag: Int)] {
        var result: [(view: AnyView, label: String, icon: String, tag: Int)] = [
            (AnyView(LandingView()), "home".localized, "house.fill", 0),
            (AnyView(AdminPropertyFormView(property: nil)), "add_property".localized, "plus.circle.fill", 1),
            (AnyView(PropertyListView(initialViewMode: .map)), "map".localized, "map.fill", 2)
        ]
        
        if isAdmin {
            result.append((AnyView(AdminToolsView()), "admin".localized, "person.crop.circle.badge.checkmark", 3))
        }
        
        result.append((AnyView(ProfileView()), "profile".localized, "person.fill", isAdmin ? 4 : 3))
        result.append((AnyView(ServicesView()), "our_services".localized, "briefcase.fill", isAdmin ? 5 : 4))
        
        return result
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(tabs, id: \.tag) { tab in
                NavigationView {
                    tab.view
                        .environmentObject(firebaseManager)
                        .environmentObject(authManager)
                        .environmentObject(localizationManager)
                        .environmentObject(currencyManager)
                }
                .tabItem {
                    Label {
                        Text(tab.label)
                    } icon: {
                        Image(systemName: tab.icon)
                            .environment(\.symbolVariants, selectedTab == tab.tag ? .fill : .none)
                    }
                }
                .tint(Theme.primaryRed)
                .tag(tab.tag)
            }
        }
        .tint(Theme.primaryRed)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = UIColor.black
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        .id(localizationManager.refreshToggle)
    }
}

// Admin Tools View
struct AdminToolsView: View {
    @State private var showingGeolocationUpdateAlert = false
    @State private var isUpdatingLocations = false
    @EnvironmentObject private var firebaseManager: FirebaseManager
    
    var body: some View {
        VStack {
            List {
                NavigationLink(destination: AdminView()) {
                    Label("admin".localized, systemImage: "gear")
                }
                
                Button(action: {
                    showingGeolocationUpdateAlert = true
                }) {
                    Label("update_property_locations".localized, systemImage: "map")
                }
            }
        }
        .navigationTitle("admin_tools".localized)
        .alert(isPresented: $showingGeolocationUpdateAlert) {
            Alert(
                title: Text("update_property_locations".localized),
                message: Text("update_property_locations_message".localized),
                primaryButton: .default(Text("update".localized)) {
                    Task {
                        isUpdatingLocations = true
                        await firebaseManager.triggerGeolocationUpdate()
                        isUpdatingLocations = false
                    }
                },
                secondaryButton: .cancel(Text("cancel".localized))
            )
        }
        .overlay(
            ProgressView()
                .scaleEffect(1.5)
                .opacity(isUpdatingLocations ? 1 : 0)
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LocalizationManager.shared)
    }
}
