//
//  Property.swift
//  RealEstate
//
//  Created by Raphael PIERRE on 15.01.2025.
//

import Foundation
import FirebaseFirestore

struct ContactInfo: Codable, Equatable {
    var whatsapp: String
    
    init(whatsapp: String = "") {
        self.whatsapp = whatsapp
    }
    
    // Validate WhatsApp number (basic validation)
    func isValidWhatsApp() -> Bool {
        let phoneRegex = "^\\+?[1-9]\\d{1,14}$"
        let phonePred = NSPredicate(format:"SELF MATCHES %@", phoneRegex)
        return whatsapp.isEmpty || phonePred.evaluate(with: whatsapp)
    }
}

struct Property: Identifiable, Codable, Equatable, Hashable {
    var id: String
    var userId: String
    var title: String
    var price: Double
    var description: String
    var address: String
    var contact: ContactInfo
    var zipCode: String
    var city: String
    var country: String
    var bedrooms: Int
    var bathrooms: Int
    var area: Double
    var type: String
    var purpose: String
    var imageURLs: [String]
    var createdAt: Date
    var updatedAt: Date
    var isFavorite: Bool = false
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    init(id: String = UUID().uuidString,
         userId: String = "",
         title: String,
         price: Double,
         description: String,
         address: String,
         contact: ContactInfo = ContactInfo(),
         zipCode: String = "",
         city: String = "",
         country: String = "",
         bedrooms: Int,
         bathrooms: Int,
         area: Double,
         type: String = "House",
         purpose: String = "Buy",
         imageURLs: [String] = [],
         createdAt: Date = Date(),
         updatedAt: Date = Date(),
         isFavorite: Bool = false,
         latitude: Double = 0.0,
         longitude: Double = 0.0) {
        self.id = id
        self.userId = userId
        self.title = title
        self.price = price
        self.description = description
        self.address = address
        self.contact = contact
        self.zipCode = zipCode
        self.city = city
        self.country = country
        self.bedrooms = bedrooms
        self.bathrooms = bathrooms
        self.area = area
        self.type = type
        self.purpose = purpose
        self.imageURLs = imageURLs
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isFavorite = isFavorite
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // Implement Equatable
    static func == (lhs: Property, rhs: Property) -> Bool {
        return lhs.id == rhs.id &&
               lhs.userId == rhs.userId &&
               lhs.title == rhs.title &&
               lhs.price == rhs.price &&
               lhs.description == rhs.description &&
               lhs.address == rhs.address &&
               lhs.contact == rhs.contact &&
               lhs.zipCode == rhs.zipCode &&
               lhs.city == rhs.city &&
               lhs.country == rhs.country &&
               lhs.bedrooms == rhs.bedrooms &&
               lhs.bathrooms == rhs.bathrooms &&
               lhs.area == rhs.area &&
               lhs.type == rhs.type &&
               lhs.purpose == rhs.purpose &&
               lhs.imageURLs == rhs.imageURLs &&
               lhs.createdAt == rhs.createdAt &&
               lhs.updatedAt == rhs.updatedAt &&
               lhs.isFavorite == rhs.isFavorite &&
               lhs.latitude == rhs.latitude &&
               lhs.longitude == rhs.longitude
    }
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func fromFirestore(_ document: DocumentSnapshot) -> Property? {
        guard let data = document.data() else { return nil }
        
        return Property(
            id: document.documentID,
            userId: data["userId"] as? String ?? "",
            title: data["title"] as? String ?? "",
            price: data["price"] as? Double ?? 0.0,
            description: data["description"] as? String ?? "",
            address: data["address"] as? String ?? "",
            contact: ContactInfo(whatsapp: data["contact"] as? String ?? ""),
            zipCode: data["zipCode"] as? String ?? "",
            city: data["city"] as? String ?? "",
            country: data["country"] as? String ?? "",
            bedrooms: data["bedrooms"] as? Int ?? 0,
            bathrooms: data["bathrooms"] as? Int ?? 0,
            area: data["area"] as? Double ?? 0.0,
            type: data["type"] as? String ?? "House",
            purpose: data["purpose"] as? String ?? "Buy",
            imageURLs: data["imageURLs"] as? [String] ?? [],
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
            updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date(),
            latitude: data["latitude"] as? Double ?? 0.0,
            longitude: data["longitude"] as? Double ?? 0.0
        )
    }
    
    func toFirestoreData() -> [String: Any] {
        return [
            "userId": userId,
            "title": title,
            "price": price,
            "description": description,
            "address": address,
            "contact": contact.whatsapp,
            "zipCode": zipCode,
            "city": city,
            "country": country,
            "bedrooms": bedrooms,
            "bathrooms": bathrooms,
            "area": area,
            "type": type,
            "purpose": purpose,
            "imageURLs": imageURLs,
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt),
            "latitude": latitude,
            "longitude": longitude
        ]
    }
}

// MARK: - Preview Helper
extension Property {
    static let example = Property(
        userId: "example_user_id",
        title: "Luxury Villa with Ocean View",
        price: 1250000,
        description: "Beautiful luxury villa with panoramic ocean views, featuring modern amenities and elegant design.",
        address: "123 Ocean Drive",
        contact: ContactInfo(whatsapp: "+1234567890"),
        zipCode: "90210",
        city: "Malibu",
        country: "United States",
        bedrooms: 4,
        bathrooms: 3,
        area: 3500,
        type: "Villa",
        purpose: "Rent",
        imageURLs: [],
        latitude: 34.0224,
        longitude: -118.8011
    )
}