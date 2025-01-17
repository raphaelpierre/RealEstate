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
                    
                    // Show selected images
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(0..<selectedImageData.count, id: \.self) { index in
                                if let uiImage = UIImage(data: selectedImageData[index]) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(
                                            Button(action: {
                                                selectedImageData.remove(at: index)
                                                selectedItems.remove(at: index)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.white)
                                                    .background(Color.black)
                                                    .clipShape(Circle())
                                            }
                                            .padding(4),
                                            alignment: .topTrailing
                                        )
                                }
                            }
                        }
                        .padding(.vertical)
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
                Task {
                    selectedImageData.removeAll()
                    for item in selectedItems {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            selectedImageData.append(data)
                        }
                    }
                }
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
    
    private func saveProperty() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Upload images first
            var imageURLs: [String] = []
            for imageData in selectedImageData {
                let url = try await firebaseManager.uploadImage(imageData)
                imageURLs.append(url)
            }
            
            // Create or update property
            let newProperty = Property(
                id: property?.id ?? UUID().uuidString,
                title: title,
                price: Double(price) ?? 0,
                description: description,
                address: address,
                bedrooms: Int(bedrooms) ?? 0,
                bathrooms: Int(bathrooms) ?? 0,
                area: Double(area) ?? 0,
                imageURLs: imageURLs
            )
            
            if isEditing {
                try await firebaseManager.updateProperty(newProperty)
            } else {
                try await firebaseManager.addProperty(newProperty)
            }
            
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    AdminPropertyFormView()
        .environmentObject(FirebaseManager.shared)
}
