#!/bin/bash

# This script helps you add a splash video to your RealEstate project

echo "This script will help you add a splash video to your RealEstate project."
echo "Please make sure you have your MP4 file ready."
echo ""

# Ask for the path to the MP4 file
read -p "Enter the full path to your MP4 file: " video_path

# Check if the file exists
if [ ! -f "$video_path" ]; then
    echo "Error: File not found at $video_path"
    exit 1
fi

# Create destination directory if it doesn't exist
mkdir -p "RealEstate/Assets.xcassets/Videos.spriteatlas"

# Copy the file to the project
cp "$video_path" "RealEstate/splash_video.mp4"

echo ""
echo "Video file copied to RealEstate/splash_video.mp4"
echo ""
echo "Next steps:"
echo "1. Open your Xcode project"
echo "2. Drag the splash_video.mp4 file from Finder into your project navigator"
echo "3. When prompted, make sure 'Copy items if needed' is checked"
echo "4. Add the file to your RealEstate target"
echo ""
echo "Your video splash screen should now work when you run the app!" 