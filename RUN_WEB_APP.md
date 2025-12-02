# 🚀 How to Run Flutter Web App in Chrome/Edge

## Quick Start

### Method 1: Using VS Code (Recommended)
1. Press `F5` or click the "Run and Debug" button
2. Select one of these configurations:
   - **"Flutter: Run on Chrome"** - Opens in Chrome
   - **"Flutter: Run on Edge"** - Opens in Edge
   - **"Flutter: Run on Windows"** - Runs as Windows desktop app

### Method 2: Using Terminal/Command Line

#### Run in Chrome:
```powershell
flutter run -d chrome
```

#### Run in Edge:
```powershell
flutter run -d edge
```

#### Run on specific port (8080):
```powershell
flutter run -d chrome --web-port=8080
```

#### Run in release mode:
```powershell
flutter run -d chrome --release
```

## Troubleshooting

### Error: "This site can't be reached" or "ERR_CONNECTION_REFUSED"

**Solution:** The Flutter web server isn't running. You need to start it first:

1. **Make sure Flutter web is enabled:**
   ```powershell
   flutter config --enable-web
   ```

2. **Run the app:**
   ```powershell
   flutter run -d chrome
   ```

3. **Wait for the build to complete** - You'll see output like:
   ```
   Launching lib\main.dart on Chrome in debug mode...
   Building web application...
   ```

4. **The browser will open automatically** when ready

### Port Already in Use

If port 8080 is already in use, Flutter will automatically use a different port (usually 50000+). Check the terminal output for the actual URL.

### Build Errors

If you see build errors:
```powershell
# Clean and rebuild
.\fix_build.ps1
flutter pub get
flutter run -d chrome
```

## Default Ports

- **Flutter Web (default):** Usually `localhost:50000+` (random port)
- **Custom port:** Use `--web-port=8080` flag
- **VS Code:** Automatically handles port selection

## Hot Reload

Once the app is running:
- Press `r` in the terminal to hot reload
- Press `R` to hot restart
- Press `q` to quit

## Accessing the App

After running `flutter run -d chrome`, the app will:
1. Build the web application
2. Start a local web server
3. Automatically open your browser
4. Display the app at the URL shown in the terminal

**Note:** Don't try to access `localhost:8080` manually - Flutter will open the correct URL automatically!

