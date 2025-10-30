# IPFS Quick Start Script for DecentraShare
# This script helps you start IPFS daemon

Write-Host "================================" -ForegroundColor Cyan
Write-Host "IPFS Daemon Starter" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check if IPFS is installed
Write-Host "Checking for IPFS installation..." -ForegroundColor Yellow
$ipfsPath = Get-Command ipfs -ErrorAction SilentlyContinue

if (-not $ipfsPath) {
    Write-Host ""
    Write-Host "ERROR: IPFS is not installed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install IPFS using one of these methods:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Option 1 - Using Chocolatey:" -ForegroundColor Cyan
    Write-Host "  choco install ipfs" -ForegroundColor White
    Write-Host ""
    Write-Host "Option 2 - Using Winget (Windows 11):" -ForegroundColor Cyan
    Write-Host "  winget install ipfs.kubo" -ForegroundColor White
    Write-Host ""
    Write-Host "Option 3 - Manual Download:" -ForegroundColor Cyan
    Write-Host "  Visit: https://dist.ipfs.tech/#kubo" -ForegroundColor White
    Write-Host "  Download, extract, and add to PATH" -ForegroundColor White
    Write-Host ""
    Write-Host "After installation, run this script again." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "✓ IPFS found at: $($ipfsPath.Source)" -ForegroundColor Green
Write-Host ""

# Check if IPFS is initialized
$ipfsRepo = "$env:USERPROFILE\.ipfs"
if (-not (Test-Path $ipfsRepo)) {
    Write-Host "IPFS not initialized. Initializing now..." -ForegroundColor Yellow
    ipfs init
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "ERROR: Failed to initialize IPFS" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
    Write-Host "✓ IPFS initialized successfully!" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "✓ IPFS already initialized" -ForegroundColor Green
    Write-Host ""
}

# Check if daemon is already running
Write-Host "Checking if IPFS daemon is already running..." -ForegroundColor Yellow
$ipfsRunning = Get-NetTCPConnection -LocalPort 5001 -ErrorAction SilentlyContinue

if ($ipfsRunning) {
    Write-Host ""
    Write-Host "✓ IPFS daemon is already running!" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can access:" -ForegroundColor Cyan
    Write-Host "  - IPFS Web UI: http://127.0.0.1:5001/webui" -ForegroundColor White
    Write-Host "  - IPFS Gateway: http://127.0.0.1:8080" -ForegroundColor White
    Write-Host "  - IPFS API: http://127.0.0.1:5001/api/v0" -ForegroundColor White
    Write-Host ""
    Write-Host "Your DecentraShare backend should now be able to connect!" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 0
}

# Start IPFS daemon
Write-Host ""
Write-Host "Starting IPFS Daemon..." -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT: Keep this window open while using DecentraShare!" -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop the daemon when done" -ForegroundColor Yellow
Write-Host ""
Write-Host "After the daemon starts, you'll see:" -ForegroundColor Cyan
Write-Host "  - API server listening on /ip4/127.0.0.1/tcp/5001" -ForegroundColor White
Write-Host "  - Gateway server listening on /ip4/127.0.0.1/tcp/8080" -ForegroundColor White
Write-Host "  - 'Daemon is ready' message" -ForegroundColor White
Write-Host ""
Write-Host "Then you can:" -ForegroundColor Cyan
Write-Host "  1. Start your backend server" -ForegroundColor White
Write-Host "  2. Visit http://localhost:8000/health to verify connection" -ForegroundColor White
Write-Host "  3. Use DecentraShare to upload/download files!" -ForegroundColor White
Write-Host ""
Write-Host "Starting now..." -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray
Write-Host ""

# Start the daemon
ipfs daemon
