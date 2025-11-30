# Simple script to fix Flutter build directory permission issues
param()

Write-Host "Fixing Flutter build directory..." -ForegroundColor Cyan

# Stop all Flutter/Dart/Chrome processes that might lock files
Write-Host "Stopping processes that might lock files..." -ForegroundColor Yellow
$processes = Get-Process -ErrorAction SilentlyContinue | Where-Object {
    $_.ProcessName -like "*dart*" -or 
    $_.ProcessName -like "*flutter*" -or
    ($_.ProcessName -like "*chrome*" -and $_.MainWindowTitle -like "*flutter*")
}

if ($processes) {
    foreach ($proc in $processes) {
        try {
            Stop-Process -Id $proc.Id -Force -ErrorAction Stop
            Write-Host "  Stopped: $($proc.ProcessName) (PID: $($proc.Id))" -ForegroundColor Green
        } catch {
            Write-Host "  Could not stop: $($proc.ProcessName)" -ForegroundColor Yellow
        }
    }
    Start-Sleep -Seconds 2
} else {
    Write-Host "  No processes to stop" -ForegroundColor Green
}

# Remove build directories with proper handling
Write-Host "Removing build directories..." -ForegroundColor Yellow

$dirs = @(
    "build\flutter_assets", 
    "build",
    "windows\flutter\ephemeral\.plugin_symlinks",
    "windows\flutter\ephemeral",
    "ios\Flutter\ephemeral",
    "macos\Flutter\ephemeral",
    "linux\flutter\ephemeral"
)

foreach ($dir in $dirs) {
    if (Test-Path $dir) {
        try {
            # Unlock files if possible
            $files = Get-ChildItem -Path $dir -Recurse -File -ErrorAction SilentlyContinue
            foreach ($file in $files) {
                try {
                    $file.IsReadOnly = $false
                } catch { }
            }
            
            # Try to remove with retry
            $retries = 5
            $removed = $false
            while ($retries -gt 0 -and -not $removed) {
                try {
                    # Use robocopy trick for stubborn directories (creates empty dir, then removes)
                    if (Test-Path $dir) {
                        $emptyDir = "$dir.empty"
                        if (Test-Path $emptyDir) {
                            Remove-Item -Path $emptyDir -Force -ErrorAction SilentlyContinue
                        }
                        New-Item -ItemType Directory -Path $emptyDir -Force | Out-Null
                        robocopy $emptyDir $dir /MIR /NFL /NDL /NJH /NJS | Out-Null
                        Remove-Item -Path $emptyDir -Force -ErrorAction SilentlyContinue
                        Remove-Item -Path $dir -Recurse -Force -ErrorAction Stop
                    }
                    Write-Host "  Removed: $dir" -ForegroundColor Green
                    $removed = $true
                } catch {
                    $retries--
                    if ($retries -gt 0) {
                        Start-Sleep -Milliseconds 1000
                    }
                }
            }
            if (-not $removed) {
                Write-Host "  Warning: Could not remove: $dir (will try flutter clean)" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "  Error removing: $dir - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Run flutter clean
Write-Host "Running flutter clean..." -ForegroundColor Yellow
flutter clean

Write-Host "Done!" -ForegroundColor Green

