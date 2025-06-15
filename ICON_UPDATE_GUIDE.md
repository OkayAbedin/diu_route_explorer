# Icon Update Guide for DIU Route Explorer

## Overview
This guide explains how to update the app icons throughout the DIU Route Explorer Flutter project.

## Current Icon Setup
The project has been configured to use:
- **Icon.png** - Main app icon (light version)
- **Icon-dark.png** - Dark mode app icon (optional)

## File Locations
- Source icons: `assets/icons/Icon.png` and `assets/icons/Icon-dark.png`
- Generated platform icons are automatically created in platform-specific directories

## Supported Platforms
- ✅ Android (including adaptive icons)
- ✅ iOS (App Store compliant)
- ✅ Web (PWA icons)
- ✅ Windows
- ✅ macOS

## How to Update Icons

### Method 1: Using the Update Script (Recommended)
1. Replace `assets/icons/Icon.png` with your new icon
2. Replace `assets/icons/Icon-dark.png` with your dark mode icon (optional)
3. Run the update script:
   - Windows: `scripts\update-icons.bat`
   - macOS/Linux: `scripts/update-icons.sh`

### Method 2: Manual Update
1. Replace the icon files in `assets/icons/`
2. Run the following commands:
   ```bash
   flutter packages get
   flutter packages pub run flutter_launcher_icons:main
   ```

## Icon Requirements
- **Format**: PNG
- **Recommended size**: 1024x1024 pixels minimum
- **Background**: Should work well on both light and dark backgrounds
- **Transparency**: Alpha channel will be removed for iOS compliance

## What Gets Updated
When you update the icons, the following will be automatically generated:
- Android launcher icons (all densities)
- Android adaptive icons with the specified background color (#580dda)
- iOS app icons (all required sizes)
- Web app icons (192x192, 512x512, maskable variants)
- Windows app icon
- macOS app icon

## Affected Files
The icon update process modifies these files:
- `android/app/src/main/res/mipmap-*/ic_launcher.png`
- `android/app/src/main/res/mipmap-*/ic_launcher_adaptive_fore.png`
- `android/app/src/main/res/mipmap-*/ic_launcher_adaptive_back.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png`
- `web/icons/Icon-*.png`
- `windows/runner/resources/app_icon.ico`
- `macos/Runner/Assets.xcassets/AppIcon.appiconset/*.png`

## Code References Updated
The following files have been updated to reference the new Icon.png:
- `lib/screens/splash_screen.dart` - Splash screen logo
- `web/index.html` - Web app loading screen and favicon
- `README.md` - Project documentation

## Troubleshooting

### Android Icon Appears Zoomed In
If the Android app icon appears zoomed in compared to web:
1. **Root Cause**: Android adaptive icons use a smaller safe area (~66% of canvas)
2. **Solution**: Create `assets/icons/Icon-adaptive.png` with your logo smaller and centered
3. **Update pubspec.yaml** to use `adaptive_icon_foreground: "assets/icons/Icon-adaptive.png"`
4. **Regenerate icons**: `flutter packages pub run flutter_launcher_icons:main`
5. **See**: `ANDROID_ICON_FIX.md` for detailed instructions

### General Icon Issues
If icons don't appear correctly:
1. Clean the project: `flutter clean`
2. Get dependencies: `flutter packages get`
3. Regenerate icons: `flutter packages pub run flutter_launcher_icons:main`
4. Rebuild the project: `flutter build apk --release`

## Notes
- The old `icon.png` file is kept for backward compatibility
- Dark mode icons are configured but optional
- All generated icons include the purple brand color (#580dda) as background for adaptive icons
