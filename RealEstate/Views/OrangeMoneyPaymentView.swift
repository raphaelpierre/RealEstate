import SwiftUI

struct OrangeMoneyPaymentView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var currencyManager: CurrencyManager
    @StateObject private var orangeMoneyService = OrangeMoneyService()
    
    let property: Property
    let amount: Double
    
    @State private var phoneNumber = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @State private var currentTransaction: OrangeMoneyTransaction?
    @State private var paymentStep: PaymentStep = .enterPhone
    
    enum PaymentStep {
        case enterPhone
        case confirmation
        case processing
        case completed
        case failed
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundBlack.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // En-tête avec logo et montant
                        paymentHeader
                        
                        // Contenu principal basé sur l'étape
                        switch paymentStep {
                        case .enterPhone:
                            phoneNumberInput
                        case .confirmation:
                            confirmationView
                        case .processing:
                            processingView
                        case .completed:
                            completedView
                        case .failed:
                            failedView
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if paymentStep != .processing {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(Theme.textWhite)
                        }
                    }
                }
            }
            .alert("error".localized, isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .alert("success".localized, isPresented: $showSuccess) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("payment_success".localized)
            }
        }
    }
    
    private var paymentHeader: some View {
        VStack(spacing: 16) {
            Image("Orange-Money-Icon-Logo-Vector.svg-")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 60)
            
            Text(currencyManager.formatPrice(amount))
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Theme.primaryRed)
        }
    }
    
    private var phoneNumberInput: some View {
        VStack(spacing: 16) {
            Text("enter_phone_number".localized)
                .font(.headline)
                .foregroundColor(Theme.textWhite)
            
            TextField("phone_number_placeholder".localized, text: $phoneNumber)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
                .padding()
                .background(Theme.cardBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Theme.primaryRed.opacity(0.3), lineWidth: 1)
                )
            
            Button {
                validateAndProceed()
            } label: {
                Text("continue".localized)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.primaryRed)
                    .cornerRadius(12)
                    .foregroundColor(.white)
            }
            .disabled(phoneNumber.isEmpty)
        }
    }
    
    private func validateAndProceed() {
        guard orangeMoneyService.validatePhoneNumber(phoneNumber) else {
            errorMessage = "invalid_phone_number".localized
            showError = true
            return
        }
        
        withAnimation {
            paymentStep = .confirmation
        }
    }
    
    private func processPayment() {
        Task {
            do {
                paymentStep = .processing
                let transaction = try await orangeMoneyService.initiatePayment(
                    amount: amount,
                    phoneNumber: phoneNumber,
                    propertyId: property.id
                )
                currentTransaction = transaction
                
                // Vérifier le statut après quelques secondes
                try await Task.sleep(nanoseconds: 3 * 1_000_000_000)
                let status = try await orangeMoneyService.checkTransactionStatus(
                    transactionId: transaction.id
                )
                
                await MainActor.run {
                    withAnimation {
                        paymentStep = status == .completed ? .completed : .failed
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    withAnimation {
                        paymentStep = .failed
                    }
                }
            }
        }
    }
    
    private var confirmationView: some View {
        VStack(spacing: 16) {
            Text("confirm_payment".localized)
                .font(.headline)
                .foregroundColor(Theme.textWhite)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("property".localized + ": " + property.title)
                Text("phone_number".localized + ": " + phoneNumber)
                Text("amount".localized + ": " + currencyManager.formatPrice(amount))
            }
            .foregroundColor(Theme.textWhite)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Theme.cardBackground)
            .cornerRadius(12)
            
            Button {
                processPayment()
            } label: {
                Text("confirm_and_pay".localized)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.primaryRed)
                    .cornerRadius(12)
                    .foregroundColor(.white)
            }
        }
    }
    
    private var processingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Theme.primaryRed)
            
            Text("processing_payment".localized)
                .font(.headline)
                .foregroundColor(Theme.textWhite)
        }
    }
    
    private var completedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.green)
            
            Text("payment_successful".localized)
                .font(.headline)
                .foregroundColor(Theme.textWhite)
            
            Text("transaction_id".localized + ": " + (currentTransaction?.id ?? ""))
                .font(.subheadline)
                .foregroundColor(Theme.textGray)
            
            Button {
                dismiss()
            } label: {
                Text("done".localized)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.primaryRed)
                    .cornerRadius(12)
                    .foregroundColor(.white)
            }
        }
    }
    
    private var failedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(Theme.primaryRed)
            
            Text("payment_failed".localized)
                .font(.headline)
                .foregroundColor(Theme.textWhite)
            
            Text(errorMessage)
                .font(.subheadline)
                .foregroundColor(Theme.textGray)
                .multilineTextAlignment(.center)
            
            Button {
                withAnimation {
                    paymentStep = .enterPhone
                }
            } label: {
                Text("try_again".localized)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.primaryRed)
                    .cornerRadius(12)
                    .foregroundColor(.white)
            }
        }
    }
} 