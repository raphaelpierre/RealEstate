//
//  AdminPropertyFormView.swift
//  RealEstate
//
//  Created by Raphael PIERRE on 15.01.2025.
//

import SwiftUI
import PhotosUI
import CoreLocation

struct AdminPropertyFormView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @Environment(\.dismiss) private var dismiss
    
    let property: Property?
    
    // UI State
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var isProcessingImages = false
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
    @State private var selectedType: PropertyType
    @State private var selectedPurpose: PropertyPurpose
    @State private var selectedImages: [PhotosPickerItem] = []
    @State private var imageURLs: [String]
    @State private var newImageData: [Data] = []
    @State private var contactWhatsapp: String = ""
    
    private let maxImages = 10
    private let steps = ["Basic Info", "Location", "Details", "Photos", "Contact"]
    
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        price > 0 &&
        bedrooms > 0 &&
        bathrooms > 0 &&
        area > 0 &&
        !selectedType.rawValue.isEmpty &&
        !selectedPurpose.rawValue.isEmpty
    }
    
    init(property: Property?) {
        self.property = property
        
        // Initialize state variables with existing property data if available
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
        _selectedType = State(initialValue: PropertyType(rawValue: property?.type ?? "") ?? .house)
        _selectedPurpose = State(initialValue: PropertyPurpose(rawValue: property?.purpose ?? "") ?? .buy)
        _imageURLs = State(initialValue: property?.imageURLs ?? [])
        _isLoading = State(initialValue: false)
        
        // Initialize contactWhatsapp from property's contact
        _contactWhatsapp = State(initialValue: property?.contact.whatsapp ?? "")
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
                                
                                // Property Type Picker
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "building.fill")
                                            .foregroundColor(Theme.textWhite)
                                        Text("Property Type")
                                            .foregroundColor(Theme.textWhite)
                                    }
                                    
                                    Picker("Property Type", selection: $selectedType) {
                                        ForEach(PropertyType.allCases.filter { $0 != .all }, id: \.self) { type in
                                            Text(type.rawValue)
                                                .tag(type)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                }
                                
                                // Property Purpose Picker
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "tag.fill")
                                            .foregroundColor(Theme.textWhite)
                                        Text("Purpose")
                                            .foregroundColor(Theme.textWhite)
                                    }
                                    
                                    Picker("Purpose", selection: $selectedPurpose) {
                                        ForEach(PropertyPurpose.allCases.filter { $0 != .all }, id: \.self) { purpose in
                                            Text(purpose.rawValue)
                                                .tag(purpose)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                }
                                
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
                                    if imageURLs.count + newImageData.count < maxImages {
                                        PhotosPicker(
                                            selection: $selectedImages,
                                            maxSelectionCount: maxImages - (imageURLs.count + newImageData.count),
                                            matching: .images
                                        ) {
                                            Label("Add Photos", systemImage: "plus.circle.fill")
                                                .foregroundColor(Theme.primaryRed)
                                        }
                                    }
                                }
                                
                                if isProcessingImages {
                                    ProgressView("Processing images...")
                                        .tint(Theme.primaryRed)
                                }
                                
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
                                                        .tint(Theme.primaryRed)
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                case .failure:
                                                    Image(systemName: "photo.fill")
                                                        .foregroundColor(Theme.textWhite)
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                            .frame(height: 120)
                                            .frame(maxWidth: .infinity)
                                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                                            
                                            Button {
                                                imageURLs.removeAll { $0 == imageURL }
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                                    .background(Circle().fill(Color.white))
                                            }
                                            .padding(4)
                                        }
                                    }
                                    
                                    // Show new images
                                    ForEach(newImageData.indices, id: \.self) { index in
                                        if let uiImage = UIImage(data: newImageData[index]) {
                                            ZStack(alignment: .topTrailing) {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(height: 120)
                                                    .frame(maxWidth: .infinity)
                                                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                                                
                                                Button {
                                                    newImageData.remove(at: index)
                                                } label: {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.red)
                                                        .background(Circle().fill(Color.white))
                                                }
                                                .padding(4)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                        .tag(3)
                        
                        // Contact
                        ScrollView {
                            VStack(spacing: 24) {
                                whatsAppContactField()
                            }
                            .padding()
                        }
                        .tag(4)
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
                                    await savePropertyToFirebase()
                                }
                            } label: {
                                Text("Save Property")
                                    .foregroundColor(Theme.textWhite)
                            }
                            .primaryButton()
                            .disabled(false)
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
        .onChange(of: selectedImages) { oldValue, newValue in
            Task {
                isProcessingImages = true
                
                do {
                    var newData: [Data] = []
                    for item in newValue {
                        if let data = try await item.loadTransferable(type: Data.self) {
                            // Resize and compress image
                            if let uiImage = UIImage(data: data) {
                                let maxDimension: CGFloat = 1200 // Maximum dimension for either width or height
                                let scale = min(maxDimension / uiImage.size.width, maxDimension / uiImage.size.height, 1.0)
                                let newSize = CGSize(width: uiImage.size.width * scale, height: uiImage.size.height * scale)
                                
                                let renderer = UIGraphicsImageRenderer(size: newSize)
                                let resizedImage = renderer.image { context in
                                    uiImage.draw(in: CGRect(origin: .zero, size: newSize))
                                }
                                
                                if let compressedData = resizedImage.jpegData(compressionQuality: 0.7) {
                                    newData.append(compressedData)
                                }
                            }
                        }
                    }
                    
                    await MainActor.run {
                        newImageData.append(contentsOf: newData)
                        selectedImages.removeAll()
                        isProcessingImages = false
                    }
                } catch {
                    print("Error processing images: \(error)")
                    await MainActor.run {
                        showError = true
                        errorMessage = "Failed to process images: \(error.localizedDescription)"
                        isProcessingImages = false
                    }
                }
            }
        }
    }
    
    private func whatsAppContactField() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("WhatsApp")
                .font(.caption)
                .foregroundColor(Theme.textWhite.opacity(0.7))
            
            HStack {
                // WhatsApp-specific icon with brand color
                Image("whatsapp_icon") // Assumes you'll add a WhatsApp icon to Assets
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color(red: 37/255, green: 211/255, blue: 102/255)) // WhatsApp green
                
                TextField("", text: $contactWhatsapp)
                    .keyboardType(.phonePad)
                    .foregroundColor(Theme.textWhite)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .placeholder(when: contactWhatsapp.isEmpty) {
                        Text("e.g. +1234567890")
                            .foregroundColor(Theme.textWhite.opacity(0.5))
                    }
            }
            .padding(12)
            .background(Theme.cardBackground)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(contactWhatsapp.isEmpty ? Color.clear : 
                            (ContactInfo(whatsapp: contactWhatsapp).isValidWhatsApp() ? 
                             Color.green : Color.red), 
                     lineWidth: 2)
            )
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
                address = updatedProperty.address
                zipCode = updatedProperty.zipCode
                city = updatedProperty.city
                country = updatedProperty.country
                bedrooms = updatedProperty.bedrooms
                bathrooms = updatedProperty.bathrooms
                area = updatedProperty.area
                selectedType = PropertyType(rawValue: updatedProperty.type) ?? .house
                selectedPurpose = PropertyPurpose(rawValue: updatedProperty.purpose) ?? .buy
                imageURLs = updatedProperty.imageURLs
                contactWhatsapp = updatedProperty.contact.whatsapp
                isLoading = false
            }
        } catch {
            await MainActor.run {
                print("Error loading property data: \(error)")
                isLoading = false
            }
        }
    }
    
    private func savePropertyToFirebase() async {
        // Validate input fields
        guard validateFields() else { return }
        
        // Create property object
        let propertyToSave = Property(
            id: property?.id ?? UUID().uuidString,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            price: price,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            address: address.trimmingCharacters(in: .whitespacesAndNewlines),
            contact: ContactInfo(
                whatsapp: contactWhatsapp.trimmingCharacters(in: .whitespacesAndNewlines)
            ),
            zipCode: zipCode.trimmingCharacters(in: .whitespacesAndNewlines),
            city: city.trimmingCharacters(in: .whitespacesAndNewlines),
            country: country.trimmingCharacters(in: .whitespacesAndNewlines),
            bedrooms: bedrooms,
            bathrooms: bathrooms,
            area: area,
            type: selectedType.rawValue,
            purpose: selectedPurpose.rawValue,
            imageURLs: imageURLs,
            createdAt: property?.createdAt ?? Date(),
            updatedAt: Date(),
            // Optional: If you want to preserve existing coordinates
            latitude: property?.latitude ?? 0.0,
            longitude: property?.longitude ?? 0.0
        )
        
        do {
            isLoading = true
            
            // Use the new saveProperty method which includes geocoding
            _ = try await firebaseManager.saveProperty(propertyToSave)
            
            // Optional: show success message or navigate away
            await MainActor.run {
                isLoading = false
                dismiss()
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func validateFields() -> Bool {
        // Implement your validation logic here
        return true
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

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder then: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            then().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
