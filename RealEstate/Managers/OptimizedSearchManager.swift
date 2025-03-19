import Foundation

struct PropertyFilters {
    let priceRange: ClosedRange<Double>?
    let propertyType: PropertyType?
    let minBedrooms: Int?
    let minBathrooms: Int?
    let minArea: Double?
    
    func matches(_ property: Property) -> Bool {
        if let priceRange = priceRange,
           !priceRange.contains(property.price) {
            return false
        }
        
        if let propertyType = propertyType,
           property.type != propertyType.rawValue {
            return false
        }
        
        if let minBedrooms = minBedrooms,
           property.bedrooms < minBedrooms {
            return false
        }
        
        if let minBathrooms = minBathrooms,
           property.bathrooms < minBathrooms {
            return false
        }
        
        if let minArea = minArea,
           property.area < minArea {
            return false
        }
        
        return true
    }
}

class OptimizedSearchManager {
    private var searchIndex: [String: Set<String>] = [:] // Term -> Property IDs
    private var properties: [String: Property] = [:] // Property ID -> Property
    
    // Build search index
    func buildSearchIndex(for properties: [Property]) {
        var newIndex: [String: Set<String>] = [:]
        var newProperties: [String: Property] = [:]
        
        for property in properties {
            newProperties[property.id] = property
            
            // Index searchable fields
            let searchableText = [
                property.title,
                property.description,
                property.address,
                property.city,
                property.type,
                String(property.price)
            ].joined(separator: " ").lowercased()
            
            let terms = searchableText.split(separator: " ")
            for term in terms {
                newIndex[String(term), default: []].insert(property.id)
            }
        }
        
        searchIndex = newIndex
        self.properties = newProperties
    }
    
    // Perform optimized search
    func search(query: String, filters: PropertyFilters) -> [Property] {
        let searchTerms = query.lowercased().split(separator: " ")
        
        // Find matching property IDs from index
        var matchingIds: Set<String>? = nil
        
        for term in searchTerms {
            if let termMatches = searchIndex[String(term)] {
                if matchingIds == nil {
                    matchingIds = termMatches
                } else {
                    matchingIds?.formIntersection(termMatches)
                }
            }
        }
        
        guard let propertyIds = matchingIds else { return [] }
        
        // Apply filters
        return propertyIds.compactMap { properties[$0] }
            .filter { property in
                filters.matches(property)
            }
    }
    
    // Clear search index
    func clearIndex() {
        searchIndex.removeAll()
        properties.removeAll()
    }
    
    // Update single property in index
    func updateProperty(_ property: Property) {
        // Remove old property from index
        if let oldProperty = properties[property.id] {
            removeFromIndex(oldProperty)
        }
        
        // Add new property to index
        properties[property.id] = property
        addToIndex(property)
    }
    
    private func removeFromIndex(_ property: Property) {
        let searchableText = [
            property.title,
            property.description,
            property.address,
            property.city,
            property.type,
            String(property.price)
        ].joined(separator: " ").lowercased()
        
        let terms = searchableText.split(separator: " ")
        for term in terms {
            searchIndex[String(term)]?.remove(property.id)
        }
    }
    
    private func addToIndex(_ property: Property) {
        let searchableText = [
            property.title,
            property.description,
            property.address,
            property.city,
            property.type,
            String(property.price)
        ].joined(separator: " ").lowercased()
        
        let terms = searchableText.split(separator: " ")
        for term in terms {
            searchIndex[String(term), default: []].insert(property.id)
        }
    }
} 