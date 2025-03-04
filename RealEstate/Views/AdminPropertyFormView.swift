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
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var currencyManager: CurrencyManager
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToProperty: Property?
    
    let property: Property?
    
    // UI State
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var isProcessingImages = false
    @State private var currentStep = 0
    @State private var showImagePicker = false
    @State private var showSuccessMessage = false
    @State private var successMessage = ""
    @State private var price: Double
    @State private var priceCurrency: Currency = .usd
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
    private var steps: [String] {
        ["basic_info".localized, "location".localized, "details".localized, "photos".localized, "contact".localized]
    }
    
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
        _priceCurrency = State(initialValue: .usd) // Default to USD
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
                    ProgressStepsView(steps: steps, currentStep: currentStep)
                    
                    MainContentView(
                        currentStep: $currentStep,
                        title: $title,
                        description: $description,
                        selectedType: $selectedType,
                        selectedPurpose: $selectedPurpose,
                        price: $price,
                        priceCurrency: $priceCurrency,
                        address: $address,
                        city: $city,
                        zipCode: $zipCode,
                        country: $country,
                        bedrooms: $bedrooms,
                        bathrooms: $bathrooms,
                        area: $area,
                        imageURLs: $imageURLs,
                        newImageData: $newImageData,
                        selectedImages: $selectedImages,
                        isProcessingImages: $isProcessingImages,
                        contactWhatsapp: $contactWhatsapp,
                        maxImages: maxImages
                    )
                    
                    NavigationButtonsView(
                        currentStep: currentStep,
                        totalSteps: steps.count,
                        onPrevious: {
                                withAnimation {
                                    currentStep -= 1
                            }
                        },
                        onNext: {
                                withAnimation {
                                    currentStep += 1
                            }
                        },
                        onSave: {
                                Task {
                                    await savePropertyToFirebase()
                            }
                        }
                    )
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(property == nil ? "add_property".localized : "edit_property".localized)
                    .font(Theme.Typography.heading)
                    .foregroundColor(Theme.textWhite)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    ProfileView()
                } label: {
                    if let user = authManager.currentUser, let photoURLString = user.photoURL, let photoURL = URL(string: photoURLString) {
                        AsyncImage(url: photoURL) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 24, height: 24)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 24, height: 24)
                                    .clipShape(Circle())
                            case .failure:
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(Theme.textWhite)
                                    .font(.system(size: 24))
                            @unknown default:
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(Theme.textWhite)
                                    .font(.system(size: 24))
                            }
                        }
                    } else {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(Theme.textWhite)
                        .font(.system(size: 24))
                    }
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
        .alert("error".localized, isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .alert("success".localized, isPresented: $showSuccessMessage) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        } message: {
            Text(successMessage)
        }
        .navigationDestination(item: $navigateToProperty) { property in
            PropertyDetailView(property: property)
                .environmentObject(localizationManager)
                .environmentObject(currencyManager)
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
                            if let uiImage = UIImage(data: data) {
                                let maxDimension: CGFloat = 1200
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
        
        // Convert price to USD before saving
        let priceInUSD = currencyManager.convert(price, from: priceCurrency)
        
        // Get current user ID
        guard let userId = authManager.currentUser?.id else {
            errorMessage = "User not authenticated"
            showError = true
            return
        }
        
        do {
            isLoading = true
            
            // Upload new images first
            var finalImageURLs = imageURLs // Start with existing image URLs
            for imageData in newImageData {
                do {
                    let imageURL = try await firebaseManager.uploadImage(imageData)
                    finalImageURLs.append(imageURL)
                } catch {
                    print("Failed to upload image: \(error.localizedDescription)")
                    throw error
                }
            }
            
            // Create property object with updated image URLs
        let propertyToSave = Property(
                id: property?.id ?? "",
                userId: userId,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                price: priceInUSD,
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
                imageURLs: finalImageURLs, // Use the updated image URLs
            createdAt: property?.createdAt ?? Date(),
            updatedAt: Date(),
            latitude: property?.latitude ?? 0.0,
            longitude: property?.longitude ?? 0.0
        )
        
            // Save the property and get the saved version
            let savedProperty = try await firebaseManager.saveProperty(propertyToSave)
            
            await MainActor.run {
                isLoading = false
                if property == nil {
                    // For new properties, show success message and navigate to detail view
                    successMessage = "property_saved_success".localized
                    showSuccessMessage = true
                    navigateToProperty = savedProperty
                } else {
                    // For existing properties, show success message and dismiss
                    successMessage = "property_updated_success".localized
                    showSuccessMessage = true
                }
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
                showError = true
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
                .environmentObject(LocalizationManager.shared)
                .environmentObject(CurrencyManager.shared)
                .environmentObject(AuthManager.shared)
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

// MARK: - Progress Steps View
private struct ProgressStepsView: View {
    let steps: [String]
    let currentStep: Int
    
    var body: some View {
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
    }
}

// MARK: - Icon Helpers
private extension PropertyType {
    var icon: String {
        switch self.rawValue.lowercased() {
        case "house": return "house.fill"
        case "apartment": return "building.2.fill"
        case "condo": return "building.fill"
        case "villa": return "house.lodge.fill"
        case "land": return "leaf.fill"
        default: return "house.fill"
        }
    }
}

private extension PropertyPurpose {
    var icon: String {
        switch self {
        case .buy: return "cart.fill"
        case .rent: return "key.fill"
        case .seasonal: return "calendar"
        case .all: return "square.grid.2x2.fill"
        }
    }
}

// MARK: - Property Type Selection View
private struct PropertyTypeSelectionView: View {
    @Binding var selectedType: PropertyType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "building.fill")
                    .foregroundColor(Theme.textWhite)
                Text("property_type".localized)
                    .foregroundColor(Theme.textWhite)
                    .font(.headline)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(PropertyType.allCases.filter { $0 != .all }, id: \.self) { type in
                    Button(action: { selectedType = type }) {
                        VStack(spacing: 8) {
                            Image(systemName: type.icon)
                                .font(.system(size: 24))
                            Text(type.rawValue)
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedType == type ? Theme.primaryRed : Theme.cardBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedType == type ? Theme.primaryRed : Theme.textWhite.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .foregroundColor(selectedType == type ? .white : Theme.textWhite)
                    }
                }
            }
        }
    }
}

// MARK: - Property Purpose Selection View
private struct PropertyPurposeSelectionView: View {
    @Binding var selectedPurpose: PropertyPurpose
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "tag.fill")
                    .foregroundColor(Theme.textWhite)
                Text("purpose".localized)
                    .foregroundColor(Theme.textWhite)
                    .font(.headline)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(PropertyPurpose.allCases.filter { $0 != .all }, id: \.self) { purpose in
                    Button(action: { selectedPurpose = purpose }) {
                        VStack(spacing: 8) {
                            Image(systemName: purpose.icon)
                                .font(.system(size: 24))
                            Text(purpose.rawValue)
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedPurpose == purpose ? Theme.primaryRed : Theme.cardBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedPurpose == purpose ? Theme.primaryRed : Theme.textWhite.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .foregroundColor(selectedPurpose == purpose ? .white : Theme.textWhite)
                    }
                }
            }
        }
    }
}

