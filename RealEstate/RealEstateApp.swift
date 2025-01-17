//
//  RealEstateApp.swift
//  RealEstate
//
//  Created by Raphael PIERRE on 15.01.2025.
//
import SwiftUI
import FirebaseCore

@main
struct RealEstateApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
