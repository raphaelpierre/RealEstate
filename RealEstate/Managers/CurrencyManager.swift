import Foundation
import Combine

class CurrencyManager: ObservableObject {
    static let shared = CurrencyManager()
    
    private let defaults = UserDefaults.standard
    private let currencyKey = "selectedCurrency"
    
    @Published var selectedCurrency: Currency {
        didSet {
            saveSelectedCurrency()
        }
    }
    @Published var refreshToggle = false
    
    // Exchange rates relative to USD (1 USD = X units of currency)
    private let exchangeRates: [Currency: Double] = [
        .usd: 1.0,
        .eur: 0.92,  // Example rate: 1 USD = 0.92 EUR
        .cfa: 604.0  // Example rate: 1 USD = 604 CFA Francs
    ]
    
    // Internal initializer for preview purposes
    init(isPreview: Bool = false) {
        if isPreview {
            self.selectedCurrency = .usd
        } else {
            // Load saved currency or default to USD
            if let savedCurrencyString = defaults.string(forKey: currencyKey),
               let savedCurrency = Currency(rawValue: savedCurrencyString) {
                self.selectedCurrency = savedCurrency
            } else {
                self.selectedCurrency = .usd
            }
        }
    }
    
    // Preview helper
    #if DEBUG
    static func preview() -> CurrencyManager {
        return CurrencyManager(isPreview: true)
    }
    #endif
    
    private func saveSelectedCurrency() {
        defaults.set(selectedCurrency.rawValue, forKey: currencyKey)
    }
    
    func changeCurrency(to currency: Currency) {
        selectedCurrency = currency
        refreshToggle.toggle()
    }
    
    func convert(_ amount: Double, from sourceCurrency: Currency = .usd) -> Double {
        guard let sourceRate = exchangeRates[sourceCurrency], 
              let targetRate = exchangeRates[selectedCurrency] else {
            return amount
        }
        
        // Convert to USD first (if not already USD), then to target currency
        let amountInUSD = amount / sourceRate
        return amountInUSD * targetRate
    }
    
    func formatPrice(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        
        switch selectedCurrency {
        case .usd:
            formatter.currencySymbol = "$"
        case .eur:
            formatter.currencySymbol = "€"
        case .cfa:
            formatter.currencySymbol = "CFA "
        }
        
        return formatter.string(from: NSNumber(value: amount)) ?? "\(selectedCurrency.symbol)\(Int(amount))"
    }
} 