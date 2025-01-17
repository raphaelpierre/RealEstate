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

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    private let db = Firestore.firestore()
    private let storage: Storage
    
    @Published var properties: [Property] = []
    @Published var isAdmin = false // TODO: Replace with proper auth
    
    private init() {
        // Ensure Firebase is configured
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        storage = Storage.storage()
    }
    
    func fetchProperties() async throws {
        let snapshot = try await db.collection("properties").getDocuments()
        self.properties = snapshot.documents.compactMap { document in
            Property.fromFirestore(document)
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
}