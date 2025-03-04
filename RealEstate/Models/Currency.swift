import Foundation

enum Currency: String, CaseIterable, Identifiable {
    case usd
    case eur
    case cfa // CFA Franc
    
    var id: String { self.rawValue }
    
    var symbol: String {
        switch self {
        case .usd: return "$"
        case .eur: return "€"
        case .cfa: return "CFA "
        }
    }
    
    var name: String {
        switch self {
        case .usd: return "us_dollars".localized
        case .eur: return "euros".localized
        case .cfa: return "francs_cfa".localized
        }
    }
} 