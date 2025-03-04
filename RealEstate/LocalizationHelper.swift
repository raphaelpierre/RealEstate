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
        let localizedString = NSLocalizedString(self, bundle: .main, comment: "")
        if localizedString == self && self != "app_name" {
            print("Warning: No localization found for key: \(self)")
            print("Available localizations: \(Bundle.main.localizations)")
            print("Current language: \(Locale.current.language.languageCode?.identifier ?? "unknown")")
            print("Preferred languages: \(Locale.preferredLanguages)")
        }
        return localizedString
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
}

// MARK: - Environment Key for Locale
struct LocaleKey: EnvironmentKey {
    static let defaultValue: Locale = .current
}

extension EnvironmentValues {
    var locale: Locale {
        get { self[LocaleKey.self] }
        set { self[LocaleKey.self] = newValue }
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
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLocale: Locale = .current
    @Published var refreshToggle = false // Used to force view refreshes
    
    private init() {
        // Load user's preferred language if available
        loadSavedLanguage()
        
        // Listen for locale changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(localeDidChange),
            name: NSLocale.currentLocaleDidChangeNotification,
            object: nil
        )
        
        // Listen for language change notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageChanged),
            name: Notification.Name("LanguageChanged"),
            object: nil
        )
    }
    
    private func loadSavedLanguage() {
        if let languages = UserDefaults.standard.object(forKey: "AppleLanguages") as? [String],
           let preferredLanguage = languages.first {
            updateLocale(Locale(identifier: preferredLanguage))
        }
    }
    
    @objc private func localeDidChange() {
        currentLocale = Locale.current
        objectWillChange.send()
    }
    
    @objc private func languageChanged() {
        // Force UI refresh
        refreshToggle.toggle()
        objectWillChange.send()
    }
    
    /// Get the current app language
    var currentLanguage: String {
        return currentLocale.language.languageCode?.identifier ?? "en"
    }
    
    /// Check if the app is running in French
    var isFrench: Bool {
        return currentLanguage == "fr"
    }
    
    /// Update the current locale (for previews and testing)
    func updateLocale(_ locale: Locale) {
        currentLocale = locale
        refreshToggle.toggle()
        objectWillChange.send()
        
        // Set the preferred language for the app
        UserDefaults.standard.set([locale.identifier], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Force reload of bundle
        Bundle.main.localizedString(forKey: "app_name", value: nil, table: nil)
        
        // Post notification for app-wide language change
        NotificationCenter.default.post(name: Notification.Name("LanguageChanged"), object: nil)
        
        print("Language updated to: \(locale.identifier)")
        print("Current localized app name: \("app_name".localized)")
        print("Current localized home: \("home".localized)")
        print("Current localized profile: \("profile".localized)")
        print("Current localized favorites: \("favorites".localized)")
    }
    
    /// Format currency based on the current locale
    func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        if currentLocale.language.languageCode?.identifier == "fr" {
            formatter.locale = Locale(identifier: "fr_FR")
        } else {
            formatter.locale = Locale(identifier: "en_US")
        }
        
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
    
    /// Format area based on the current locale (square meters for French, square feet for English)
    func formatArea(_ area: Double) -> String {
        if currentLocale.language.languageCode?.identifier == "fr" {
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
        
        if currentLocale.language.languageCode?.identifier == "fr" {
            formatter.locale = Locale(identifier: "fr_FR")
        } else {
            formatter.locale = Locale(identifier: "en_US")
        }
        
        return formatter.string(from: date)
    }
}

// MARK: - Preview Helper
struct LocalePreview<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        Group {
            content
                .previewDisplayName("English")
                .environment(\.locale, Locale(identifier: "en"))
                .onAppear {
                    LocalizationManager.shared.updateLocale(Locale(identifier: "en"))
                }
            
            content
                .previewDisplayName("French")
                .environment(\.locale, Locale(identifier: "fr"))
                .onAppear {
                    LocalizationManager.shared.updateLocale(Locale(identifier: "fr"))
                }
        }
    }
}

// Example usage in previews:
/*
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LocalePreview {
            ContentView()
        }
    }
}
*/ 