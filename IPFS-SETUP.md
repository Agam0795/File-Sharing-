# IPFS Installation Guide for DecentraShare

## Quick Install (Windows)

### Option 1: Using Chocolatey (Recommended)

If you have Chocolatey installed:

```powershell
choco install ipfs
```

### Option 2: Manual Installation

1. **Download IPFS (Kubo)**
   - Go to: https://dist.ipfs.tech/#kubo
   - Download the Windows version (e.g., `kubo_v0.x.x_windows-amd64.zip`)

2. **Extract and Install**
   ```powershell
   # Extract the downloaded zip file
   # Move ipfs.exe to a location, for example:
   # C:\Program Files\ipfs\ipfs.exe
   
   # Add to PATH
   # Open System Properties > Environment Variables
   # Add the folder containing ipfs.exe to your PATH
   ```

3. **Verify Installation**
   ```powershell
   ipfs version
   ```

### Option 3: Using Winget (Windows 11)

```powershell
winget install ipfs.kubo
```

## Setup IPFS

### First Time Setup

1. **Initialize IPFS** (only needed once):
   ```powershell
   ipfs init
   ```

   You should see output like:
   ```
   generating ED25519 keypair...done
   peer identity: Qm...
   ```

2. **Configure IPFS (Optional - for better performance)**:
   ```powershell
   # Increase storage limit (default is 10GB)
   ipfs config Datastore.StorageMax 20GB
   
   # Enable automatic garbage collection
   ipfs config --json Datastore.GCPeriod '"1h"'
   ```

### Start IPFS Daemon

**Every time you want to use DecentraShare, you need to start the IPFS daemon:**

```powershell
ipfs daemon
```

You should see output like:
```
Initializing daemon...
go-ipfs version: 0.x.x
Repo version: ...
API server listening on /ip4/127.0.0.1/tcp/5001
WebUI: http://127.0.0.1:5001/webui
Gateway server listening on /ip4/127.0.0.1/tcp/8080
Daemon is ready
```

**Important:** Keep this terminal window open! The daemon must run while using DecentraShare.

### Verify IPFS is Running

In a **new terminal**, run:

```powershell
# Check IPFS status
ipfs id

# Or test the API
Invoke-RestMethod -Uri http://127.0.0.1:5001/api/v0/id -Method Post
```

## Using IPFS with DecentraShare

### Complete Startup Sequence

Open **3 separate PowerShell terminals**:

**Terminal 1 - IPFS Daemon:**
```powershell
ipfs daemon
```

**Terminal 2 - Backend Server:**
```powershell
cd C:\Users\agam1\Desktop\filesharing\backend
C:\Users\agam1\Desktop\filesharing\backend\venv\Scripts\python.exe main.py
```

**Terminal 3 - Frontend Server:**
```powershell
cd C:\Users\agam1\Desktop\filesharing\frontend
npm run dev
```

### Verify Everything is Working

1. **Check IPFS**: http://127.0.0.1:5001/webui (IPFS Web UI)
2. **Check Backend**: http://localhost:8000/health (should show `"ipfs_connected": true`)
3. **Check Frontend**: http://localhost:5174 (health indicator should be green)

## Troubleshooting IPFS

### "Error: lock /Users/.../.ipfs/repo.lock: someone else has the lock"

**Solution:** IPFS daemon is already running. Either:
- Use the existing daemon
- Stop it first: `ipfs shutdown`

### "Error: api not running"

**Solution:** Start the daemon:
```powershell
ipfs daemon
```

### Port 5001 Already in Use

**Solution:** Kill the process using port 5001:
```powershell
Get-NetTCPConnection -LocalPort 5001 | Select-Object -ExpandProperty OwningProcess | ForEach-Object { Stop-Process -Id $_ -Force }
```

Then restart the daemon.

### "Error: cannot acquire lock"

**Solution:** The IPFS repository is locked by another process:
```powershell
# Find and kill IPFS processes
Get-Process ipfs -ErrorAction SilentlyContinue | Stop-Process -Force

# Or remove the lock file (use with caution!)
Remove-Item -Path "$env:USERPROFILE\.ipfs\repo.lock" -Force
```

### Cannot Connect to IPFS from Backend

**Solution:** Verify IPFS API is accessible:
```powershell
# This should return IPFS node info
Invoke-RestMethod -Uri http://127.0.0.1:5001/api/v0/id -Method Post
```

If this fails, restart IPFS daemon.

## IPFS Configuration for DecentraShare

The backend expects IPFS API at: `http://127.0.0.1:5001/api/v0`

If you need to change this, edit `backend/.env` or `backend/main.py`:

```python
IPFS_API_URL = os.getenv("IPFS_API_URL", "http://127.0.0.1:5001/api/v0")
```

## IPFS Commands Reference

```powershell
# Initialize IPFS repository
ipfs init

# Start IPFS daemon
ipfs daemon

# Stop IPFS daemon
ipfs shutdown

# Check IPFS version
ipfs version

# View node identity
ipfs id

# View connected peers
ipfs swarm peers

# View repository stats
ipfs repo stat

# Clean up unused data
ipfs repo gc

# Add a file manually
ipfs add myfile.txt

# Retrieve a file manually
ipfs cat <CID>

# Pin a file (keep it permanently)
ipfs pin add <CID>

# List pinned files
ipfs pin ls
```

## Quick Start Script

Save this as `start-ipfs.ps1`:

```powershell
Write-Host "Starting IPFS Daemon..." -ForegroundColor Green
Write-Host "Keep this window open while using DecentraShare" -ForegroundColor Yellow
Write-Host ""

# Check if IPFS is installed
if (-not (Get-Command ipfs -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: IPFS not found!" -ForegroundColor Red
    Write-Host "Install with: choco install ipfs" -ForegroundColor Yellow
    Write-Host "Or download from: https://dist.ipfs.tech/#kubo" -ForegroundColor Yellow
    exit 1
}

# Check if initialized
if (-not (Test-Path "$env:USERPROFILE\.ipfs")) {
    Write-Host "Initializing IPFS..." -ForegroundColor Yellow
    ipfs init
}

# Start daemon
ipfs daemon
```

Run it with:
```powershell
powershell -ExecutionPolicy Bypass -File .\start-ipfs.ps1
```

## After Installing IPFS

1. Initialize IPFS: `ipfs init`
2. Start daemon: `ipfs daemon`
3. Restart backend: It should now connect to IPFS
4. Check health status: http://localhost:8000/health
5. Try uploading a file in DecentraShare!

## Links

- IPFS Documentation: https://docs.ipfs.tech/
- IPFS Desktop (GUI alternative): https://docs.ipfs.tech/install/ipfs-desktop/
- Kubo Downloads: https://dist.ipfs.tech/#kubo
