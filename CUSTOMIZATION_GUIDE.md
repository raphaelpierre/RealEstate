# Real Estate App Customization Guide

This guide will help you customize your Real Estate iOS app with a professional app icon and a video splash screen.

## Table of Contents

1. [Adding an App Icon](#adding-an-app-icon)
2. [Adding a Video Splash Screen](#adding-a-video-splash-screen)
3. [Testing Your Customizations](#testing-your-customizations)
4. [Troubleshooting](#troubleshooting)

## Adding an App Icon

A professional app icon is crucial for making a good first impression on users. Follow these steps to add a custom app icon to your Real Estate app.

### Step 1: Design Your App Icon

Create a square image (1024×1024 pixels) that represents your Real Estate app. For detailed guidance on designing an effective app icon, refer to the [PROFESSIONAL_APP_ICON_GUIDE.md](PROFESSIONAL_APP_ICON_GUIDE.md) file.

### Step 2: Generate App Icon Assets

You have two options for generating the necessary app icon assets:

#### Option 1: Using Our Scripts (Recommended)

If you have an SVG file:
1. Run the SVG to PNG converter script:
   ```
   ./convert_svg_to_png.sh
   ```
2. This will create a PNG file from the SVG.

Then, for any PNG file:
1. Run the app icon generator script:
   ```
   ./generate_app_icon.sh
   ```
2. When prompted, enter the path to your PNG file.
3. The script will generate all required icon sizes in an `AppIcon.appiconset` directory.

#### Option 2: Using Online Tools

1. Visit an app icon generator website like [AppIconMaker](https://appiconmaker.co/)
2. Upload your 1024×1024 pixel image
3. Download the generated icon set

### Step 3: Add the Icons to Your Xcode Project

1. Open your Xcode project
2. In the Project Navigator, select `Assets.xcassets`
3. If you already have an `AppIcon.appiconset` folder, delete it or rename it
4. Copy your new `AppIcon.appiconset` folder to the `Assets.xcassets` directory
5. Verify that Xcode recognizes the app icon set

## Adding a Video Splash Screen

A video splash screen can make your app feel more premium and engaging. Follow these steps to add a video splash screen to your Real Estate app.

### Step 1: Prepare Your Video

1. Create or select an MP4 video file that you want to use as your splash screen
2. Keep the video short (3-5 seconds is ideal)
3. Make sure the video has dimensions that work well on mobile devices (e.g., 1080×1920 for portrait)
4. Consider creating a video without audio or with subtle audio

### Step 2: Add the Video to Your Project

#### Option 1: Using the Helper Script

1. Run the provided helper script:
   ```
   ./add_splash_video.sh
   ```
2. Follow the prompts to specify the path to your MP4 file
3. Open your Xcode project and add the copied file to your project

#### Option 2: Manual Addition

1. Rename your video file to `splash_video.mp4`
2. Drag the file into your Xcode project
3. When prompted, make sure "Copy items if needed" is checked
4. Add the file to your RealEstate target

### Step 3: Customize the Video Splash Screen (Optional)

You can customize the behavior of the video splash screen by modifying the properties in `VideoSplashView.swift`:

```swift
// Name of your video file without extension
private let videoName = "splash_video" 

// Video file extension
private let videoExtension = "mp4"

// Set to true if you want the video to loop
private let loopVideo = false 

// Maximum duration to show video (in seconds)
private let maxDuration: Double = 5.0 

// Set to false if you want audio
private let muteAudio = true 
```

## Testing Your Customizations

After adding both the app icon and video splash screen, it's important to test them thoroughly:

1. Clean your build folder (Product > Clean Build Folder)
2. Build and run your app on different devices or simulators
3. Verify that:
   - The app icon appears correctly on the home screen
   - The video splash screen plays when the app launches
   - The app transitions smoothly from the splash screen to the main content

## Troubleshooting

### App Icon Issues

- **Icon not appearing**: Make sure all required sizes are provided and the AppIcon set is selected in your target settings
- **Icon looks pixelated**: Ensure you're using a high-quality source image (1024×1024 pixels)
- **Icon has wrong colors**: Check that your image is using the correct color profile (sRGB)

### Video Splash Screen Issues

- **Video doesn't play**: Make sure the video file is correctly added to your project's bundle
- **Video plays but no transition**: Check that the notification observer for video completion is working
- **Poor video quality**: Use a higher quality video file or adjust the encoding settings
- **App crashes**: Ensure the video format is compatible with iOS (H.264 encoding is recommended)

## Additional Resources

- [Apple Human Interface Guidelines - App Icons](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [Apple Human Interface Guidelines - Launch Screen](https://developer.apple.com/design/human-interface-guidelines/launching)
- [Video Compression Guide for iOS](https://developer.apple.com/documentation/avfoundation/avassetexportsession/1388728-presets)

---

For more detailed information about each customization, refer to:
- [APP_ICON_INSTRUCTIONS.md](APP_ICON_INSTRUCTIONS.md)
- [PROFESSIONAL_APP_ICON_GUIDE.md](PROFESSIONAL_APP_ICON_GUIDE.md)
- [SPLASH_VIDEO_INSTRUCTIONS.md](SPLASH_VIDEO_INSTRUCTIONS.md) 