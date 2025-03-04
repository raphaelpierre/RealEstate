//
//  LocalizationHelper.swift
//  RealEstate
//
//  Created by Raphael PIERRE on 15.01.2025.
//

import Foundation
import SwiftUI

// MARK: - String Extension for Localization
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
}

// MARK: - View Extension for Localization
extension View {
    /// Applies localized accessibility identifiers to the view
    func localizedAccessibilityIdentifier(_ identifier: String) -> some View {
        return self.accessibilityIdentifier(identifier.localized)
    }
}

// MARK: - Localization Manager
class LocalizationManager {
    static let shared = LocalizationManager()
    
    private init() {}
    
    /// Get the current app language
    var currentLanguage: String {
        return Locale.current.languageCode ?? "en"
    }
    
    /// Check if the app is running in French
    var isFrench: Bool {
        return currentLanguage == "fr"
    }
    
    /// Format currency based on the current locale
    func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        if isFrench {
            formatter.locale = Locale(identifier: "fr_FR")
        } else {
            formatter.locale = Locale(identifier: "en_US")
        }
        
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
    
    /// Format area based on the current locale (square meters for French, square feet for English)
    func formatArea(_ area: Double) -> String {
        if isFrench {
            return "\(Int(area)) \("square_meters".localized)"
        } else {
            // Convert to square feet for English
            let sqft = area * 10.764
            return "\(Int(sqft)) \("square_feet".localized)"
        }
    }
    
    /// Format date based on the current locale
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        if isFrench {
            formatter.locale = Locale(identifier: "fr_FR")
        } else {
            formatter.locale = Locale(identifier: "en_US")
        }
        
        return formatter.string(from: date)
    }
}

// MARK: - Preview Helper
extension View {
    /// Helper function to preview a view in French
    func previewFrench() -> some View {
        return self
            .environment(\.locale, Locale(identifier: "fr"))
    }
}

// Example usage in previews:
/*
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewDisplayName("English")
            
            ContentView()
                .previewFrench()
                .previewDisplayName("French")
        }
    }
}
*/ 