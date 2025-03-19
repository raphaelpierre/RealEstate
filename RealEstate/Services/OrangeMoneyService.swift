import Foundation

enum OrangeMoneyError: Error {
    case invalidPhoneNumber
    case insufficientFunds
    case networkError
    case transactionFailed(String)
    
    var localizedDescription: String {
        switch self {
        case .invalidPhoneNumber:
            return "invalid_phone_number".localized
        case .insufficientFunds:
            return "insufficient_funds".localized
        case .networkError:
            return "network_error".localized
        case .transactionFailed(let message):
            return message
        }
    }
}

class OrangeMoneyService: ObservableObject {
    @Published var isProcessing = false
    
    private let apiKey: String = "YOUR_ORANGE_MONEY_API_KEY"
    private let apiEndpoint = "https://api.orange.com/orange-money-webpay"
    
    func validatePhoneNumber(_ phoneNumber: String) -> Bool {
        // Format attendu: +XXX XXXXXXXX
        let phoneRegex = "^\\+[0-9]{3}\\s[0-9]{8}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phoneNumber)
    }
    
    func initiatePayment(amount: Double, phoneNumber: String, propertyId: String) async throws -> OrangeMoneyTransaction {
        guard validatePhoneNumber(phoneNumber) else {
            throw OrangeMoneyError.invalidPhoneNumber
        }
        
        isProcessing = true
        defer { isProcessing = false }
        
        // Simuler l'appel API
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000) // 2 secondes
        
        // En production, vous feriez un vrai appel API ici
        let transaction = OrangeMoneyTransaction(
            id: UUID().uuidString,
            propertyId: propertyId,
            buyerId: await AuthManager.shared.currentUser?.id ?? "",
            sellerId: "", // À récupérer depuis la propriété
            amount: amount,
            phoneNumber: phoneNumber,
            status: .pending,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        // Sauvegarder la transaction dans Firestore
        try await FirebaseManager.shared.saveOrangeMoneyTransaction(transaction)
        
        return transaction
    }
    
    func checkTransactionStatus(transactionId: String) async throws -> TransactionStatus {
        // Simuler l'appel API
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        return .completed
    }
} 