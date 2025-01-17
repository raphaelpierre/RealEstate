Real Estate iOS App
A modern iOS application for real estate property listings built with SwiftUI and Firebase.

Features:

🏠 Property Listings
View detailed property information
Search and filter properties
Sort by price, bedrooms, and date added

👤 User Authentication
Email/password authentication
User profile management
Password reset functionality

👑 Admin Panel
Manage property listings
Add, edit, and delete properties
Upload property images

🎨 Modern UI/UX
Clean and intuitive interface
Responsive design
Image galleries
Loading states and error handling

Requirements:

iOS 15.0+
Xcode 13.0+
Swift 5.5+
Firebase account

Installation:
Clone the repository git clone https://github.com/raphaelpierre/RealEstate.git 
cd RealEstate
Set up Firebase
Create a new Firebase project
Add an iOS app in Firebase console
Download GoogleService-Info.plist
Add it to the project (don't commit this file)
Open the project in Xcode open RealEstate.xcodeproj
Build and run the project
Configuration
Firebase Setup
Enable Authentication with Email/Password
Set up Cloud Firestore
Configure Storage for images
Security Rules
Configure Firestore rules
Set up Storage rules

Architecture:
SwiftUI for UI
MVVM architecture
Firebase for backend
Async/await for asynchronous operations

Project Structure:
RealEstate/ 
├── Models/ 
│ ├── Property.swift 
│ └── User.swift 
├── Views/ 
│ ├── PropertyListView.swift 
│ ├── PropertyDetailView.swift 
│ ├── LoginView.swift 
│ └── AdminView.swift 
├── Services/ 
│ └── FirebaseManager.swift 
└── Supporting Files/ 
└── Info.plist

Contributing:
Fork the repository
Create your feature branch (git checkout -b feature/AmazingFeature)
Commit your changes (git commit -m 'Add some AmazingFeature')
Push to the branch (git push origin feature/AmazingFeature)
Open a Pull Request

License:
This project is licensed under the MIT License - see the LICENSE file for details

Acknowledgments:
SwiftUI for the modern UI framework
Firebase for backend services
The iOS development community