# Quick Start Script for DecentraShare Frontend
# This script starts the Vite development server

Write-Host "DecentraShare Frontend Starter" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to frontend directory
$frontendPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $frontendPath

# Check if node_modules exists
if (-Not (Test-Path ".\node_modules")) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    npm install
    Write-Host ""
}

# Start the frontend server
Write-Host "Starting DecentraShare Frontend..." -ForegroundColor Green
Write-Host "Frontend will be available at: http://localhost:5173 (or next available port)" -ForegroundColor Cyan
Write-Host "Press CTRL+C to stop the server" -ForegroundColor Yellow
Write-Host ""

npm run dev
