#!/bin/bash

echo "Copying SEO and static files to build/web directory..."

# Create build/web directory if it doesn't exist
mkdir -p build/web

# Copy SEO files from web to build/web
cp web/index.html build/web/index.html 2>/dev/null || true
cp web/download.html build/web/download.html 2>/dev/null || true
cp web/sitemap.xml build/web/sitemap.xml 2>/dev/null || true
cp web/robots.txt build/web/robots.txt 2>/dev/null || true
cp web/humans.txt build/web/humans.txt 2>/dev/null || true
cp web/manifest.json build/web/manifest.json 2>/dev/null || true
cp web/browserconfig.xml build/web/browserconfig.xml 2>/dev/null || true
cp web/.htaccess build/web/.htaccess 2>/dev/null || true

echo "SEO files copied successfully!"
echo ""
echo "Files copied:"
echo "- index.html (SEO optimized)"
echo "- download.html (SEO optimized)"
echo "- sitemap.xml (with keyword optimization)"
echo "- robots.txt"
echo "- humans.txt (updated with keywords)"
echo "- manifest.json (SEO optimized)"
echo "- browserconfig.xml"
echo "- .htaccess"
echo ""
echo "All files optimized for DIU Transport keywords:"
echo "DIU Transport, DIU Route, DIU Bus, Daffodil Transport,"
echo "Daffodil Route, Daffodil Bus, Bus Time Daffodil, Bus Time DIU"
echo ""
echo "Ready for Firebase deployment!"
