import SwiftUI

struct ServicesView: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        ZStack {
            Theme.backgroundBlack
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    Text("our_services".localized)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Theme.textWhite)
                        .padding(.top)
                    
                    // Services List
                    ForEach(services, id: \.id) { service in
                        ServiceCard(service: service)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .id(localizationManager.refreshToggle)
    }
    
    private var services: [Service] {
        [
            Service(
                id: "1",
                title: "property_valuation".localized,
                description: "property_valuation_desc".localized,
                icon: "house.circle"
            ),
            Service(
                id: "2",
                title: "property_management".localized,
                description: "property_management_desc".localized,
                icon: "building.2"
            ),
            Service(
                id: "3",
                title: "legal_assistance".localized,
                description: "legal_assistance_desc".localized,
                icon: "doc.text"
            ),
            Service(
                id: "4",
                title: "mortgage_consulting".localized,
                description: "mortgage_consulting_desc".localized,
                icon: "banknote"
            ),
            Service(
                id: "5",
                title: "renovation_services".localized,
                description: "renovation_services_desc".localized,
                icon: "hammer"
            ),
            Service(
                id: "6",
                title: "real_estate_news".localized,
                description: "real_estate_news_desc".localized,
                icon: "newspaper"
            )
        ]
    }
}

struct Service: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
}

struct ServiceCard: View {
    let service: Service
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: service.icon)
                    .font(.system(size: 24))
                    .foregroundColor(Theme.primaryRed)
                
                Text(service.title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Theme.textWhite)
            }
            
            Text(service.description)
                .font(.system(size: 16))
                .foregroundColor(Theme.textWhite.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
            
            Button(action: {
                // Contact action would go here
            }) {
                Text("contact_us".localized)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Theme.textWhite)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Theme.primaryRed)
                    .cornerRadius(8)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    ServicesView()
        .environmentObject(LocalizationManager.shared)
} 