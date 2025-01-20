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
    var zipCode: String
    var city: String
    var country: String
    var bedrooms: Int
    var bathrooms: Int
    var area: Double
    var imageURLs: [String]
    var createdAt: Date
    var updatedAt: Date
    var isFavorite: Bool = false
    
    init(id: String = UUID().uuidString,
         title: String,
         price: Double,
         description: String,
         address: String,
         zipCode: String = "",
         city: String = "",
         country: String = "",
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
        self.zipCode = zipCode
        self.city = city
        self.country = country
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
               lhs.zipCode == rhs.zipCode &&
               lhs.city == rhs.city &&
               lhs.country == rhs.country &&
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
            zipCode: data["zipCode"] as? String ?? "",
            city: data["city"] as? String ?? "",
            country: data["country"] as? String ?? "",
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
            "zipCode": zipCode,
            "city": city,
            "country": country,
            "bedrooms": bedrooms,
            "bathrooms": bathrooms,
            "area": area,
            "imageURLs": imageURLs,
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt)
        ]
    }
}

// MARK: - Preview Helper
extension Property {
    static let example = Property(
        title: "Luxury Villa with Ocean View",
        price: 1250000,
        description: "Beautiful luxury villa with panoramic ocean views, featuring modern amenities and elegant design.",
        address: "123 Ocean Drive",
        zipCode: "90210",
        city: "Malibu",
        country: "United States",
        bedrooms: 4,
        bathrooms: 3,
        area: 3500,
        imageURLs: []
    )
}