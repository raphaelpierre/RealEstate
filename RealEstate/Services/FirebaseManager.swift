//
//  FirebaseManager.swift
//  RealEstate
//
//  Created by Raphael PIERRE on 15.01.2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseCore
import FirebaseAuth

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    private let db = Firestore.firestore()
    private let storage: Storage
    private let auth = Auth.auth()
    
    @Published var properties: [Property] = []
    @Published var isAdmin = false // TODO: Replace with proper auth
    @Published var favoritePropertyIds: Set<String> = []
    
    private init() {
        // Ensure Firebase is configured
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        storage = Storage.storage()
        
        // Listen for auth state changes
        auth.addStateDidChangeListener { [weak self] _, user in
            if user != nil {
                self?.loadFavorites()
            } else {
                DispatchQueue.main.async {
                    self?.favoritePropertyIds.removeAll()
                    self?.updatePropertiesFavoriteStatus()
                }
            }
        }
    }
    
    // MARK: - Properties Management
    
    func getProperty(id: String) async throws -> Property {
        let document = try await db.collection("properties").document(id).getDocument()
        guard let property = Property.fromFirestore(document) else {
            throw NSError(
                domain: "FirebaseManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to load property with ID: \(id)"]
            )
        }
        
        // Update favorite status
        var updatedProperty = property
        updatedProperty.isFavorite = favoritePropertyIds.contains(property.id)
        return updatedProperty
    }
    
    func fetchProperties() async throws {
        let snapshot = try await db.collection("properties").getDocuments()
        let fetchedProperties = snapshot.documents.compactMap { document -> Property? in
            if var property = Property.fromFirestore(document) {
                property.isFavorite = favoritePropertyIds.contains(property.id)
                return property
            }
            return nil
        }
        
        DispatchQueue.main.async {
            self.properties = fetchedProperties
        }
    }
    
    func addProperty(_ property: Property) async throws {
        try await db.collection("properties").document(property.id).setData(property.toFirestoreData())
        try await fetchProperties()
    }
    
    func updateProperty(_ property: Property) async throws {
        try await db.collection("properties").document(property.id).setData(property.toFirestoreData())
        try await fetchProperties()
    }
    
    func deleteProperty(_ property: Property) async throws {
        // Delete associated images first
        for imageURL in property.imageURLs {
            if let url = URL(string: imageURL), url.host?.contains("firebasestorage") == true {
                try await storage.reference(forURL: imageURL).delete()
            }
        }
        
        // Delete the property document
        try await db.collection("properties").document(property.id).delete()
        try await fetchProperties()
    }
    
    func uploadImage(_ imageData: Data) async throws -> String {
        let filename = UUID().uuidString + ".jpg"
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        do {
            // Ensure the property_images directory exists
            let storageRef = storage.reference()
            let imagesRef = storageRef.child("property_images")
            let imageRef = imagesRef.child(filename)
            
            print("Uploading to path: \(imageRef.fullPath)")
            
            // Upload the file
            _ = try await imageRef.putDataAsync(imageData, metadata: metadata)
            
            // Get download URL
            let downloadURL = try await imageRef.downloadURL()
            print("Successfully uploaded image: \(downloadURL.absoluteString)")
            return downloadURL.absoluteString
            
        } catch let error as NSError {
            print("Detailed storage error: \(error)")
            print("Error domain: \(error.domain)")
            print("Error code: \(error.code)")
            print("Error description: \(error.localizedDescription)")
            print("Error user info: \(error.userInfo)")
            
            throw NSError(
                domain: "FirebaseStorage",
                code: error.code,
                userInfo: [
                    NSLocalizedDescriptionKey: "Failed to upload image: \(error.localizedDescription)",
                    NSUnderlyingErrorKey: error
                ]
            )
        }
    }
    
    // MARK: - Favorites Management
    
    private func loadFavorites() {
        guard let userId = auth.currentUser?.uid else { return }
        Task {
            do {
                let favoritesDoc = try await db.collection("users").document(userId).collection("favorites").getDocuments()
                let favoriteIds = favoritesDoc.documents.map { $0.documentID }
                
                DispatchQueue.main.async {
                    self.favoritePropertyIds = Set(favoriteIds)
                    // Update isFavorite status for all properties
                    self.updatePropertiesFavoriteStatus()
                }
            } catch {
                print("Error loading favorites: \(error)")
            }
        }
    }
    
    private func updatePropertiesFavoriteStatus() {
        DispatchQueue.main.async {
            self.properties = self.properties.map { property in
                var updatedProperty = property
                updatedProperty.isFavorite = self.favoritePropertyIds.contains(property.id)
                return updatedProperty
            }
            self.objectWillChange.send()
        }
    }
    
    func toggleFavorite(for property: Property) {
        guard let userId = auth.currentUser?.uid else { return }
        
        // Update local state immediately
        let isCurrentlyFavorite = favoritePropertyIds.contains(property.id)
        if isCurrentlyFavorite {
            favoritePropertyIds.remove(property.id)
        } else {
            favoritePropertyIds.insert(property.id)
        }
        updatePropertiesFavoriteStatus()
        
        // Then update Firebase
        Task {
            do {
                let favoriteRef = db.collection("users").document(userId).collection("favorites").document(property.id)
                
                if isCurrentlyFavorite {
                    // Remove from favorites
                    try await favoriteRef.delete()
                } else {
                    // Add to favorites
                    try await favoriteRef.setData(["addedAt": FieldValue.serverTimestamp()])
                }
                
                // Refresh properties to ensure consistency
                try await fetchProperties()
            } catch {
                print("Error toggling favorite: \(error)")
                // Revert local state if Firebase update fails
                DispatchQueue.main.async {
                    if isCurrentlyFavorite {
                        self.favoritePropertyIds.insert(property.id)
                    } else {
                        self.favoritePropertyIds.remove(property.id)
                    }
                    self.updatePropertiesFavoriteStatus()
                }
            }
        }
    }
    
    func isFavorite(_ propertyId: String) -> Bool {
        return favoritePropertyIds.contains(propertyId)
    }
    
    // MARK: - Sample Data
    
    func createSampleProperties() async throws {
        let sampleProperties = [
            Property(
                id: UUID().uuidString,
                title: "Modern Waterfront Villa",
                price: 1250000,
                description: "Stunning modern villa with direct access to Lake Geneva. Features include floor-to-ceiling windows, private dock, and state-of-the-art home automation.",
                address: "123 Lakeside Drive",
                zipCode: "1290",
                city: "Versoix",
                country: "Switzerland",
                bedrooms: 4,
                bathrooms: 3,
                area: 280,
                imageURLs: [
                    "https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?ixlib=rb-4.0.3",
                    "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?ixlib=rb-4.0.3"
                ],
                createdAt: Date(),
                updatedAt: Date()
            ),
            Property(
                id: UUID().uuidString,
                title: "Luxury Penthouse in City Center",
                price: 2100000,
                description: "Exclusive penthouse with panoramic views of Geneva. Features a private rooftop terrace, wine cellar, and 24/7 concierge service.",
                address: "45 Rue du Rhône",
                zipCode: "1204",
                city: "Geneva",
                country: "Switzerland",
                bedrooms: 3,
                bathrooms: 2,
                area: 200,
                imageURLs: [
                    "https://images.unsplash.com/photo-1600607687644-c7171b42498f?ixlib=rb-4.0.3",
                    "https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?ixlib=rb-4.0.3"
                ],
                createdAt: Date(),
                updatedAt: Date()
            ),
            Property(
                id: UUID().uuidString,
                title: "Historic Townhouse",
                price: 1850000,
                description: "Beautifully renovated 18th-century townhouse in Old Town. Original features combined with modern amenities.",
                address: "12 Grand-Rue",
                zipCode: "1204",
                city: "Geneva",
                country: "Switzerland",
                bedrooms: 5,
                bathrooms: 3,
                area: 320,
                imageURLs: [
                    "https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?ixlib=rb-4.0.3",
                    "https://images.unsplash.com/photo-1600566753086-00b2a0069a2c?ixlib=rb-4.0.3"
                ],
                createdAt: Date(),
                updatedAt: Date()
            ),
            Property(
                id: UUID().uuidString,
                title: "Mountain View Chalet",
                price: 1650000,
                description: "Authentic Swiss chalet with breathtaking views of Mont Blanc. Perfect for both summer and winter activities.",
                address: "78 Route des Alpes",
                zipCode: "1264",
                city: "Saint-Cergue",
                country: "Switzerland",
                bedrooms: 4,
                bathrooms: 2,
                area: 240,
                imageURLs: [
                    "https://images.unsplash.com/photo-1600585154526-990dced4db0d?ixlib=rb-4.0.3",
                    "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?ixlib=rb-4.0.3"
                ],
                createdAt: Date(),
                updatedAt: Date()
            ),
            Property(
                id: UUID().uuidString,
                title: "Contemporary Garden Apartment",
                price: 980000,
                description: "Modern ground-floor apartment with private garden. Open-plan living space and high-end finishes throughout.",
                address: "34 Avenue de Champel",
                zipCode: "1206",
                city: "Geneva",
                country: "Switzerland",
                bedrooms: 2,
                bathrooms: 2,
                area: 150,
                imageURLs: [
                    "https://images.unsplash.com/photo-1600573472591-761f0e56eefa?ixlib=rb-4.0.3",
                    "https://images.unsplash.com/photo-1600573472573-8f80d9bf4a7c?ixlib=rb-4.0.3"
                ],
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
        
        for property in sampleProperties {
            try await addProperty(property)
        }
    }
}