// MARK: - Price Input View
private struct PriceInputView: View {
    @Binding var price: Double
    @Binding var priceCurrency: Currency
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(Theme.textWhite)
                Text("price".localized)
                    .foregroundColor(Theme.textWhite)
                    .font(.headline)
            }
            
            HStack(spacing: 12) {
                TextField("", value: $price, format: .number)
                    .keyboardType(.decimalPad)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Theme.cardBackground)
                    .cornerRadius(10)
                    .foregroundColor(Theme.textWhite)
                    .tint(Theme.primaryRed)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Theme.textWhite.opacity(0.2), lineWidth: 1)
                    )
                    .placeholder(when: price == 0) {
                        Text("0")
                            .foregroundColor(Theme.textWhite.opacity(0.5))
                    }
                
                Picker("Currency", selection: $priceCurrency) {
                    ForEach(Currency.allCases, id: \.self) { currency in
                        Text(currency.rawValue.uppercased())
                            .tag(currency)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 100)
                .padding(12)
                .background(Theme.cardBackground)
                .cornerRadius(10)
                .foregroundColor(Theme.textWhite)
                .tint(Theme.primaryRed)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Theme.textWhite.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }
}

// MARK: - Form Content Views
private struct BasicInfoView: View {
    @Binding var title: String
    @Binding var description: String
    @Binding var selectedType: PropertyType
    @Binding var selectedPurpose: PropertyPurpose
    @Binding var price: Double
    @Binding var priceCurrency: Currency
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                TextFormField(
                    label: "property_title".localized,
                    placeholder: "enter_property_title".localized,
                    text: $title,
                    icon: "house.fill"
                )
                
