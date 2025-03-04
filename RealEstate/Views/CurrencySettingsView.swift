import SwiftUI

struct CurrencySettingsView: View {
    @EnvironmentObject private var currencyManager: CurrencyManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isUpdating = false
    
    private let currencies: [(currency: Currency, name: String)] = [
        (.usd, "US Dollar"),
        (.eur, "Euro"),
        (.cfa, "CFA Franc")
    ]
    
    var body: some View {
        ZStack {
            Theme.backgroundBlack
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.padding) {
                    // Header
                    Text("currency_settings".localized)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Theme.textWhite)
                        .padding(.top)
                    
                    // Description
                    Text("currency_settings_description".localized)
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.textWhite.opacity(0.7))
                        .padding(.bottom, Theme.padding)
                    
                    // Currency List
                    VStack(spacing: Theme.smallPadding) {
                        ForEach(currencies, id: \.currency) { currency in
                            Button {
                                updateCurrency(to: currency.currency)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(currency.name)
                                            .font(Theme.Typography.body)
                                            .foregroundColor(Theme.textWhite)
                                        
                                        Text(currency.currency.rawValue.uppercased())
                                            .font(Theme.Typography.caption)
                                            .foregroundColor(Theme.textWhite.opacity(0.7))
                                    }
                                    
                                    Spacer()
                                    
                                    if currencyManager.selectedCurrency == currency.currency {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Theme.primaryRed)
                                    }
                                }
                                .padding()
                                .background(Theme.cardBackground)
                                .cornerRadius(Theme.cornerRadius)
                            }
                            .disabled(isUpdating)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("currency_update_error".localized, isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func updateCurrency(to currency: Currency) {
        isUpdating = true
        
        // Update the currency
        currencyManager.changeCurrency(to: currency)
        
        // Dismiss the view after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
        
        isUpdating = false
    }
}

#Preview {
    NavigationView {
        CurrencySettingsView()
            .environmentObject(CurrencyManager.preview())
    }
} 