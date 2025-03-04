import SwiftUI

/// A simple demo app to showcase the language switching functionality
struct LocalizationDemoApp: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Language switcher
                LanguageSwitcher()
                    .padding(.top, 20)
                
                // App title
                Text("app_name".localized)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Localized content examples
                GroupBox(label: Text("examples".localized)) {
                    VStack(alignment: .leading, spacing: 16) {
                        // Text example
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Text Example:")
                                .font(.headline)
                            Text("property_details".localized)
                        }
                        
                        Divider()
                        
                        // Currency example
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Currency Example:")
                                .font(.headline)
                            Text(LocalizationManager.shared.formatCurrency(1250000))
                        }
                        
                        Divider()
                        
                        // Area example
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Area Example:")
                                .font(.headline)
                            Text(LocalizationManager.shared.formatArea(150))
                        }
                        
                        Divider()
                        
                        // Date example
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Date Example:")
                                .font(.headline)
                            Text(LocalizationManager.shared.formatDate(Date()))
                        }
                    }
                    .padding()
                }
                .padding(.horizontal)
                
                // Navigation to property detail
                NavigationLink(destination: LocalizedPropertyDetailView(property: Property.example)
                    .environmentObject(localizationManager)) {
                    Text("view_property_details".localized)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Current language info
                Text("Current language: \(localizationManager.currentLanguage)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
            }
            .navigationTitle("localization_demo".localized)
            .navigationBarItems(trailing: MiniLanguageSwitcher())
            // This is important to force the view to refresh when the language changes
            .id(localizationManager.refreshToggle)
        }
    }
}

// Preview
struct LocalizationDemoApp_Previews: PreviewProvider {
    static var previews: some View {
        LocalePreview {
            LocalizationDemoApp()
                .environmentObject(LocalizationManager.shared)
        }
    }
} 