                PropertyTypeSelectionView(selectedType: $selectedType)
                PropertyPurposeSelectionView(selectedPurpose: $selectedPurpose)
                
                TextFormField(
                    label: "description".localized,
                    placeholder: "enter_property_description".localized,
                    text: $description,
                    icon: "doc.text.fill"
                )
                
                PriceInputView(price: $price, priceCurrency: $priceCurrency)
            }
            .padding()
        }
    }
}

private struct LocationView: View {
    @Binding var address: String
    @Binding var city: String
    @Binding var zipCode: String
    @Binding var country: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                TextFormField(
                    label: "address".localized,
                    placeholder: "enter_address".localized,
                    text: $address,
                    icon: "mappin.circle.fill"
                )
                
                TextFormField(
                    label: "city".localized,
                    placeholder: "enter_city".localized,
                    text: $city,
                    icon: "building.2.fill"
                )
                
                TextFormField(
                    label: "zip_code".localized,
                    placeholder: "enter_zip_code".localized,
                    text: $zipCode,
                    icon: "number.circle.fill"
                )
                
                TextFormField(
                    label: "country".localized,
                    placeholder: "enter_country".localized,
                    text: $country,
                    icon: "globe.europe.africa.fill"
                )
            }
            .padding()
        }
    }
}

private struct DetailsView: View {
    @Binding var bedrooms: Int
    @Binding var bathrooms: Int
    @Binding var area: Double
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                NumericFormField(
                    "bedrooms".localized,
                    value: $bedrooms,
                    icon: "bed.double.fill"
                )
                
                NumericFormField(
                    "bathrooms".localized,
                    value: $bathrooms,
                    icon: "shower.fill"
                )
                
                NumericFormField(
                    "area".localized,
                    value: $area,
                    icon: "square.fill"
                )
            }
            .padding()
        }
    }
}

private struct PhotosView: View {
    @Binding var imageURLs: [String]
    @Binding var newImageData: [Data]
    @Binding var selectedImages: [PhotosPickerItem]
    @Binding var isProcessingImages: Bool
    let maxImages: Int
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Image Counter
                HStack {
                    Image(systemName: "photo.stack.fill")
                        .foregroundColor(Theme.textWhite)
                    Text("\(imageURLs.count + newImageData.count)/\(maxImages) \("photos".localized)")
                        .foregroundColor(Theme.textWhite)
                    Spacer()
                    if imageURLs.count + newImageData.count < maxImages {
                        PhotosPicker(
                            selection: $selectedImages,
                            maxSelectionCount: maxImages - (imageURLs.count + newImageData.count),
                            matching: .images
                        ) {
                            Label("add_photos".localized, systemImage: "plus.circle.fill")
                                .foregroundColor(Theme.primaryRed)
                        }
                    }
                }
                
                if isProcessingImages {
                    ProgressView("processing_images".localized)
                        .tint(Theme.primaryRed)
                }
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    // Show existing images
                    ForEach(imageURLs, id: \.self) { imageURL in
                        ImageCell(imageURL: imageURL, onDelete: {
                            imageURLs.removeAll { $0 == imageURL }
                        })
                    }
                    
                    // Show new images
                    ForEach(newImageData.indices, id: \.self) { index in
                        if let uiImage = UIImage(data: newImageData[index]) {
                            ImageCell(uiImage: uiImage, onDelete: {
                                newImageData.remove(at: index)
                            })
                        }
                    }
                }
            }
            .padding()
        }
    }
}

