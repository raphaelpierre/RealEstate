import Foundation
import FirebaseFirestore

enum TransactionStatus: String, Codable {
    case pending
    case completed
    case failed
}

struct OrangeMoneyTransaction: Identifiable, Codable {
    let id: String
    let propertyId: String
    let buyerId: String
    let sellerId: String
    let amount: Double
    let status: TransactionStatus
    let phoneNumber: String
    let createdAt: Date
    let updatedAt: Date
    
    init(id: String = UUID().uuidString,
         propertyId: String,
         buyerId: String,
         sellerId: String,
         amount: Double,
         phoneNumber: String,
         status: TransactionStatus = .pending,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.propertyId = propertyId
        self.buyerId = buyerId
        self.sellerId = sellerId
        self.amount = amount
        self.phoneNumber = phoneNumber
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
} 