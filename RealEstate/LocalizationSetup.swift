import SwiftUI

// This file contains helpers to set up localization in the app

// MARK: - Localization Setup
struct LocalizationSetup {
    static func initialize() {
        // Force load of localization bundles
        _ = Bundle.main.localizedString(forKey: "app_name", value: nil, table: nil)
        
        // Set up the LocalizationManager
        let localizationManager = LocalizationManager.shared
        
        // Check for saved language preference
        if let languages = UserDefaults.standard.object(forKey: "AppleLanguages") as? [String],
           let preferredLanguage = languages.first {
            localizationManager.updateLocale(Locale(identifier: preferredLanguage))
            print("Initializing with saved language preference: \(preferredLanguage)")
        } else {
            // Initialize with current locale
            if let languageCode = Locale.current.language.languageCode?.identifier {
                localizationManager.updateLocale(Locale(identifier: languageCode))
            }
        }
        
        // Print some debug information
        print("Localization initialized with language: \(localizationManager.currentLanguage)")
        print("App name in current language: \("app_name".localized)")
        print("Available localizations: \(Bundle.main.localizations)")
    }
}

// MARK: - App Extension
extension View {
    func withLocalization() -> some View {
        self.environmentObject(LocalizationManager.shared)
    }
}

// Usage in your App file:
/*
@main
struct RealEstateApp: App {
    init() {
        LocalizationSetup.initialize()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .withLocalization()
        }
    }
}
*/ 