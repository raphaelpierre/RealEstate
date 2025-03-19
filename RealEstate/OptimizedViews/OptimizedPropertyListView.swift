import SwiftUI

class PropertyListViewModel: ObservableObject {
    @Published private(set) var visibleProperties: [Property] = []
    private var allProperties: [Property] = []
    private var currentPage = 0
    private let pageSize = 20
    private var isLoading = false
    
    func loadMoreContent() {
        guard !isLoading else { return }
        isLoading = true
        
        let startIndex = currentPage * pageSize
        let endIndex = min(startIndex + pageSize, allProperties.count)
        
        guard startIndex < allProperties.count else {
            isLoading = false
            return
        }
        
        let newProperties = Array(allProperties[startIndex..<endIndex])
        DispatchQueue.main.async {
            self.visibleProperties.append(contentsOf: newProperties)
            self.currentPage += 1
            self.isLoading = false
        }
        
        // Prefetch next page
        prefetchNextPage()
    }
    
    private func prefetchNextPage() {
        let nextPageStart = (currentPage + 1) * pageSize
        let nextPageEnd = min(nextPageStart + pageSize, allProperties.count)
        
        guard nextPageStart < allProperties.count else { return }
        
        let propertiesToPrefetch = Array(allProperties[nextPageStart..<nextPageEnd])
        prefetchImages(for: propertiesToPrefetch)
    }
    
    private func prefetchImages(for properties: [Property]) {
        for property in properties {
            guard let firstImageURL = property.imageURLs.first,
                  let url = URL(string: firstImageURL) else { continue }
            
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data,
                   let image = UIImage(data: data) {
                    ImageCacheManager.shared.setImage(image, forKey: firstImageURL)
                }
            }.resume()
        }
    }
    
    func refreshContent() async {
        // Implement your refresh logic here
        // For example, fetching new data from Firebase
    }
    
    func updateProperties(_ properties: [Property]) {
        allProperties = properties
        currentPage = 0
        visibleProperties = []
        loadMoreContent()
    }
}

struct OptimizedPropertyListView: View {
    @StateObject private var viewModel: PropertyListViewModel
    @EnvironmentObject private var currencyManager: CurrencyManager
    
    private let columns = [
        GridItem(.adaptive(minimum: 300), spacing: 16)
    ]
    
    init(viewModel: PropertyListViewModel = PropertyListViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.visibleProperties) { property in
                    NavigationLink(destination: PropertyDetailView(property: property)) {
                        PropertyCard(property: property)
                            .onAppear {
                                if property.id == viewModel.visibleProperties.last?.id {
                                    viewModel.loadMoreContent()
                                }
                            }
                    }
                }
            }
            .padding()
        }
        .refreshable {
            await viewModel.refreshContent()
        }
    }
} 