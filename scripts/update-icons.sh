#!/bin/bash

echo "========================================"
echo "DIU Route Explorer - Icon Update Script"
echo "========================================"
echo ""
echo "This script will help you update the app icons."
echo ""
echo "Instructions:"
echo "1. Place your new 'Icon.png' file in assets/icons/"
echo "2. Place your new 'Icon-dark.png' file in assets/icons/ (optional)"
echo "3. Run this script to regenerate all platform icons"
echo ""

if [ ! -f "assets/icons/Icon.png" ]; then
    echo "ERROR: Icon.png not found in assets/icons/"
    echo "Please add your new Icon.png file to assets/icons/ first."
    exit 1
fi

echo "Icon.png found! Generating new launcher icons..."
echo ""

flutter packages get
flutter packages pub run flutter_launcher_icons:main

echo ""
echo "========================================"
echo "Icon update completed!"
echo "========================================"
echo ""
echo "The following platforms have been updated:"
echo "- Android (adaptive icons included)"
echo "- iOS"
echo "- Web"
echo "- Windows"
echo "- macOS"
echo ""
echo "You may need to clean and rebuild your project:"
echo "flutter clean"
echo "flutter build apk --release"
echo ""
