# Real Estate App Localization Suite

This repository contains a comprehensive suite of tools and resources for localizing your Real Estate iOS app in both English and French. This README provides an overview of all the localization components and how to use them.

## Table of Contents

1. [Localization Files](#localization-files)
2. [Helper Tools](#helper-tools)
3. [Implementation Guides](#implementation-guides)
4. [Sample Components](#sample-components)
5. [Getting Started](#getting-started)

## Localization Files

### Localizable.strings (English)

The main localization file containing all English strings used in the app. This file includes:
- General app terms
- Authentication strings
- Property listing details
- Filter options
- Admin functionalities
- Error messages
- Success messages

### Localizable.strings.fr (French)

The French translation of all strings in the app, following the same structure as the English file.

## Helper Tools

### LocalizationHelper.swift

A utility file that provides:
- String extension for easy localization (`"key".localized`)
- View extension for localized accessibility identifiers
- LocalizationManager class for:
  - Checking current app language
  - Formatting currency based on locale
  - Formatting area measurements based on locale
  - Formatting dates based on locale
- Preview helper for testing views in French

### localize_code.sh

A shell script that automatically updates your existing SwiftUI code to use localization:
- Creates a backup of your Swift files
- Scans for hardcoded strings in common SwiftUI components
- Replaces them with localized versions
- Generates appropriate localization keys

### convert_svg_to_png.sh

A utility script for converting SVG icons to PNG format, which can be useful when creating localized assets.

## Implementation Guides

### LOCALIZATION_IMPLEMENTATION_GUIDE.md

A comprehensive guide that covers:
- Using the localization helper script
- Manual implementation of localization
- Testing localization in previews and on device
- Best practices for localization
- Example implementations

### FRENCH_LOCALIZATION_GUIDE.md

A detailed guide specifically for French localization, including:
- Setting up the Xcode project for French
- Creating French translation files
- Implementing French-specific formatting
- Testing French localization

## Sample Components

### LocalizedPropertyDetailView.swift

A fully localized sample view that demonstrates:
- Localized text elements
- Localized navigation titles
- Localized accessibility labels
- Locale-aware formatting for currency and measurements
- Preview configuration for both English and French

## Getting Started

To implement localization in your Real Estate app:

1. **Set up localization files**:
   - Add `Localizable.strings` for English
   - Add `Localizable.strings.fr` for French

2. **Add the helper utilities**:
   - Copy `LocalizationHelper.swift` to your project

3. **Update your existing code**:
   - Run `./localize_code.sh` to automatically update your code
   - Review the changes and add any missing keys to your strings files

4. **Test your localization**:
   - Use the preview helper to test in both English and French
   - Test on device by changing the device language

5. **Follow best practices**:
   - Use descriptive keys
   - Group related keys together
   - Add comments for context
   - Handle plurals appropriately

## Additional Resources

- [Apple's Localization Guide](https://developer.apple.com/documentation/xcode/localization)
- [Human Interface Guidelines for Localization](https://developer.apple.com/design/human-interface-guidelines/internationalization)

## License

This localization suite is provided under the MIT License.

---

For any questions or issues, please open an issue in the repository. 