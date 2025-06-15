@echo off
echo Building DIU Route Explorer APK...
echo.

REM Clean previous builds
echo Cleaning previous builds...
flutter clean

REM Get dependencies
echo Getting dependencies...
flutter pub get

REM Build the APK without symlinks
echo Building APK (this may take a few minutes)...
flutter build apk --release --no-tree-shake-icons

echo.
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo ✓ APK built successfully!
    echo Location: build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo You can now install this APK on your Android device.
) else (
    echo ✗ APK build failed. Check the output above for errors.
)

pause
