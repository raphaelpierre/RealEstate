//
//  User.swift
//  RealEstate
//
//  Created by Raphael PIERRE on 15.01.2025.
//

import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    var id: String
    var email: String
    var isAdmin: Bool
    var createdAt: Date
    
    init(id: String = UUID().uuidString,
         email: String,
         isAdmin: Bool = false,
         createdAt: Date = Date()) {
        self.id = id
        self.email = email
        self.isAdmin = isAdmin
        self.createdAt = createdAt
    }
    
    static func fromFirestore(_ document: DocumentSnapshot) -> User? {
        guard let data = document.data() else { return nil }
        
        return User(
            id: document.documentID,
            email: data["email"] as? String ?? "",
            isAdmin: data["isAdmin"] as? Bool ?? false,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
    
    func toFirestoreData() -> [String: Any] {
        return [
            "email": email,
            "isAdmin": isAdmin,
            "createdAt": Timestamp(date: createdAt)
        ]
    }
}
