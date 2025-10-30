# Quick Start Script for DecentraShare Backend
# This script stops any running backend and starts a fresh instance

Write-Host "DecentraShare Backend Starter" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to backend directory
$backendPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $backendPath

# Check if virtual environment exists
if (-Not (Test-Path ".\venv\Scripts\python.exe")) {
    Write-Host "ERROR: Virtual environment not found!" -ForegroundColor Red
    Write-Host "Please run: python -m venv venv" -ForegroundColor Yellow
    Write-Host "Then run: .\venv\Scripts\pip.exe install -r requirements.txt" -ForegroundColor Yellow
    exit 1
}

# Try to stop any existing backend on port 8000
Write-Host "Checking for existing backend on port 8000..." -ForegroundColor Yellow
$process = Get-NetTCPConnection -LocalPort 8000 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -ErrorAction SilentlyContinue
if ($process) {
    Write-Host "Found existing process on port 8000 (PID: $process)" -ForegroundColor Yellow
    Write-Host "Stopping it..." -ForegroundColor Yellow
    Stop-Process -Id $process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

# Start the backend server
Write-Host ""
Write-Host "Starting DecentraShare Backend..." -ForegroundColor Green
Write-Host "Backend will be available at: http://localhost:8000" -ForegroundColor Cyan
Write-Host "Press CTRL+C to stop the server" -ForegroundColor Yellow
Write-Host ""

.\venv\Scripts\python.exe main.py
