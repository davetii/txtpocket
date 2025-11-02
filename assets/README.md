# Assets Directory

## System Tray Icon

The application requires a system tray icon file:

- **Windows**: `app_icon.ico` (32x32 or 16x16 .ico file)
- **macOS**: `app_icon.png` (PNG file)
- **Linux**: `app_icon.png` (PNG file)

### Creating the Icon

You can create a simple icon using:
- Online tools like https://www.icoconverter.com/ (for .ico files)
- Image editors like GIMP, Photoshop, or Paint.NET
- Command line tools like ImageMagick
- Windows: Use Paint to create a simple 32x32 image and save as BMP, then rename to .ico

**Note**: The app will run without the icon, but the system tray icon may not be visible or may show a default icon until you add the file.

### Quick Icon Creation on Windows:
1. Open Paint
2. Resize canvas to 32x32 pixels (Ctrl+E)
3. Draw a simple design (e.g., letter "T" for TxtPocket)
4. Save as PNG first: `app_icon.png`
5. Use an online converter to convert to .ico: https://convertio.co/png-ico/
6. Place `app_icon.ico` in this folder
7. Rebuild the app

### Example using ImageMagick (if installed):
```bash
# Create a simple colored square as placeholder
magick -size 32x32 xc:#007ACC app_icon.ico
```
