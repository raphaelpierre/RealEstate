import SwiftUI
import FirebaseFirestore
import MapKit

struct PropertyListView: View {
    @StateObject private var viewModel = PropertyListViewModel()
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var currencyManager: CurrencyManager
    @State private var selectedViewMode: ViewMode
    
    // New initializer to support setting initial view mode
    init(initialViewMode: ViewMode = .list) {
        _selectedViewMode = State(initialValue: initialViewMode)
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundBlack
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                Text("properties".localized)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Theme.textWhite)
                    .padding(.top)
                
                // Segmented control for view mode
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: selectedViewMode == .list ? "list.bullet" : "map")
                            .font(.system(size: 24))
                            .foregroundColor(Theme.primaryRed)
                        
                        Text("display_mode".localized)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Theme.textWhite)
                    }
                    
                    Picker("View Mode", selection: $selectedViewMode) {
                        Text("list".localized).tag(ViewMode.list)
                        Text("map".localized).tag(ViewMode.map)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding()
                .background(Theme.cardBackground)
                .cornerRadius(12)
                .padding(.horizontal)
                .id(localizationManager.refreshToggle)
                
                // Conditional view based on selected mode
                if selectedViewMode == .list {
                    OptimizedPropertyListView(viewModel: viewModel)
                } else {
                    PropertyMapView(properties: firebaseManager.properties)
                        .environmentObject(localizationManager)
                        .environmentObject(currencyManager)
                }
            }
        }
        .onChange(of: firebaseManager.properties) { oldProperties, newProperties in
            viewModel.updateProperties(newProperties)
        }
    }
    
    // Existing enums remain the same
    enum ViewMode {
        case list
        case map
    }
}

#Preview {
    PropertyListView()
        .environmentObject(FirebaseManager.shared)
        .environmentObject(LocalizationManager.shared)
        .environmentObject(CurrencyManager.shared)
}