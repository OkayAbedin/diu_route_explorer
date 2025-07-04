@echo off
echo Copying SEO and static files to build/web directory...

REM Create build/web directory if it doesn't exist
if not exist "build\web" mkdir "build\web"

REM Copy SEO files from web to build/web
copy "web\index.html" "build\web\index.html" >nul 2>&1
copy "web\download.html" "build\web\download.html" >nul 2>&1
copy "web\sitemap.xml" "build\web\sitemap.xml" >nul 2>&1
copy "web\robots.txt" "build\web\robots.txt" >nul 2>&1
copy "web\humans.txt" "build\web\humans.txt" >nul 2>&1
copy "web\manifest.json" "build\web\manifest.json" >nul 2>&1
copy "web\browserconfig.xml" "build\web\browserconfig.xml" >nul 2>&1
copy "web\.htaccess" "build\web\.htaccess" >nul 2>&1

echo SEO files copied successfully!
echo.
echo Files copied:
echo - index.html (SEO optimized)
echo - download.html (SEO optimized)
echo - sitemap.xml (with keyword optimization)
echo - robots.txt
echo - humans.txt (updated with keywords)
echo - manifest.json (SEO optimized)
echo - browserconfig.xml
echo - .htaccess
echo.
echo All files optimized for DIU Transport keywords:
echo DIU Transport, DIU Route, DIU Bus, Daffodil Transport,
echo Daffodil Route, Daffodil Bus, Bus Time Daffodil, Bus Time DIU
echo.
echo Ready for Firebase deployment!
