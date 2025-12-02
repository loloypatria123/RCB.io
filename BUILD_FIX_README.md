# Fix Flutter Build Directory Permission Issues

## Problem
If you see this error:
```
Flutter failed to delete a directory at "build\flutter_assets". 
The flutter tool cannot access the file or directory.
```

## Quick Fix

Run this command in PowerShell:
```powershell
.\fix_build.ps1
```

Or manually:
```powershell
# Stop Dart processes
Get-Process -Name "dart" -ErrorAction SilentlyContinue | Stop-Process -Force

# Remove build directory
Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue

# Clean Flutter
flutter clean
```

## Prevention

The `fix_build.ps1` script will:
1. ✅ Stop any running Dart/Flutter processes
2. ✅ Remove the build directory
3. ✅ Run `flutter clean`

## VS Code Integration

You can run the fix from VS Code:
1. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
2. Type "Tasks: Run Task"
3. Select "Fix Build Directory"

## Why This Happens

This issue occurs when:
- Flutter/Dart processes are still running and locking files
- Windows file permissions prevent deletion
- OneDrive sync is interfering with file access

## Permanent Solution

The build directory is already in `.gitignore`, so it won't be tracked. The `fix_build.ps1` script handles cleanup automatically.

If the issue persists:
1. Close all VS Code windows
2. Close all Chrome windows (especially DevTools)
3. Run `.\fix_build.ps1`
4. Restart VS Code

