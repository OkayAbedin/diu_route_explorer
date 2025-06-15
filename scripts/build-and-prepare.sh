#!/bin/bash

echo "🚀 Building DIU Route Explorer for deployment..."

# Build Flutter web app
echo "📱 Building Flutter web app..."
flutter build web --release

# Build APKs with architecture splits
echo "📦 Building APKs for different architectures..."
flutter build apk --split-per-abi

# Copy download page and APKs to build directory
echo "📄 Copying download page..."
cp web/download.html build/web/

echo "📱 Copying APK files..."
cp -r web/apks build/web/

echo "✅ Build complete! Ready for Firebase deployment."
echo ""
echo "To deploy to Firebase hosting, run:"
echo "firebase deploy --only hosting"
echo ""
echo "Your download page will be available at:"
echo "https://diurouteexplorer.web.app/download"
