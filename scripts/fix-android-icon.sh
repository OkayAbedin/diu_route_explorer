#!/bin/bash

# Android Icon Fix Script
# This script helps create an adaptive icon version for Android

echo "🔧 Android Icon Fix Script"
echo "=========================="

# Check if ImageMagick is available
if ! command -v magick &> /dev/null && ! command -v convert &> /dev/null; then
    echo "❌ ImageMagick not found. Please install ImageMagick first:"
    echo "   - Windows: Download from https://imagemagick.org/script/download.php#windows"
    echo "   - macOS: brew install imagemagick"
    echo "   - Linux: sudo apt-get install imagemagick"
    echo ""
    echo "📝 Manual alternative:"
    echo "   1. Open assets/icons/Icon.png in an image editor"
    echo "   2. Resize canvas to 1024x1024"
    echo "   3. Make your logo ~65% smaller and center it"
    echo "   4. Save as assets/icons/Icon-adaptive.png"
    exit 1
fi

# Check if source icon exists
if [ ! -f "assets/icons/Icon.png" ]; then
    echo "❌ Source icon not found: assets/icons/Icon.png"
    exit 1
fi

echo "✅ Found source icon: assets/icons/Icon.png"

# Create adaptive icon with proper padding
echo "🎨 Creating adaptive icon with proper padding..."

# Use ImageMagick to create adaptive icon
if command -v magick &> /dev/null; then
    # ImageMagick 7.x
    magick assets/icons/Icon.png -resize 65% -background transparent -gravity center -extent 1024x1024 assets/icons/Icon-adaptive.png
else
    # ImageMagick 6.x
    convert assets/icons/Icon.png -resize 65% -background transparent -gravity center -extent 1024x1024 assets/icons/Icon-adaptive.png
fi

if [ $? -eq 0 ]; then
    echo "✅ Created: assets/icons/Icon-adaptive.png"
    echo ""
    echo "📋 Next steps:"
    echo "   1. Update pubspec.yaml:"
    echo "      adaptive_icon_foreground: \"assets/icons/Icon-adaptive.png\""
    echo "   2. Run: flutter packages get"
    echo "   3. Run: flutter packages pub run flutter_launcher_icons:main"
    echo "   4. Rebuild APK: flutter build apk --release"
    echo ""
    echo "🎯 This should fix the zoomed-in Android icon issue!"
else
    echo "❌ Failed to create adaptive icon"
    echo "📝 Please create it manually as described above"
fi
