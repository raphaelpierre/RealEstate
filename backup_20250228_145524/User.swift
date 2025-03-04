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
    var displayName: String?
    var isAdmin: Bool
    var createdAt: Date
    
    init(id: String = UUID().uuidString,
         email: String,
         displayName: String? = nil,
         isAdmin: Bool = false,
         createdAt: Date = Date()) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.isAdmin = isAdmin
        self.createdAt = createdAt
    }
    
    static func fromFirestore(_ document: DocumentSnapshot) -> User? {
        guard let data = document.data() else { return nil }
        
        return User(
            id: document.documentID,
            email: data["email"] as? String ?? "",
            displayName: data["displayName"] as? String,
            isAdmin: data["isAdmin"] as? Bool ?? false,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
    
    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "email": email,
            "isAdmin": isAdmin,
            "createdAt": Timestamp(date: createdAt)
        ]
        
        if let displayName = displayName {
            data["displayName"] = displayName
        }
        
        return data
    }
}
