#!/bin/bash

# This script helps generate app icons for your Real Estate iOS app

echo "App Icon Generator for Real Estate iOS App"
echo "=========================================="
echo ""
echo "This script will help you generate app icons from a source image."
echo "You need to have ImageMagick installed to use this script."
echo ""

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick is not installed."
    echo "Please install it using Homebrew:"
    echo "  brew install imagemagick"
    exit 1
fi

# Ask for the path to the source image
read -p "Enter the full path to your source image (1024x1024 recommended): " source_image

# Check if the file exists
if [ ! -f "$source_image" ]; then
    echo "Error: File not found at $source_image"
    exit 1
fi

# Create output directory
output_dir="AppIcon.appiconset"
mkdir -p "$output_dir"

# Generate Contents.json file
cat > "$output_dir/Contents.json" << EOL
{
  "images" : [
    {
      "filename" : "Icon-20@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-20@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-29@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-29@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-40@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-40@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-60@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60"
    },
    {
      "filename" : "Icon-60@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "60x60"
    },
    {
      "filename" : "Icon-20.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-20@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-29.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-29@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-40.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-40@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-76.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "76x76"
    },
    {
      "filename" : "Icon-76@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "76x76"
    },
    {
      "filename" : "Icon-83.5@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "83.5x83.5"
    },
    {
      "filename" : "Icon-1024.png",
      "idiom" : "ios-marketing",
      "scale" : "1x",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOL

echo "Generating app icons..."

# Generate iPhone icons
convert "$source_image" -resize 40x40 "$output_dir/Icon-20@2x.png"
convert "$source_image" -resize 60x60 "$output_dir/Icon-20@3x.png"
convert "$source_image" -resize 58x58 "$output_dir/Icon-29@2x.png"
convert "$source_image" -resize 87x87 "$output_dir/Icon-29@3x.png"
convert "$source_image" -resize 80x80 "$output_dir/Icon-40@2x.png"
convert "$source_image" -resize 120x120 "$output_dir/Icon-40@3x.png"
convert "$source_image" -resize 120x120 "$output_dir/Icon-60@2x.png"
convert "$source_image" -resize 180x180 "$output_dir/Icon-60@3x.png"

# Generate iPad icons
convert "$source_image" -resize 20x20 "$output_dir/Icon-20.png"
convert "$source_image" -resize 29x29 "$output_dir/Icon-29.png"
convert "$source_image" -resize 40x40 "$output_dir/Icon-40.png"
convert "$source_image" -resize 76x76 "$output_dir/Icon-76.png"
convert "$source_image" -resize 152x152 "$output_dir/Icon-76@2x.png"
convert "$source_image" -resize 167x167 "$output_dir/Icon-83.5@2x.png"

# Generate App Store icon
convert "$source_image" -resize 1024x1024 "$output_dir/Icon-1024.png"

echo ""
echo "App icons generated successfully in the '$output_dir' directory."
echo ""
echo "Next steps:"
echo "1. Open your Xcode project"
echo "2. In the Project Navigator, select Assets.xcassets"
echo "3. Right-click and select 'New App Icon Set' (if you don't already have one)"
echo "4. Delete any existing AppIcon.appiconset folder in Assets.xcassets"
echo "5. Copy the generated AppIcon.appiconset folder to your Assets.xcassets directory"
echo "6. Verify that the app icon appears in Xcode"
echo ""
echo "You can also manually copy the AppIcon.appiconset folder to:"
echo "RealEstate/Assets.xcassets/" 