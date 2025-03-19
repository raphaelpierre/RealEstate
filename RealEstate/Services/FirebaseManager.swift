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
import CoreLocation

@MainActor
class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private let storage: Storage
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    @Published private(set) var properties: [Property] = []
    @Published var isAdmin = false // TODO: Replace with proper auth
    @Published private(set) var favoritePropertyIds: Set<String> = []
    
    init() {
        // Ensure Firebase is configured
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        storage = Storage.storage()
        
        // Store the auth state listener handle
        authStateHandle = auth.addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                if user != nil {
                    do {
                        // First load favorites
                        try await self.loadFavorites()
                        
                        // Then fetch properties to ensure they have correct favorite status
                        try await self.fetchProperties()
                    } catch {
                        print("❌ Error loading data after auth state change: \(error.localizedDescription)")
                    }
                } else {
                    self.favoritePropertyIds.removeAll()
                    try? await self.fetchProperties() // Reload properties without favorites
                }
            }
        }
        
        // Initial properties load
        Task {
            try? await fetchProperties()
        }
    }
    
    deinit {
        // Remove the auth state listener when the manager is deallocated
        if let handle = authStateHandle {
            auth.removeStateDidChangeListener(handle)
        }
    }
    
    // MARK: - Properties Management
    
    @MainActor
    func getProperty(id: String) async throws -> Property {
        let document = try await db.collection("properties").document(id).getDocument()
        guard var property = Property.fromFirestore(document) else {
            throw NSError(
                domain: "FirebaseManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to load property with ID: \(id)"]
            )
        }
        
        // Update favorite status
        property.isFavorite = favoritePropertyIds.contains(property.id)
        return property
    }
    
    @MainActor
    func fetchProperties() async throws {
        let snapshot = try await db.collection("properties").getDocuments()
        
        let fetchedProperties = snapshot.documents.compactMap { document -> Property? in
            guard var property = Property.fromFirestore(document) else { return nil }
            property.isFavorite = self.favoritePropertyIds.contains(property.id)
            return property
        }
        
        self.properties = fetchedProperties
    }
    
    private func addProperty(_ property: Property) async throws -> Property {
        let docRef = db.collection("properties").document(property.id)
        
        let encodedProperty = try Firestore.Encoder().encode(property)
        try await docRef.setData(encodedProperty)
        
        return property
    }
    
    private func updateProperty(_ property: Property) async throws -> Property {
        let docRef = db.collection("properties").document(property.id)
        
        let encodedProperty = try Firestore.Encoder().encode(property)
        try await docRef.updateData(encodedProperty)
        
        return property
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
    
    @MainActor
    func loadFavorites() async throws {
        guard let userId = auth.currentUser?.uid else {
            print("❌ Cannot load favorites: No authenticated user")
            throw AuthError.userNotAuthenticated
        }
        
        let userRef = db.collection("users").document(userId)
        let favoritesRef = userRef.collection("favorites")
        
        do {
            let snapshot = try await favoritesRef.getDocuments()
            let favoriteIds = snapshot.documents.map { $0.documentID }
            self.favoritePropertyIds = Set(favoriteIds)
            
            // Update existing properties with favorite status
            self.updatePropertiesFavoriteStatus()
        } catch {
            print("❌ Error loading favorites: \(error.localizedDescription)")
            throw FavoriteError.loadError(error)
        }
    }
    
    @MainActor
    func toggleFavorite(for property: Property) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw AuthError.userNotAuthenticated
        }
        
        let userRef = db.collection("users").document(userId)
        let favoriteRef = userRef.collection("favorites").document(property.id)
        
        do {
            // First verify if the document exists
            let docSnapshot = try await favoriteRef.getDocument()
            let isCurrentlyFavorite = docSnapshot.exists
            
            if isCurrentlyFavorite {
                try await favoriteRef.delete()
                favoritePropertyIds.remove(property.id)
            } else {
                // Create the data dictionary on the main actor
                let data: [String: Any] = [
                    "propertyId": property.id,
                    "addedAt": FieldValue.serverTimestamp(),
                    "title": property.title,
                    "price": property.price,
                    "imageURL": property.imageURLs.first ?? "",
                    "address": property.address,
                    "city": property.city,
                    "bedrooms": property.bedrooms,
                    "bathrooms": property.bathrooms,
                    "area": property.area,
                    "updatedAt": FieldValue.serverTimestamp()
                ]
                
                // Use the data dictionary in the async context
                try await favoriteRef.setData(data)
                favoritePropertyIds.insert(property.id)
            }
            
            // Update local state
            self.updatePropertiesFavoriteStatus()
            
        } catch {
            print("❌ Error toggling favorite: \(error.localizedDescription)")
            throw FavoriteError.toggleError(error)
        }
    }
    
    @MainActor
    private func updatePropertiesFavoriteStatus() {
        for i in properties.indices {
            let isFavorite = favoritePropertyIds.contains(properties[i].id)
            properties[i].isFavorite = isFavorite
        }
    }
    
    func isFavorite(_ propertyId: String) -> Bool {
        return favoritePropertyIds.contains(propertyId)
    }
    
    // MARK: - Error Types
    
    enum AuthError: LocalizedError {
        case userNotAuthenticated
        
        var errorDescription: String? {
            switch self {
            case .userNotAuthenticated:
                return "You must be signed in to perform this action"
            }
        }
    }
    
    enum FavoriteError: LocalizedError {
        case loadError(Error)
        case toggleError(Error)
        
        var errorDescription: String? {
            switch self {
            case .loadError(let error):
                return "Failed to load favorites: \(error.localizedDescription)"
            case .toggleError(let error):
                return "Failed to update favorite: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Cleanup Methods
    
    @MainActor
    func cleanupUserData() async {
        // Clear local favorites
        favoritePropertyIds.removeAll()
        updatePropertiesFavoriteStatus()
        
        // Clear local properties
        properties.removeAll()
    }
    
    @MainActor
    func deleteAllFavorites() async throws {
        guard let userId = auth.currentUser?.uid else { return }
        
        // Get all favorites
        let favoritesRef = db.collection("users").document(userId).collection("favorites")
        let snapshot = try await favoritesRef.getDocuments()
        
        // Delete each favorite
        for document in snapshot.documents {
            try await document.reference.delete()
        }
        
        // Clear local state
        favoritePropertyIds.removeAll()
        updatePropertiesFavoriteStatus()
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
            _ = try await addProperty(property)
        }
    }
    
    // Update method to use geocoding before saving a property
    func saveProperty(_ property: Property) async throws -> Property {
        var propertyToSave = property
        
        // Generate a new ID if the property is new (empty ID)
        if propertyToSave.id.isEmpty {
            propertyToSave.id = UUID().uuidString
        }
        
        do {
            // Attempt to geocode the address
            let geocodedProperty = try await geocodeAddress(for: propertyToSave)
            
            // Check if the property already exists in Firestore
            let docRef = db.collection("properties").document(geocodedProperty.id)
            let docSnapshot = try await docRef.getDocument()
            
            let savedProperty: Property
            if docSnapshot.exists {
                // If the document exists, update it
                savedProperty = try await updateProperty(geocodedProperty)
            } else {
                // If the document doesn't exist, add it as a new document
                savedProperty = try await addProperty(geocodedProperty)
            }
            
            // Update local properties array
            if let index = properties.firstIndex(where: { $0.id == savedProperty.id }) {
                properties[index] = savedProperty
            } else {
                properties.append(savedProperty)
            }
            
            return savedProperty
            
        } catch {
            // If geocoding fails, save the property without coordinates
            print("⚠️ Geocoding failed: \(error.localizedDescription). Saving property without coordinates.")
            
            // Check if the property already exists in Firestore
            let docRef = db.collection("properties").document(propertyToSave.id)
            let docSnapshot = try await docRef.getDocument()
            
            let savedProperty: Property
            if docSnapshot.exists {
                // If the document exists, update it
                savedProperty = try await updateProperty(propertyToSave)
            } else {
                // If the document doesn't exist, add it as a new document
                savedProperty = try await addProperty(propertyToSave)
            }
            
            // Update local properties array
            if let index = properties.firstIndex(where: { $0.id == savedProperty.id }) {
                properties[index] = savedProperty
            } else {
                properties.append(savedProperty)
            }
            
            return savedProperty
        }
    }
    
    // MARK: - User Management
    
    @MainActor
    func fetchAllUsers() async throws -> [User] {
        let snapshot = try await db.collection("users").getDocuments()
        return snapshot.documents.compactMap { User.fromFirestore($0) }
    }
    
    @MainActor
    func updateUser(_ user: User) async throws {
        let docRef = db.collection("users").document(user.id)
        try await docRef.updateData(user.toFirestoreData())
    }
    
    @MainActor
    func deleteUser(_ userId: String) async throws {
        // Delete user document from Firestore
        try await db.collection("users").document(userId).delete()
        
        // Delete user's favorites
        let favoritesRef = db.collection("users").document(userId).collection("favorites")
        let snapshot = try await favoritesRef.getDocuments()
        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }
    
    // MARK: - Orange Money Transactions
    
    @MainActor
    func saveOrangeMoneyTransaction(_ transaction: OrangeMoneyTransaction) async throws {
        let docRef = db.collection("transactions").document(transaction.id)
        let encodedTransaction = try Firestore.Encoder().encode(transaction)
        try await docRef.setData(encodedTransaction)
    }
    
    @MainActor
    func getOrangeMoneyTransaction(id: String) async throws -> OrangeMoneyTransaction {
        let document = try await db.collection("transactions").document(id).getDocument()
        guard let transaction = try? document.data(as: OrangeMoneyTransaction.self) else {
            throw NSError(
                domain: "FirebaseManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to load transaction with ID: \(id)"]
            )
        }
        return transaction
    }
    
    @MainActor
    func updateOrangeMoneyTransactionStatus(id: String, status: TransactionStatus) async throws {
        let docRef = db.collection("transactions").document(id)
        try await docRef.updateData([
            "status": status.rawValue,
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }
}

extension FirebaseManager {
    // Geocoding method to convert address to coordinates
    func geocodeAddress(for property: Property) async throws -> Property {
        var updatedProperty = property
        
        let geocoder = CLGeocoder()
        let addressString = "\(property.address), \(property.city), \(property.country) \(property.zipCode)"
        
        return try await withCheckedThrowingContinuation { continuation in
            geocoder.geocodeAddressString(addressString) { placemarks, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                if let placemark = placemarks?.first,
                   let location = placemark.location {
                    updatedProperty.latitude = location.coordinate.latitude
                    updatedProperty.longitude = location.coordinate.longitude
                    continuation.resume(returning: updatedProperty)
                } else {
                    continuation.resume(throwing: NSError(domain: "GeocodeError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find coordinates for the given address"]))
                }
            }
        }
    }
    
    // Method to update geolocation for all existing properties
    func updateAllPropertiesGeolocation() async throws {
        // Fetch all existing properties
        try await fetchProperties()
        
        // Create a task group to process properties concurrently
        try await withThrowingTaskGroup(of: Void.self) { group in
            for property in properties {
                // Skip properties that already have coordinates
                guard property.latitude == 0.0 && property.longitude == 0.0 else {
                    continue
                }
                
                // Add a task to geocode each property
                group.addTask {
                    do {
                        // Attempt to geocode the property
                        let geocodedProperty = try await self.geocodeAddress(for: property)
                        
                        // Update the property in Firestore if coordinates were found
                        if geocodedProperty.latitude != 0.0 && geocodedProperty.longitude != 0.0 {
                            _ = try await self.updateProperty(geocodedProperty)
                            print("✅ Updated geolocation for property: \(geocodedProperty.title)")
                        }
                    } catch {
                        print("⚠️ Geocoding failed for property: \(property.title). Error: \(error.localizedDescription)")
                    }
                }
            }
            
            // Wait for all tasks to complete
            try await group.waitForAll()
        }
        
        // Refresh properties after updates
        try await fetchProperties()
    }
    
    // Modify triggerGeolocationUpdate to be a fully asynchronous method
    func triggerGeolocationUpdate() async {
        do {
            try await updateAllPropertiesGeolocation()
        } catch {
            print("Error updating properties geolocation: \(error.localizedDescription)")
        }
    }
}