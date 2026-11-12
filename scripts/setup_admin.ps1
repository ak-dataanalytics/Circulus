# PowerShell Setup Script: CIRCULUS React Admin Dashboard
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " CIRCULUS Admin Dashboard Setup Script   " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

$AdminDir = "C:\Users\Aditya Kumar\Documents\Circulus\admin"
Set-Location $AdminDir

Write-Host "`n[1/2] Installing Node.js packages..." -ForegroundColor Yellow
npm install

Write-Host "`n[2/2] Starting React Admin Dashboard on http://localhost:3000..." -ForegroundColor Green
npm run dev
