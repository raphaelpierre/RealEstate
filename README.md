# RealEstate App

A modern iOS application for browsing and managing real estate properties, built with SwiftUI and following MVVM architecture.

## Features

### Property Management
- Browse properties with detailed information
- View property details including price, location, and amenities
- Search and filter properties by various criteria
- Save favorite properties
- View property images and descriptions
- Track property views and interactions

### User Experience
- Multi-language support (English and French)
- Currency conversion and formatting
- Area unit conversion (sq ft to m²)
- Dark mode support
- Responsive and adaptive UI
- Smooth animations and transitions

### User Profile
- User authentication and profile management
- Customizable user preferences
- Language and currency settings
- Favorite properties management
- User activity tracking

## Technical Implementation

### Architecture
- MVVM (Model-View-ViewModel) architecture
- SwiftUI for modern UI development
- Combine framework for reactive programming
- Protocol-oriented programming principles

### Key Components

#### Views
- `PropertyListView`: Main property browsing interface
- `PropertyDetailView`: Detailed property information
- `ProfileView`: User profile and settings
- `CurrencySettingsView`: Currency preferences
- `LanguageSwitcher`: Language selection interface

#### ViewModels
- `PropertyListViewModel`: Manages property data and filtering
- `PropertyDetailViewModel`: Handles property detail logic
- `ProfileViewModel`: Manages user profile data
- `CurrencyManager`: Handles currency conversion and formatting

#### Models
- `Property`: Core property data model
- `User`: User profile and preferences
- `Currency`: Currency conversion and formatting
- `Localization`: Multi-language support

### Data Management
- Local data persistence
- Real-time data updates
- Efficient data caching
- Background data refresh

### UI/UX Features
- Custom SwiftUI components
- Responsive layouts
- Accessibility support
- Dynamic type support
- Adaptive color schemes

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+
- macOS 12.0+ (for development)

## Installation

1. Clone the repository:
```bash
git clone https://github.com/raphaelpierre/RealEstate.git
```

2. Open the project in Xcode:
```bash
cd RealEstate
open RealEstate.xcodeproj
```

3. Build and run the project in Xcode

## Dependencies

- SwiftUI
- Combine
- Foundation
- CoreData (for local storage)

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- SwiftUI team for the amazing framework
- Apple for providing excellent development tools
- Contributors and maintainers of the project

# RealEstate App Promotional Website

This repository contains a promotional website for the RealEstate iOS app. The website showcases the app's features, benefits, and pricing plans to attract potential users.

## Quick Start

1. Clone this repository
2. Open `index.html` in your web browser to view the website
3. Check out `demo.html` to see the app's splash video in action

## Features

- Responsive design that works on all devices
- Modern UI with smooth animations and transitions
- Interactive elements (tabbed content, pricing toggle, testimonial slider, etc.)
- Video background using the app's splash video
- Device mockups to showcase the app

## File Structure

- `index.html` - Main promotional website
- `demo.html` - Standalone demo page showcasing the app's splash video
- `styles.css` - CSS styles for the website
- `script.js` - JavaScript for interactive elements
- `images/` - Directory containing app assets
  - `logo.png` - App icon
  - `app-showcase.png` - Banner image
  - `app-screens.png` - App screenshots
  - `splash_video.mp4` - App splash video
  - `testimonial-*.jpg` - Testimonial profile pictures

## Using App Assets

This website uses assets directly from the RealEstate iOS app to maintain brand consistency. The assets were extracted from the app's Assets.xcassets folder.

## Customization

For detailed customization instructions, see `website-README.md`.

## License

This project is licensed under the MIT License - see the LICENSE file for details.