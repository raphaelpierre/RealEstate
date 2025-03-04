# Implementing Localization in Your Real Estate App

This guide will help you implement localization in your SwiftUI views using the localization tools we've created.

## Table of Contents
1. [Using the Localization Helper](#using-the-localization-helper)
2. [Manual Implementation](#manual-implementation)
3. [Testing Localization](#testing-localization)
4. [Best Practices](#best-practices)
5. [Examples](#examples)

## Using the Localization Helper

We've created a script called `localize_code.sh` that automatically updates your SwiftUI code to use localization. Here's how to use it:

1. Make sure the script is executable:
   ```bash
   chmod +x localize_code.sh
   ```

2. Run the script:
   ```bash
   ./localize_code.sh
   ```

3. The script will:
   - Create a backup of your Swift files
   - Update common SwiftUI text elements to use localization
   - Generate localization keys based on the existing text

4. After running the script, review the changes and add any missing keys to your `Localizable.strings` files.

## Manual Implementation

If you prefer to implement localization manually or need to handle special cases, here's how to do it:

### Text Elements

Replace hardcoded strings with localized versions:

```swift
// Before
Text("Property Details")

// After
Text("property_details".localized)
```

### Buttons

```swift
// Before
Button("Save") { ... }

// After
Button("save".localized) { ... }
```

### Navigation Titles

```swift
// Before
.navigationTitle("Settings")

// After
.navigationTitle("settings".localized)
```

### Text with Arguments

For text that includes dynamic values:

```swift
// Before
Text("Price: $\(property.price)")

// After
Text(String(format: "price_format".localized, property.price))
```

In your `Localizable.strings` files:
```
"price_format" = "Price: $%@";
```

And in French:
```
"price_format" = "Prix: %@€";
```

### Using the LocalizationManager

The `LocalizationManager` class provides helpful utilities:

```swift
// Format currency according to locale
let price = LocalizationManager.shared.formatCurrency(1250000)
// $1,250,000 in English, 1 250 000 € in French

// Format area according to locale
let area = LocalizationManager.shared.formatArea(150)
// 150 sq ft in English, 150 m² in French

// Check if app is running in French
if LocalizationManager.shared.isRunningInFrench {
    // French-specific code
}
```

## Testing Localization

To test your app in different languages:

### Using Preview

Use the preview helper to see your views in French:

```swift
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDisplayName("English")
        
        ContentView()
            .environment(\.locale, .init(identifier: "fr"))
            .previewDisplayName("French")
    }
}
```

### On Device

1. Go to Settings > General > Language & Region
2. Add French as a preferred language
3. Launch your app to see it in French

## Best Practices

1. **Use Descriptive Keys**: Instead of `"btn1"`, use `"save_property_button"`.

2. **Group Related Keys**: Keep related keys together in your strings files.

3. **Comment Your Strings**: Add comments to explain context for translators.
   ```
   /* Button to save property changes */
   "save_property" = "Save";
   ```

4. **Handle Plurals**: Use different keys for singular and plural forms.
   ```
   "one_bedroom" = "1 Bedroom";
   "multiple_bedrooms" = "%d Bedrooms";
   ```

5. **Test with Different Languages**: Some languages may have longer text that could break your layout.

6. **Keep Strings Files Organized**: Use consistent naming and grouping.

## Examples

### Example 1: Property Listing Card

```swift
struct PropertyCard: View {
    let property: Property
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(property.mainImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipped()
            
            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizationManager.shared.formatCurrency(property.price))
                    .font(.headline)
                
                HStack {
                    Text("\(property.bedrooms) \("bedrooms".localized)")
                    Text("•")
                    Text("\(property.bathrooms) \("bathrooms".localized)")
                    Text("•")
                    Text("\(LocalizationManager.shared.formatArea(property.area))")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                Text(property.address)
                    .font(.body)
                
                Button("view_details".localized) {
                    // Action
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}
```

### Example 2: Filter View

```swift
struct FilterView: View {
    @State private var minPrice: Double = 0
    @State private var maxPrice: Double = 1000000
    @State private var bedrooms: Int = 0
    
    var body: some View {
        Form {
            Section(header: Text("price_range".localized)) {
                HStack {
                    Text("min_price".localized)
                    Spacer()
                    Text(LocalizationManager.shared.formatCurrency(Int(minPrice)))
                }
                Slider(value: $minPrice, in: 0...1000000, step: 50000)
                
                HStack {
                    Text("max_price".localized)
                    Spacer()
                    Text(LocalizationManager.shared.formatCurrency(Int(maxPrice)))
                }
                Slider(value: $maxPrice, in: 0...5000000, step: 50000)
            }
            
            Section(header: Text("bedrooms".localized)) {
                Picker("bedrooms".localized, selection: $bedrooms) {
                    Text("any".localized).tag(0)
                    Text("1+").tag(1)
                    Text("2+").tag(2)
                    Text("3+").tag(3)
                    Text("4+").tag(4)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Button("apply_filters".localized) {
                // Apply filters
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding()
        }
        .navigationTitle("filters".localized)
    }
}
```

By following this guide, you'll be able to fully localize your Real Estate app, providing a great experience for both English and French users. 