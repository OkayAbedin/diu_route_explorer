@echo off
REM Android Icon Fix Script for Windows
REM This script helps create an adaptive icon version for Android

echo 🔧 Android Icon Fix Script
echo ==========================

REM Check if ImageMagick is available
magick -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ ImageMagick not found. Please install ImageMagick first:
    echo    Download from https://imagemagick.org/script/download.php#windows
    echo.
    echo 📝 Manual alternative:
    echo    1. Open assets/icons/Icon.png in an image editor
    echo    2. Resize canvas to 1024x1024
    echo    3. Make your logo ~65%% smaller and center it
    echo    4. Save as assets/icons/Icon-adaptive.png
    exit /b 1
)

REM Check if source icon exists
if not exist "assets\icons\Icon.png" (
    echo ❌ Source icon not found: assets\icons\Icon.png
    exit /b 1
)

echo ✅ Found source icon: assets\icons\Icon.png

REM Create adaptive icon with proper padding
echo 🎨 Creating adaptive icon with proper padding...

magick assets\icons\Icon.png -resize 65%% -background transparent -gravity center -extent 1024x1024 assets\icons\Icon-adaptive.png

if %errorlevel% equ 0 (
    echo ✅ Created: assets\icons\Icon-adaptive.png
    echo.
    echo 📋 Next steps:
    echo    1. Update pubspec.yaml:
    echo       adaptive_icon_foreground: "assets/icons/Icon-adaptive.png"
    echo    2. Run: flutter packages get
    echo    3. Run: flutter packages pub run flutter_launcher_icons:main
    echo    4. Rebuild APK: flutter build apk --release
    echo.
    echo 🎯 This should fix the zoomed-in Android icon issue!
) else (
    echo ❌ Failed to create adaptive icon
    echo 📝 Please create it manually as described above
)

pause
