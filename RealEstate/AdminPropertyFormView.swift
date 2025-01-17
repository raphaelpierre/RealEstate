//
//  AdminPropertyFormView.swift
//  RealEstate
//
//  Created by Raphael PIERRE on 15.01.2025.
//

import SwiftUI
import PhotosUI

struct AdminPropertyFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    // Property fields
    @State private var title = ""
    @State private var price = ""
    @State private var description = ""
    @State private var address = ""
    @State private var bedrooms = ""
    @State private var bathrooms = ""
    @State private var area = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImageData: [Data] = []
    
    var property: Property? // If set, we're editing an existing property
    
    private var isEditing: Bool {
        property != nil
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Title", text: $title)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                    TextField("Address", text: $address)
                }
                
                Section("Details") {
                    TextField("Bedrooms", text: $bedrooms)
                        .keyboardType(.numberPad)
                    TextField("Bathrooms", text: $bathrooms)
                        .keyboardType(.numberPad)
                    TextField("Area (m²)", text: $area)
                        .keyboardType(.decimalPad)
                }
                
                Section("Description") {
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
                
                Section("Images") {
                    PhotosPicker(selection: $selectedItems,
                               maxSelectionCount: 5,
                               matching: .images) {
                        Label("Select Images", systemImage: "photo.stack")
                    }
                    
                    if !selectedImageData.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 12) {
                                ForEach(0..<selectedImageData.count, id: \.self) { index in
                                    if let uiImage = UIImage(data: selectedImageData[index]) {
                                        imagePreview(uiImage, index: index)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .frame(height: 120) // Fixed height for scroll view
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Property" : "Add Property")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        Task {
                            await saveProperty()
                        }
                    }
                    .disabled(isLoading || title.isEmpty || price.isEmpty)
                }
            }
            .onChange(of: selectedItems) { _ in
                handleImageSelection()
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            if let property = property {
                // Populate form with existing property data
                title = property.title
                price = String(property.price)
                description = property.description
                address = property.address
                bedrooms = String(property.bedrooms)
                bathrooms = String(property.bathrooms)
                area = String(property.area)
            }
        }
    }
    
    private func imagePreview(_ image: UIImage, index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Button(action: {
                withAnimation {
                    selectedImageData.remove(at: index)
                    selectedItems.remove(at: index)
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.black.opacity(0.5)))
                    .padding(4)
            }
        }
    }
    
    @MainActor
    private func loadImage(from item: PhotosPickerItem) async throws -> Data {
        guard let data = try await item.loadTransferable(type: Data.self) else {
            throw NSError(domain: "ImageLoading", code: -1, 
                userInfo: [NSLocalizedDescriptionKey: "Could not load image data"])
        }
        
        // Validate and compress image data
        guard let uiImage = UIImage(data: data),
              let compressedData = uiImage.jpegData(compressionQuality: 0.7) else {
            throw NSError(domain: "ImageLoading", code: -2, 
                userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
        }
        
        return compressedData
    }
    
    private func handleImageSelection() {
        Task {
            do {
                selectedImageData.removeAll()
                
                for item in selectedItems {
                    do {
                        let imageData = try await loadImage(from: item)
                        selectedImageData.append(imageData)
                    } catch {
                        print("Error loading image: \(error)")
                    }
                }
            } catch {
                showError = true
                errorMessage = "Failed to load images: \(error.localizedDescription)"
            }
        }
    }
    
    private func saveProperty() async {
        isLoading = true
        defer { isLoading = false }
        
        // Validate numeric fields
        guard let priceValue = Double(price.replacingOccurrences(of: ",", with: ".")),
              let bedroomsValue = Int(bedrooms),
              let bathroomsValue = Int(bathrooms),
              let areaValue = Double(area.replacingOccurrences(of: ",", with: ".")) else {
            showError = true
            errorMessage = "Please enter valid numbers for price, bedrooms, bathrooms, and area"
            return
        }
        
        do {
            // Upload images first
            var imageURLs: [String] = []
            
            // If editing, keep existing images
            if let existingProperty = property {
                imageURLs = existingProperty.imageURLs
            }
            
            // Upload new images
            for (index, imageData) in selectedImageData.enumerated() {
                do {
                    let url = try await firebaseManager.uploadImage(imageData)
                    imageURLs.append(url)
                } catch {
                    print("Error uploading image \(index + 1): \(error)")
                    showError = true
                    errorMessage = "Failed to upload image \(index + 1). Please try again."
                    return
                }
            }
            
            // Create or update property with validated values
            let newProperty = Property(
                id: property?.id ?? UUID().uuidString,
                title: title,
                price: priceValue,
                description: description,
                address: address,
                bedrooms: bedroomsValue,
                bathrooms: bathroomsValue,
                area: areaValue,
                imageURLs: imageURLs
            )
            
            if isEditing {
                try await firebaseManager.updateProperty(newProperty)
            } else {
                try await firebaseManager.addProperty(newProperty)
            }
            
            dismiss()
        } catch {
            print("Error saving property: \(error)")
            showError = true
            errorMessage = "Failed to save property: \(error.localizedDescription)"
        }
    }
}

#Preview {
    AdminPropertyFormView()
        .environmentObject(FirebaseManager.shared)
}
