//
//  FirebaseManager.swift
//  RealEstate
//
//  Created by Raphael PIERRE on 15.01.2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    @Published var properties: [Property] = []
    @Published var isAdmin = false // TODO: Replace with proper auth
    
    private init() {}
    
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
        let filename = UUID().uuidString
        let storageRef = storage.reference().child("property_images/\(filename).jpg")
        _ = try await storageRef.putDataAsync(imageData)
        let downloadURL = try await storageRef.downloadURL()
        return downloadURL.absoluteString
    }
}