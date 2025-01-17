//
//  Property.swift
//  RealEstate
//
//  Created by Raphael PIERRE on 15.01.2025.
//

import Foundation
import FirebaseFirestore

struct Property: Identifiable, Codable, Equatable {
    var id: String
    var title: String
    var price: Double
    var description: String
    var address: String
    var bedrooms: Int
    var bathrooms: Int
    var area: Double
    var imageURLs: [String]
    var createdAt: Date
    var updatedAt: Date
    
    init(id: String = UUID().uuidString,
         title: String,
         price: Double,
         description: String,
         address: String,
         bedrooms: Int,
         bathrooms: Int,
         area: Double,
         imageURLs: [String] = [],
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.price = price
        self.description = description
        self.address = address
        self.bedrooms = bedrooms
        self.bathrooms = bathrooms
        self.area = area
        self.imageURLs = imageURLs
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Implement Equatable
    static func == (lhs: Property, rhs: Property) -> Bool {
        return lhs.id == rhs.id &&
               lhs.title == rhs.title &&
               lhs.price == rhs.price &&
               lhs.description == rhs.description &&
               lhs.address == rhs.address &&
               lhs.bedrooms == rhs.bedrooms &&
               lhs.bathrooms == rhs.bathrooms &&
               lhs.area == rhs.area &&
               lhs.imageURLs == rhs.imageURLs &&
               lhs.createdAt == rhs.createdAt &&
               lhs.updatedAt == rhs.updatedAt
    }
    
    static func fromFirestore(_ document: DocumentSnapshot) -> Property? {
        guard let data = document.data() else { return nil }
        
        return Property(
            id: document.documentID,
            title: data["title"] as? String ?? "",
            price: data["price"] as? Double ?? 0.0,
            description: data["description"] as? String ?? "",
            address: data["address"] as? String ?? "",
            bedrooms: data["bedrooms"] as? Int ?? 0,
            bathrooms: data["bathrooms"] as? Int ?? 0,
            area: data["area"] as? Double ?? 0.0,
            imageURLs: data["imageURLs"] as? [String] ?? [],
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
            updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
    
    func toFirestoreData() -> [String: Any] {
        return [
            "title": title,
            "price": price,
            "description": description,
            "address": address,
            "bedrooms": bedrooms,
            "bathrooms": bathrooms,
            "area": area,
            "imageURLs": imageURLs,
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt)
        ]
    }
}