#!/bin/bash

# DIU Route Explorer - Deployment Status Checker
# This script helps monitor the deployment status

echo "🚀 DIU Route Explorer Deployment Status"
echo "======================================="
echo ""

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "📍 Current branch: $CURRENT_BRANCH"

# Get last commit info
LAST_COMMIT=$(git log -1 --pretty=format:"%h - %s (%an, %ar)")
echo "📝 Last commit: $LAST_COMMIT"

# Check if there are uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️  Warning: You have uncommitted changes"
    git status --short
else
    echo "✅ Working directory is clean"
fi

echo ""
echo "🌐 Live Website: https://diurouteexplorer.web.app"
echo "📊 GitHub Actions: https://github.com/OkayAbedin/diu_route_explorer/actions"
echo "🔥 Firebase Console: https://console.firebase.google.com/project/diurouteexplorer"
echo ""

# Check if main branch (deployment trigger)
if [ "$CURRENT_BRANCH" = "main" ]; then
    echo "✅ On main branch - pushes will trigger automatic deployment"
else
    echo "ℹ️  On '$CURRENT_BRANCH' branch - switch to 'main' to trigger deployment"
fi

echo ""
echo "Quick Commands:"
echo "  Deploy manually: firebase deploy --only hosting"
echo "  Build for web:   flutter build web --release"
echo "  Test locally:    flutter run -d chrome"
