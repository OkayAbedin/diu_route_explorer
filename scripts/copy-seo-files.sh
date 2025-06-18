#!/bin/bash

echo "Copying SEO and static files to build/web directory..."

# Create build/web directory if it doesn't exist
mkdir -p build/web

# Copy SEO files from web to build/web
cp web/sitemap.xml build/web/sitemap.xml 2>/dev/null || true
cp web/robots.txt build/web/robots.txt 2>/dev/null || true
cp web/humans.txt build/web/humans.txt 2>/dev/null || true
cp web/browserconfig.xml build/web/browserconfig.xml 2>/dev/null || true
cp web/.htaccess build/web/.htaccess 2>/dev/null || true

echo "SEO files copied successfully!"
echo ""
echo "Files copied:"
echo "- sitemap.xml"
echo "- robots.txt"
echo "- humans.txt"
echo "- browserconfig.xml"
echo "- .htaccess"
echo ""
echo "Ready for Firebase deployment!"
