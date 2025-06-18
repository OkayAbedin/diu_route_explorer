# DIU Route Explorer - Deployment Instructions

## Quick Deployment Steps

### Option 1: Use the automated build script
```bash
# Windows
scripts\build-and-deploy.bat

# Linux/Mac
scripts/build-and-deploy.sh
```

### Option 2: Manual deployment
1. **Build the Flutter app:**
   ```bash
   flutter build web --release
   ```

2. **Copy SEO files:**
   ```bash
   # Windows
   scripts\copy-seo-files.bat
   
   # Linux/Mac
   scripts/copy-seo-files.sh
   ```

3. **Deploy to Firebase:**
   ```bash
   firebase deploy --only hosting
   ```

## SEO Files Included
- `sitemap.xml` - Search engine sitemap
- `robots.txt` - Search engine crawling instructions
- `humans.txt` - Team credits
- `browserconfig.xml` - Microsoft tile configuration
- `.htaccess` - Security and performance headers

## Verification
After deployment, verify these URLs work:
- https://diurouteexplorer.web.app/sitemap.xml
- https://diurouteexplorer.web.app/robots.txt
- https://diurouteexplorer.web.app/humans.txt
- https://diurouteexplorer.web.app/browserconfig.xml

## Notes
- Always run the build script or copy SEO files before deploying
- The Firebase hosting serves from `build/web` directory
- SEO files must be copied from `web/` to `build/web/` before each deployment
