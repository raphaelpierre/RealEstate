import SwiftUI

/// A component that allows users to switch between languages
struct LanguageSwitcher: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var showingLanguageOptions = false
    @State private var showingRestartAlert = false
    
    var body: some View {
        Button(action: {
            showingLanguageOptions = true
        }) {
            HStack(spacing: 4) {
                Image(systemName: "globe")
                Text(currentLanguageDisplay)
                    .fontWeight(.medium)
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .actionSheet(isPresented: $showingLanguageOptions) {
            ActionSheet(
                title: Text("select_language".localized),
                buttons: [
                    .default(Text("English")) {
                        changeLanguage(to: "en")
                    },
                    .default(Text("Français")) {
                        changeLanguage(to: "fr")
                    },
                    .cancel()
                ]
            )
        }
        .alert("language_restart_message".localized, isPresented: $showingRestartAlert) {
            Button("OK", role: .cancel) { }
        }
    }
    
    private var currentLanguageDisplay: String {
        switch localizationManager.currentLanguage {
        case "fr":
            return "Français"
        default:
            return "English"
        }
    }
    
    private func changeLanguage(to languageCode: String) {
        localizationManager.updateLocale(Locale(identifier: languageCode))
        
        // Save the selected language preference
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Post notification for app-wide language change
        NotificationCenter.default.post(name: Notification.Name("LanguageChanged"), object: nil)
        
        // Show restart alert
        showingRestartAlert = true
    }
}

/// A mini version of the language switcher for navigation bars
struct MiniLanguageSwitcher: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var showingLanguageOptions = false
    @State private var showingRestartAlert = false
    
    var body: some View {
        Button(action: {
            showingLanguageOptions = true
        }) {
            Image(systemName: "globe")
        }
        .actionSheet(isPresented: $showingLanguageOptions) {
            ActionSheet(
                title: Text("select_language".localized),
                buttons: [
                    .default(Text("English")) {
                        changeLanguage(to: "en")
                    },
                    .default(Text("Français")) {
                        changeLanguage(to: "fr")
                    },
                    .cancel()
                ]
            )
        }
        .alert("language_restart_message".localized, isPresented: $showingRestartAlert) {
            Button("OK", role: .cancel) { }
        }
    }
    
    private func changeLanguage(to languageCode: String) {
        localizationManager.updateLocale(Locale(identifier: languageCode))
        
        // Save the selected language preference
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Post notification for app-wide language change
        NotificationCenter.default.post(name: Notification.Name("LanguageChanged"), object: nil)
        
        // Show restart alert
        showingRestartAlert = true
    }
}

// Preview
struct LanguageSwitcher_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            LanguageSwitcher()
            MiniLanguageSwitcher()
        }
        .padding()
        .environmentObject(LocalizationManager.shared)
    }
} 