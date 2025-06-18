#!/bin/bash

echo "Starting Flutter Web Build and Deploy Process..."
echo ""

# Build Flutter web app
echo "[1/4] Building Flutter web app..."
flutter build web --release
if [ $? -ne 0 ]; then
    echo "Error: Flutter build failed!"
    exit 1
fi
echo "Flutter build completed successfully!"
echo ""

# Copy SEO files
echo "[2/4] Copying SEO and static files..."
bash scripts/copy-seo-files.sh
echo ""

# Optional: Run Firebase deployment
echo "[3/4] Would you like to deploy to Firebase now? (y/n)"
read -p "Enter choice: " deploy_choice
if [[ "$deploy_choice" == "y" || "$deploy_choice" == "Y" ]]; then
    echo "Deploying to Firebase..."
    firebase deploy --only hosting
    if [ $? -ne 0 ]; then
        echo "Error: Firebase deployment failed!"
        exit 1
    fi
    echo "Deployment completed successfully!"
else
    echo "Skipping Firebase deployment."
    echo "You can deploy later using: firebase deploy --only hosting"
fi
echo ""

echo "[4/4] Build and preparation completed!"
echo "Your web app is ready with all SEO optimizations!"
echo ""