private struct ImageCell: View {
    let imageURL: String?
    let uiImage: UIImage?
    let onDelete: () -> Void
    
    init(imageURL: String, onDelete: @escaping () -> Void) {
        self.imageURL = imageURL
        self.uiImage = nil
        self.onDelete = onDelete
    }
    
    init(uiImage: UIImage, onDelete: @escaping () -> Void) {
        self.imageURL = nil
        self.uiImage = uiImage
        self.onDelete = onDelete
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let imageURL = imageURL {
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
            } else if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .background(Circle().fill(Color.white))
            }
            .padding(4)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

private struct ContactView: View {
    @Binding var contactWhatsapp: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                whatsAppContactField(contactWhatsapp: $contactWhatsapp)
            }
            .padding()
        }
    }
    
    private func whatsAppContactField(contactWhatsapp: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("whatsapp".localized)
                .font(.caption)
                .foregroundColor(Theme.textWhite.opacity(0.7))
            
            HStack {
                Image("whatsapp_icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color(red: 37/255, green: 211/255, blue: 102/255))
                
                TextField("", text: contactWhatsapp)
                    .keyboardType(.phonePad)
                    .foregroundColor(Theme.textWhite)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .placeholder(when: contactWhatsapp.wrappedValue.isEmpty) {
                        Text("whatsapp_example".localized)
                            .foregroundColor(Theme.textWhite.opacity(0.5))
                    }
            }
            .padding(12)
            .background(Theme.cardBackground)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(contactWhatsapp.wrappedValue.isEmpty ? Color.clear : 
                            (ContactInfo(whatsapp: contactWhatsapp.wrappedValue).isValidWhatsApp() ? 
                             Color.green : Color.red), 
                     lineWidth: 2)
            )
        }
    }
}

// MARK: - Navigation Buttons View
private struct NavigationButtonsView: View {
    let currentStep: Int
    let totalSteps: Int
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            if currentStep > 0 {
                Button(action: onPrevious) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("previous".localized)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                }
                .secondaryButton()
            }
            
            if currentStep < totalSteps - 1 {
                Button(action: onNext) {
                    HStack {
                        Text("next".localized)
                        Image(systemName: "chevron.right")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                }
                .primaryButton()
            } else {
                Button(action: onSave) {
                    Text("save_property".localized)
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

// MARK: - Main Content View
private struct MainContentView: View {
    @Binding var currentStep: Int
    @Binding var title: String
    @Binding var description: String
    @Binding var selectedType: PropertyType
    @Binding var selectedPurpose: PropertyPurpose
    @Binding var price: Double
    @Binding var priceCurrency: Currency
    @Binding var address: String
    @Binding var city: String
    @Binding var zipCode: String
    @Binding var country: String
    @Binding var bedrooms: Int
    @Binding var bathrooms: Int
    @Binding var area: Double
    @Binding var imageURLs: [String]
    @Binding var newImageData: [Data]
    @Binding var selectedImages: [PhotosPickerItem]
    @Binding var isProcessingImages: Bool
    @Binding var contactWhatsapp: String
    let maxImages: Int
    
    var body: some View {
        TabView(selection: $currentStep) {
            BasicInfoView(
                title: $title,
                description: $description,
                selectedType: $selectedType,
                selectedPurpose: $selectedPurpose,
                price: $price,
                priceCurrency: $priceCurrency
            )
            .tag(0)
            
            LocationView(
                address: $address,
                city: $city,
                zipCode: $zipCode,
                country: $country
            )
            .tag(1)
            
            DetailsView(
                bedrooms: $bedrooms,
                bathrooms: $bathrooms,
                area: $area
            )
            .tag(2)
            
            PhotosView(
                imageURLs: $imageURLs,
                newImageData: $newImageData,
                selectedImages: $selectedImages,
                isProcessingImages: $isProcessingImages,
                maxImages: maxImages
            )
            .tag(3)
            
            ContactView(contactWhatsapp: $contactWhatsapp)
                .tag(4)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}
