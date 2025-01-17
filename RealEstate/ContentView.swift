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
    
    var body: some View {
        NavigationView {
            LandingView()
                .environmentObject(firebaseManager)
                .environmentObject(authManager)
                .toolbar {
                    if authManager.isAuthenticated {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            HStack {
                                if authManager.isAdmin {
                                    Button {
                                        showingAdminView = true
                                    } label: {
                                        Image(systemName: "gear")
                                    }
                                }
                                
                                Button {
                                    try? authManager.signOut()
                                } label: {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                }
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingAdminView) {
                    AdminView()
                        .environmentObject(firebaseManager)
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
