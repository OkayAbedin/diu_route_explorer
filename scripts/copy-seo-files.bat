@echo off
echo Copying SEO and static files to build/web directory...

REM Create build/web directory if it doesn't exist
if not exist "build\web" mkdir "build\web"

REM Copy SEO files from web to build/web
copy "web\sitemap.xml" "build\web\sitemap.xml" >nul 2>&1
copy "web\robots.txt" "build\web\robots.txt" >nul 2>&1
copy "web\humans.txt" "build\web\humans.txt" >nul 2>&1
copy "web\browserconfig.xml" "build\web\browserconfig.xml" >nul 2>&1
copy "web\.htaccess" "build\web\.htaccess" >nul 2>&1

echo SEO files copied successfully!
echo.
echo Files copied:
echo - sitemap.xml
echo - robots.txt
echo - humans.txt
echo - browserconfig.xml
echo - .htaccess
echo.
echo Ready for Firebase deployment!
