# Flutter Build Cleanup Script
# This script fixes permission issues with build directories

Write-Host "🧹 Cleaning Flutter build directories..." -ForegroundColor Cyan

# Stop any running Flutter/Dart processes
Write-Host "`n📋 Checking for running Flutter processes..." -ForegroundColor Yellow
$processes = Get-Process -ErrorAction SilentlyContinue | Where-Object {
    $_.ProcessName -like "*flutter*" -or 
    $_.ProcessName -like "*dart*" -or
    ($_.ProcessName -like "*chrome*" -and $_.MainWindowTitle -like "*flutter*")
}

if ($processes) {
    Write-Host "⚠️  Found running processes. Stopping them..." -ForegroundColor Yellow
    foreach ($proc in $processes) {
        try {
            Stop-Process -Id $proc.Id -Force -ErrorAction Stop
            Write-Host "   ✓ Stopped: $($proc.ProcessName) (PID: $($proc.Id))" -ForegroundColor Green
        } catch {
            Write-Host "   ✗ Could not stop: $($proc.ProcessName)" -ForegroundColor Red
        }
    }
    Start-Sleep -Seconds 2
} else {
    Write-Host "   ✓ No Flutter processes running" -ForegroundColor Green
}

# Clean build directories
Write-Host "`n🗑️  Removing build directories..." -ForegroundColor Yellow

$directories = @(
    "build",
    ".dart_tool\build",
    "build\flutter_assets"
)

foreach ($dir in $directories) {
    if (Test-Path $dir) {
        try {
            # Take ownership and set permissions
            $acl = Get-Acl $dir -ErrorAction Stop
            $permission = "BUILTIN\Users", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
            $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
            $acl.SetAccessRule($accessRule)
            Set-Acl $dir $acl -ErrorAction Stop
            
            # Remove directory
            Remove-Item -Path $dir -Recurse -Force -ErrorAction Stop
            Write-Host "   ✓ Removed: $dir" -ForegroundColor Green
        } catch {
            Write-Host "   ✗ Could not remove: $dir - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Run Flutter clean
Write-Host "`n🧹 Running Flutter clean..." -ForegroundColor Yellow
try {
    flutter clean 2>&1 | Out-Null
    Write-Host "   ✓ Flutter clean completed" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Flutter clean failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Fix permissions on build directory (create if doesn't exist)
Write-Host "`n🔧 Setting up build directory permissions..." -ForegroundColor Yellow
if (-not (Test-Path "build")) {
    New-Item -ItemType Directory -Path "build" -Force | Out-Null
}

$buildDir = Get-Item "build" -ErrorAction SilentlyContinue
if ($buildDir) {
    try {
        $acl = Get-Acl $buildDir.FullName
        $permission = "$env:USERNAME", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
        $acl.SetAccessRule($accessRule)
        Set-Acl $buildDir.FullName $acl
        Write-Host "   ✓ Build directory permissions set" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠️  Could not set permissions: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Host "`n✅ Cleanup complete!" -ForegroundColor Green
Write-Host "`n💡 Tip: Run this script before building if you encounter permission errors." -ForegroundColor Cyan
