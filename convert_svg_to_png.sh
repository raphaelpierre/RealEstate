#!/bin/bash

# This script converts an SVG file to a PNG file for use with the app icon generator

echo "SVG to PNG Converter for App Icon"
echo "================================="
echo ""
echo "This script will convert an SVG file to a PNG file for use with the app icon generator."
echo "You need to have ImageMagick installed to use this script."
echo ""

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick is not installed."
    echo "Please install it using Homebrew:"
    echo "  brew install imagemagick"
    exit 1
fi

# Default SVG file
svg_file="real_estate_icon.svg"

# Check if the file exists
if [ ! -f "$svg_file" ]; then
    echo "Error: SVG file not found at $svg_file"
    exit 1
fi

# Output PNG file
png_file="real_estate_icon.png"

# Convert SVG to PNG
echo "Converting $svg_file to $png_file..."
convert -background none "$svg_file" -resize 1024x1024 "$png_file"

echo ""
echo "Conversion complete! PNG file created at: $png_file"
echo ""
echo "You can now use this PNG file with the app icon generator script:"
echo "  ./generate_app_icon.sh"
echo "When prompted, enter the path to the PNG file: $png_file" 