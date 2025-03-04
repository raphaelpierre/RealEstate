import SwiftUI

/// A demo view to showcase localization features
struct LocalizationDemoView: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Language switcher
                LanguageSwitcher()
                    .padding(.top, 20)
                
                // App title
                Text("app_name".localized)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textWhite)
                
                // Localized content examples
                GroupBox(label: Text("examples".localized)) {
                    VStack(alignment: .leading, spacing: 16) {
                        // Text example
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Text Example:")
                                .font(.headline)
                                .foregroundColor(Theme.textWhite)
                            Text("property_details".localized)
                                .foregroundColor(Theme.textWhite)
                        }
                        
                        Divider()
                            .background(Theme.textWhite)
                        
                        // Currency example
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Currency Example:")
                                .font(.headline)
                                .foregroundColor(Theme.textWhite)
                            Text(LocalizationManager.shared.formatCurrency(1250000))
                                .foregroundColor(Theme.textWhite)
                        }
                        
                        Divider()
                            .background(Theme.textWhite)
                        
                        // Area example
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Area Example:")
                                .font(.headline)
                                .foregroundColor(Theme.textWhite)
                            Text(LocalizationManager.shared.formatArea(150))
                                .foregroundColor(Theme.textWhite)
                        }
                        
                        Divider()
                            .background(Theme.textWhite)
                        
                        // Date example
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Date Example:")
                                .font(.headline)
                                .foregroundColor(Theme.textWhite)
                            Text(LocalizationManager.shared.formatDate(Date()))
                                .foregroundColor(Theme.textWhite)
                        }
                    }
                    .padding()
                }
                .padding(.horizontal)
                .background(Theme.backgroundBlack)
                .foregroundColor(Theme.textWhite)
                
                // Navigation to property detail
                NavigationLink(destination: LocalizedPropertyDetailView(property: Property.example)
                    .environmentObject(localizationManager)) {
                    Text("view_property_details".localized)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.primaryRed)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Current language info
                Text("Current language: \(localizationManager.currentLanguage)")
                    .font(.caption)
                    .foregroundColor(Theme.textWhite)
                    .padding(.bottom)
            }
            .padding()
            .background(Theme.backgroundBlack)
        }
        .navigationTitle("localization_demo".localized)
        .navigationBarTitleDisplayMode(.inline)
        .background(Theme.backgroundBlack)
        // This is important to force the view to refresh when the language changes
        .id(localizationManager.refreshToggle)
    }
}

// Preview
struct LocalizationDemoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LocalizationDemoView()
                .environmentObject(LocalizationManager.shared)
        }
    }
} 