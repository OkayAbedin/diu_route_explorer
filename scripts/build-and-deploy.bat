@echo off
echo Starting Flutter Web Build and Deploy Process...
echo.

REM Build Flutter web app
echo [1/4] Building Flutter web app...
flutter build web --release
if %errorlevel% neq 0 (
    echo Error: Flutter build failed!
    exit /b %errorlevel%
)
echo Flutter build completed successfully!
echo.

REM Copy SEO files
echo [2/4] Copying SEO and static files...
call scripts\copy-seo-files.bat
echo.

REM Optional: Run Firebase deployment
echo [3/4] Would you like to deploy to Firebase now? (y/n)
set /p deploy_choice=Enter choice: 
if /i "%deploy_choice%"=="y" (
    echo Deploying to Firebase...
    firebase deploy --only hosting
    if %errorlevel% neq 0 (
        echo Error: Firebase deployment failed!
        exit /b %errorlevel%
    )
    echo Deployment completed successfully!
) else (
    echo Skipping Firebase deployment.
    echo You can deploy later using: firebase deploy --only hosting
)
echo.

echo [4/4] Build and preparation completed!
echo Your web app is ready with all SEO optimizations!
echo.
pause
