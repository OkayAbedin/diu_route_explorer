@echo off
echo 🚀 Building DIU Route Explorer for deployment...

REM Build Flutter web app
echo 📱 Building Flutter web app...
flutter build web --release

REM Build APKs with architecture splits
echo 📦 Building APKs for different architectures...
flutter build apk --split-per-abi

REM Copy download page and APKs to build directory
echo 📄 Copying download page...
copy web\download.html build\web\

echo 📱 Copying APK files...
xcopy web\apks build\web\apks\ /E /I /Y

echo 🔍 Copying SEO and static files...
call scripts\copy-seo-files.bat

echo ✅ Build complete! Ready for Firebase deployment.
echo.
echo To deploy to Firebase hosting, run:
echo firebase deploy --only hosting
echo.
echo Your download page will be available at:
echo https://diurouteexplorer.web.app/download

pause
