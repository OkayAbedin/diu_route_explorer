@echo off
REM DIU Route Explorer - Deployment Status Checker (Windows)

echo 🚀 DIU Route Explorer Deployment Status
echo =======================================
echo.

REM Check if we're in a git repository
if not exist ".git" (
    echo ❌ Error: Not in a git repository
    pause
    exit /b 1
)

REM Get current branch
for /f "tokens=*" %%i in ('git rev-parse --abbrev-ref HEAD') do set CURRENT_BRANCH=%%i
echo 📍 Current branch: %CURRENT_BRANCH%

REM Get last commit info
for /f "tokens=*" %%i in ('git log -1 --pretty^=format:"%%h - %%s (%%an, %%ar)"') do set LAST_COMMIT=%%i
echo 📝 Last commit: %LAST_COMMIT%

REM Check if there are uncommitted changes
git status --porcelain > temp_status.txt
for %%A in (temp_status.txt) do set size=%%~zA
if %size% gtr 0 (
    echo ⚠️  Warning: You have uncommitted changes
    git status --short
) else (
    echo ✅ Working directory is clean
)
del temp_status.txt

echo.
echo 🌐 Live Website: https://diurouteexplorer.web.app
echo 📊 GitHub Actions: https://github.com/OkayAbedin/diu_route_explorer/actions
echo 🔥 Firebase Console: https://console.firebase.google.com/project/diurouteexplorer
echo.

REM Check if main branch (deployment trigger)
if "%CURRENT_BRANCH%"=="main" (
    echo ✅ On main branch - pushes will trigger automatic deployment
) else (
    echo ℹ️  On '%CURRENT_BRANCH%' branch - switch to 'main' to trigger deployment
)

echo.
echo Quick Commands:
echo   Deploy manually: firebase deploy --only hosting
echo   Build for web:   flutter build web --release
echo   Test locally:    flutter run -d chrome
echo.
pause
