# Adding a Splash Video to Your Real Estate App

This guide will help you add a video splash screen to your Real Estate iOS app.

## Step 1: Prepare Your Video

1. Create or select an MP4 video file that you want to use as your splash screen.
2. Keep the video short (3-5 seconds is ideal) to avoid making users wait too long.
3. Make sure the video has dimensions that work well on mobile devices (e.g., 1080x1920 for portrait).
4. Consider creating a video without audio or with subtle audio.

## Step 2: Add the Video to Your Project

### Option 1: Using the Helper Script

1. Run the provided helper script:
   ```
   ./add_splash_video.sh
   ```
2. Follow the prompts to specify the path to your MP4 file.
3. Open your Xcode project and add the copied file to your project.

### Option 2: Manual Addition

1. Rename your video file to `splash_video.mp4`.
2. Drag the file into your Xcode project.
3. When prompted, make sure "Copy items if needed" is checked.
4. Add the file to your RealEstate target.

## Step 3: Customize the Video Splash Screen (Optional)

You can customize the behavior of the video splash screen by modifying the following properties in `VideoSplashView.swift`:

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

## Step 4: Test Your App

Run your app to see the video splash screen in action. The app will automatically transition to the main content view after the video finishes playing or when the maximum duration is reached.

## Troubleshooting

If your video doesn't play:

1. Make sure the video file is correctly added to your project's bundle.
2. Check that the video name and extension in `VideoSplashView.swift` match your actual file.
3. Verify that the video format is compatible with iOS (H.264 encoding is recommended).
4. Try a different video file to see if the issue is with the specific video.

## Advanced Customization

For more advanced customization, you can modify the `VideoSplashView.swift` file to:

- Add custom overlays or text on top of the video
- Create more complex transitions between the video and your app
- Implement interactive elements during the video playback 