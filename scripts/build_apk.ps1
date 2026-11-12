# PowerShell Script: CIRCULUS Android APK Build & Installation
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " CIRCULUS Android APK Build Pipeline     " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

$MobileDir = "C:\Users\Aditya Kumar\Documents\Circulus\mobile"
Set-Location $MobileDir

Write-Host "`n[1/3] Fetching Flutter dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host "`n[2/3] Compiling Debug APK for Android..." -ForegroundColor Yellow
flutter build apk --debug

Write-Host "`n[3/3] Build complete!" -ForegroundColor Green
$ApkPath = "$MobileDir\build\app\outputs\flutter-apk\app-debug.apk"

if (Test-Path $ApkPath) {
    Write-Host "APK Location: $ApkPath" -ForegroundColor Green
    Write-Host "`nTo install on a connected Android phone, run:"
    Write-Host "adb install -r '$ApkPath'" -ForegroundColor Cyan
} else {
    Write-Host "APK compilation completed. Check build output directory." -ForegroundColor Yellow
}
