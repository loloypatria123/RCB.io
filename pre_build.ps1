# Pre-build script to prevent build directory permission issues
# This runs automatically before Flutter builds

$buildDir = "build\flutter_assets"

if (Test-Path $buildDir) {
    try {
        # Try to remove the directory
        Remove-Item -Path $buildDir -Recurse -Force -ErrorAction Stop
        Write-Host "✓ Cleaned build\flutter_assets" -ForegroundColor Green
    } catch {
        # If removal fails, try to fix permissions
        try {
            $acl = Get-Acl $buildDir
            $permission = "$env:USERNAME", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
            $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
            $acl.SetAccessRule($accessRule)
            Set-Acl $buildDir $acl
            Remove-Item -Path $buildDir -Recurse -Force -ErrorAction Stop
            Write-Host "✓ Fixed permissions and cleaned build\flutter_assets" -ForegroundColor Green
        } catch {
            Write-Host "⚠️  Could not clean build\flutter_assets: $($_.Exception.Message)" -ForegroundColor Yellow
            Write-Host "   Run .\clean_build.ps1 manually to fix this issue." -ForegroundColor Yellow
        }
    }
}

