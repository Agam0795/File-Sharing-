# Start all DecentraShare servers
# This script opens separate windows for each server

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DecentraShare - Starting All Services" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$projectRoot = "C:\Users\agam1\Desktop\filesharing"

# Check if IPFS is installed
Write-Host "Checking IPFS installation..." -ForegroundColor Yellow
$ipfsInstalled = Get-Command ipfs -ErrorAction SilentlyContinue

if (-not $ipfsInstalled) {
    Write-Host "⚠️  WARNING: IPFS not installed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "IPFS is required for file storage. Install it with:" -ForegroundColor Yellow
    Write-Host "  choco install ipfs" -ForegroundColor White
    Write-Host "  OR" -ForegroundColor Yellow
    Write-Host "  winget install ipfs.kubo" -ForegroundColor White
    Write-Host ""
    Write-Host "After installing, run: ipfs init" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Continue without IPFS? (y/n)"
    if ($continue -ne "y") {
        exit 1
    }
}

# Start IPFS if installed
if ($ipfsInstalled) {
    Write-Host ""
    Write-Host "Starting IPFS daemon..." -ForegroundColor Green
    
    # Check if IPFS is initialized
    if (-not (Test-Path "$env:USERPROFILE\.ipfs")) {
        Write-Host "  Initializing IPFS (first time only)..." -ForegroundColor Yellow
        ipfs init
    }
    
    # Check if IPFS is already running
    $ipfsRunning = Get-NetTCPConnection -LocalPort 5001 -ErrorAction SilentlyContinue
    if ($ipfsRunning) {
        Write-Host "  ✓ IPFS already running" -ForegroundColor Green
    } else {
        Start-Process powershell -ArgumentList "-NoExit", "-Command", "Write-Host 'IPFS Daemon' -ForegroundColor Cyan; Write-Host 'Keep this window open!' -ForegroundColor Yellow; Write-Host ''; ipfs daemon"
        Write-Host "  ✓ IPFS daemon started in new window" -ForegroundColor Green
        Start-Sleep -Seconds 3
    }
}

# Start Backend
Write-Host ""
Write-Host "Starting Backend server..." -ForegroundColor Green

$backendRunning = Test-NetConnection -ComputerName localhost -Port 8000 -InformationLevel Quiet -WarningAction SilentlyContinue
if ($backendRunning) {
    Write-Host "  ✓ Backend already running on port 8000" -ForegroundColor Green
} else {
    $backendPath = Join-Path $projectRoot "backend"
    $pythonExe = Join-Path $backendPath "venv\Scripts\python.exe"
    $mainPy = Join-Path $backendPath "main.py"
    
    if (-not (Test-Path $pythonExe)) {
        Write-Host "  ⚠️  ERROR: Backend virtual environment not found!" -ForegroundColor Red
        Write-Host "  Run: cd backend; python -m venv venv; .\venv\Scripts\pip.exe install -r requirements.txt" -ForegroundColor Yellow
    } else {
        Start-Process powershell -ArgumentList "-NoExit", "-Command", "Write-Host 'Backend Server' -ForegroundColor Cyan; Write-Host 'Running on http://localhost:8000' -ForegroundColor Green; Write-Host ''; cd '$backendPath'; & '$pythonExe' '$mainPy'"
        Write-Host "  ✓ Backend server started in new window" -ForegroundColor Green
        Start-Sleep -Seconds 3
    }
}

# Start Frontend
Write-Host ""
Write-Host "Starting Frontend server..." -ForegroundColor Green

$frontendPath = Join-Path $projectRoot "frontend"

if (-not (Test-Path (Join-Path $frontendPath "node_modules"))) {
    Write-Host "  ⚠️  WARNING: Frontend dependencies not installed!" -ForegroundColor Red
    Write-Host "  Run: cd frontend; npm install" -ForegroundColor Yellow
    $installNow = Read-Host "Install dependencies now? (y/n)"
    if ($installNow -eq "y") {
        Write-Host "  Installing dependencies..." -ForegroundColor Yellow
        Set-Location $frontendPath
        npm install
        Set-Location $projectRoot
    }
}

Start-Process powershell -ArgumentList "-NoExit", "-Command", "Write-Host 'Frontend Server' -ForegroundColor Cyan; Write-Host 'Will be available at http://localhost:5173' -ForegroundColor Green; Write-Host ''; cd '$frontendPath'; npm run dev"
Write-Host "  ✓ Frontend server started in new window" -ForegroundColor Green

# Wait and show status
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Waiting for servers to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

Write-Host ""
Write-Host "Checking server status..." -ForegroundColor Yellow
Write-Host ""

# Check Backend
Write-Host "Backend (http://localhost:8000):" -ForegroundColor Cyan
try {
    $health = Invoke-RestMethod -Uri "http://localhost:8000/health" -TimeoutSec 2
    if ($health.ipfs_connected) {
        Write-Host "  ✓ Running and connected to IPFS" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Running but IPFS not connected" -ForegroundColor Yellow
        Write-Host "     Make sure IPFS daemon is running" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ✗ Not responding (may still be starting...)" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DecentraShare Started!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Access the application at:" -ForegroundColor Cyan
Write-Host "  http://localhost:5173" -ForegroundColor White
Write-Host "  (or http://localhost:5174 if 5173 is in use)" -ForegroundColor Gray
Write-Host ""
Write-Host "You should see 3 new PowerShell windows:" -ForegroundColor Cyan
Write-Host "  1. IPFS Daemon" -ForegroundColor White
Write-Host "  2. Backend Server (port 8000)" -ForegroundColor White
Write-Host "  3. Frontend Server (port 5173)" -ForegroundColor White
Write-Host ""
Write-Host "Keep all windows open while using DecentraShare!" -ForegroundColor Yellow
Write-Host "Press Ctrl+C in each window to stop the servers" -ForegroundColor Yellow
Write-Host ""
Write-Host "If you see errors, check:" -ForegroundColor Cyan
Write-Host "  - IPFS is installed: ipfs version" -ForegroundColor White
Write-Host "  - Backend health: http://localhost:8000/health" -ForegroundColor White
Write-Host "  - See TROUBLESHOOTING.md for help" -ForegroundColor White
Write-Host ""

Read-Host "Press Enter to close this window"
