# PowerShell Setup Script: CIRCULUS FastAPI Backend
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " CIRCULUS Backend Setup & Run Script     " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

$BackendDir = "C:\Users\Aditya Kumar\Documents\Circulus\backend"
Set-Location $BackendDir

Write-Host "`n[1/3] Installing Python dependencies..." -ForegroundColor Yellow
python -m pip install -r requirements.txt

Write-Host "`n[2/3] Running automated unit & security tests..." -ForegroundColor Yellow
python -m pytest tests/

Write-Host "`n[3/3] Starting CIRCULUS FastAPI Backend on http://0.0.0.0:8000..." -ForegroundColor Green
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
