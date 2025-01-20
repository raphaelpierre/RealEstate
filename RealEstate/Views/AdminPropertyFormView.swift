//
//  AdminPropertyFormView.swift
//  RealEstate
//
//  Created by Raphael PIERRE on 15.01.2025.
//

import SwiftUI
import PhotosUI

struct AdminPropertyFormView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @Environment(\.dismiss) private var dismiss
    
    let property: Property?
    
    // UI State
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var isUploadingImages = false
    @State private var currentStep = 0
    @State private var showImagePicker = false
    @State private var price: Double
    @State private var bedrooms: Int
    @State private var bathrooms: Int
    @State private var area: Double
    @State private var title: String
    @State private var description: String
    @State private var address: String
    @State private var city: String
    @State private var zipCode: String
    @State private var country: String
    @State private var selectedImages: [PhotosPickerItem] = []
    @State private var imageURLs: [String]
    @State private var newImageData: [Data] = []
    
    private let maxImages = 10
    private let steps = ["Basic Info", "Location", "Details", "Photos"]
    
    init(property: Property?) {
        self.property = property
        
        // Initialize state variables with existing property data if available
        _isLoading = State(initialValue: property != nil)
        _title = State(initialValue: property?.title ?? "")
        _description = State(initialValue: property?.description ?? "")
        _price = State(initialValue: property?.price ?? 0.0)
        _bedrooms = State(initialValue: property?.bedrooms ?? 0)
        _bathrooms = State(initialValue: property?.bathrooms ?? 0)
        _area = State(initialValue: property?.area ?? 0.0)
        _address = State(initialValue: property?.address ?? "")
        _city = State(initialValue: property?.city ?? "")
        _zipCode = State(initialValue: property?.zipCode ?? "")
        _country = State(initialValue: property?.country ?? "")
        _imageURLs = State(initialValue: property?.imageURLs ?? [])
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundBlack
                .ignoresSafeArea()
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Theme.primaryRed))
                    .scaleEffect(1.5)
            } else {
                VStack(spacing: 0) {
                    // Progress Steps
                    HStack(spacing: 0) {
                        ForEach(0..<steps.count, id: \.self) { index in
                            VStack(spacing: 4) {
                                Circle()
                                    .fill(currentStep >= index ? Theme.primaryRed : Theme.cardBackground)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Text("\(index + 1)")
                                            .foregroundColor(currentStep >= index ? .white : Theme.textWhite.opacity(0.5))
                                    )
                                
                                Text(steps[index])
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(currentStep >= index ? Theme.textWhite : Theme.textWhite.opacity(0.5))
                            }
                            
                            if index < steps.count - 1 {
                                Rectangle()
                                    .fill(currentStep > index ? Theme.primaryRed : Theme.cardBackground)
                                    .frame(height: 2)
                                    .padding(.horizontal, 8)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    
                    // Form Content
                    TabView(selection: $currentStep) {
                        // Basic Info
                        ScrollView {
                            VStack(spacing: 24) {
                                TextFormField(
                                    label: "Title",
                                    placeholder: "Enter property title",
                                    text: $title,
                                    icon: "house.fill"
                                )
                                
                                TextFormField(
                                    label: "Description",
                                    placeholder: "Enter property description",
                                    text: $description,
                                    icon: "doc.text.fill"
                                )
                                
                                NumericFormField(
                                    "Price",
                                    value: $price,
                                    icon: "dollarsign.circle.fill",
                                    isCurrency: true
                                )
                            }
                            .padding()
                        }
                        .tag(0)
                        
                        // Location
                        ScrollView {
                            VStack(spacing: 24) {
                                TextFormField(
                                    label: "Address",
                                    placeholder: "Enter address",
                                    text: $address,
                                    icon: "mappin.circle.fill"
                                )
                                
                                TextFormField(
                                    label: "City",
                                    placeholder: "Enter city",
                                    text: $city,
                                    icon: "building.2.fill"
                                )
                                
                                TextFormField(
                                    label: "ZIP Code",
                                    placeholder: "Enter ZIP code",
                                    text: $zipCode,
                                    icon: "number.circle.fill"
                                )
                                
                                TextFormField(
                                    label: "Country",
                                    placeholder: "Enter country",
                                    text: $country,
                                    icon: "globe.europe.africa.fill"
                                )
                            }
                            .padding()
                        }
                        .tag(1)
                        
                        // Details
                        ScrollView {
                            VStack(spacing: 24) {
                                NumericFormField(
                                    "Bedrooms",
                                    value: $bedrooms,
                                    icon: "bed.double.fill"
                                )
                                
                                NumericFormField(
                                    "Bathrooms",
                                    value: $bathrooms,
                                    icon: "shower.fill"
                                )
                                
                                NumericFormField(
                                    "Area (sq ft)",
                                    value: $area,
                                    icon: "square.fill"
                                )
                            }
                            .padding()
                        }
                        .tag(2)
                        
                        // Photos
                        ScrollView {
                            VStack(spacing: 24) {
                                // Image Counter
                                HStack {
                                    Image(systemName: "photo.stack.fill")
                                        .foregroundColor(Theme.textWhite)
                                    Text("\(imageURLs.count + newImageData.count)/\(maxImages) photos")
                                        .foregroundColor(Theme.textWhite)
                                    Spacer()
                                    PhotosPicker(
                                        selection: $selectedImages,
                                        maxSelectionCount: maxImages - (imageURLs.count + newImageData.count),
                                        matching: .images,
                                        photoLibrary: .shared()
                                    ) {
                                        Label("Add Photos", systemImage: "plus.circle.fill")
                                            .foregroundColor(Theme.primaryRed)
                                    }
                                    .disabled(imageURLs.count + newImageData.count >= maxImages)
                                }
                                
                                if isUploadingImages {
                                    ProgressView("Uploading images...")
                                        .tint(Theme.primaryRed)
                                        .foregroundColor(Theme.textWhite)
                                }
                                
                                // Image Grid
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 12) {
                                    // Show existing images
                                    ForEach(imageURLs, id: \.self) { imageURL in
                                        ZStack(alignment: .topTrailing) {
                                            AsyncImage(url: URL(string: imageURL)) { phase in
                                                switch phase {
                                                case .empty:
                                                    ProgressView()
                                                        .frame(height: 120)
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(height: 120)
                                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                                case .failure:
                                                    Image(systemName: "exclamationmark.triangle.fill")
                                                        .foregroundColor(.red)
                                                        .frame(height: 120)
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 120)
                                            
                                            Button {
                                                imageURLs.removeAll { $0 == imageURL }
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                                    .background(Circle().fill(.white))
                                                    .padding(4)
                                            }
                                        }
                                    }
                                    
                                    // Show newly selected images
                                    ForEach(newImageData.indices, id: \.self) { index in
                                        ZStack(alignment: .topTrailing) {
                                            if let uiImage = UIImage(data: newImageData[index]) {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(height: 120)
                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                                    .frame(maxWidth: .infinity)
                                            }
                                            
                                            Button {
                                                newImageData.remove(at: index)
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                                    .background(Circle().fill(.white))
                                                    .padding(4)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                        .tag(3)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    
                    // Navigation Buttons
                    HStack(spacing: 16) {
                        if currentStep > 0 {
                            Button {
                                withAnimation {
                                    currentStep -= 1
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "chevron.left")
                                    Text("Previous")
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                            }
                            .secondaryButton()
                        }
                        
                        if currentStep < steps.count - 1 {
                            Button {
                                withAnimation {
                                    currentStep += 1
                                }
                            } label: {
                                HStack {
                                    Text("Next")
                                    Image(systemName: "chevron.right")
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                            }
                            .primaryButton()
                        } else {
                            Button {
                                Task {
                                    await saveProperty()
                                }
                            } label: {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .tint(Theme.textWhite)
                                    } else {
                                        Text(property == nil ? "Add Property" : "Save Changes")
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                            }
                            .primaryButton()
                            .disabled(isLoading || true)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(property == nil ? "Add Property" : "Edit Property")
                    .font(Theme.Typography.heading)
                    .foregroundColor(Theme.textWhite)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    ProfileView()
                } label: {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(Theme.textWhite)
                        .font(.system(size: 24))
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(Theme.textWhite)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .task {
            await loadPropertyData()
        }
        .onChange(of: selectedImages) { items in
            Task {
                isUploadingImages = true
                
                do {
                    var newData: [Data] = []
                    for item in items {
                        if let data = try await item.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data),
                           let compressedData = uiImage.jpegData(compressionQuality: 0.7) {
                            newData.append(compressedData)
                        }
                    }
                    await MainActor.run {
                        newImageData = newData
                        selectedImages.removeAll()
                    }
                } catch {
                    await MainActor.run {
                        showError = true
                        errorMessage = "Failed to load images: \(error.localizedDescription)"
                    }
                }
                
                await MainActor.run {
                    isUploadingImages = false
                }
            }
        }
    }
    
    private func loadPropertyData() async {
        guard let property = property else { return }
        
        do {
            let updatedProperty = try await firebaseManager.getProperty(id: property.id)
            
            await MainActor.run {
                title = updatedProperty.title
                description = updatedProperty.description
                price = updatedProperty.price
                bedrooms = updatedProperty.bedrooms
                bathrooms = updatedProperty.bathrooms
                area = updatedProperty.area
                address = updatedProperty.address
                city = updatedProperty.city
                zipCode = updatedProperty.zipCode
                country = updatedProperty.country
                imageURLs = updatedProperty.imageURLs
                isLoading = false
            }
        } catch {
            await MainActor.run {
                showError = true
                errorMessage = "Failed to load property data: \(error.localizedDescription)"
                isLoading = false
                dismiss()
            }
        }
    }
    
    private func saveProperty() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // First upload any new images
            isUploadingImages = true
            var updatedImageURLs = imageURLs
            
            for imageData in newImageData {
                do {
                    let imageURL = try await firebaseManager.uploadImage(imageData)
                    updatedImageURLs.append(imageURL)
                } catch {
                    print("Failed to upload image: \(error)")
                    throw error
                }
            }
            
            isUploadingImages = false
            
            let updatedProperty = Property(
                id: property?.id ?? UUID().uuidString,
                title: title,
                price: price,
                description: description,
                address: address,
                zipCode: zipCode,
                city: city,
                country: country,
                bedrooms: bedrooms,
                bathrooms: bathrooms,
                area: area,
                imageURLs: updatedImageURLs,
                createdAt: property?.createdAt ?? Date(),
                updatedAt: Date()
            )
            
            if property != nil {
                try await firebaseManager.updateProperty(updatedProperty)
            } else {
                try await firebaseManager.addProperty(updatedProperty)
            }
            
            dismiss()
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Preview
struct AdminPropertyFormView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AdminPropertyFormView(property: Property.example)
                .environmentObject(FirebaseManager.shared)
        }
    }
}
