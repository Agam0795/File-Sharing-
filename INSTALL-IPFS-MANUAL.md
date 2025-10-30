# Quick IPFS Manual Installation Guide (No Admin Required!)

## Download and Install IPFS Manually

Since Chocolatey requires admin rights, here's how to install IPFS manually:

### Step 1: Download IPFS

1. **Open this link in your browser:**
   https://dist.ipfs.tech/kubo/v0.24.0/kubo_v0.24.0_windows-amd64.zip

2. **Or go to:** https://dist.ipfs.tech/#kubo
   - Click on "kubo"
   - Find "Windows amd64"
   - Download the zip file

### Step 2: Extract and Setup

```powershell
# Create a directory for IPFS
New-Item -ItemType Directory -Path "$env:USERPROFILE\ipfs-bin" -Force

# Download IPFS (you can also download manually from browser)
Invoke-WebRequest -Uri "https://dist.ipfs.tech/kubo/v0.24.0/kubo_v0.24.0_windows-amd64.zip" -OutFile "$env:TEMP\ipfs.zip"

# Extract the zip file
Expand-Archive -Path "$env:TEMP\ipfs.zip" -DestinationPath "$env:TEMP\ipfs-extract" -Force

# Copy ipfs.exe to your bin directory
Copy-Item "$env:TEMP\ipfs-extract\kubo\ipfs.exe" -Destination "$env:USERPROFILE\ipfs-bin\" -Force

# Add to PATH for current session
$env:Path += ";$env:USERPROFILE\ipfs-bin"

# Add to PATH permanently (for future sessions)
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$env:USERPROFILE\ipfs-bin", "User")

Write-Host "✓ IPFS installed to: $env:USERPROFILE\ipfs-bin\ipfs.exe" -ForegroundColor Green
```

### Step 3: Verify Installation

Close and reopen PowerShell, then run:
```powershell
ipfs version
```

You should see: `ipfs version 0.24.0` (or similar)

### Step 4: Initialize IPFS

```powershell
ipfs init
```

You should see output like:
```
generating ED25519 keypair...done
peer identity: Qm...
```

### Step 5: Start IPFS Daemon

```powershell
ipfs daemon
```

Keep this terminal open! You should see:
```
Daemon is ready
API server listening on /ip4/127.0.0.1/tcp/5001
```

---

## All-in-One Installation Script

Save this as a file or run it directly in PowerShell:

```powershell
# IPFS Quick Install Script (No Admin Required)
Write-Host "Installing IPFS..." -ForegroundColor Cyan

# Create directory
$ipfsDir = "$env:USERPROFILE\ipfs-bin"
New-Item -ItemType Directory -Path $ipfsDir -Force | Out-Null

# Download IPFS
Write-Host "Downloading IPFS..." -ForegroundColor Yellow
$url = "https://dist.ipfs.tech/kubo/v0.24.0/kubo_v0.24.0_windows-amd64.zip"
$zipFile = "$env:TEMP\ipfs.zip"
Invoke-WebRequest -Uri $url -OutFile $zipFile

# Extract
Write-Host "Extracting..." -ForegroundColor Yellow
$extractDir = "$env:TEMP\ipfs-extract"
Expand-Archive -Path $zipFile -DestinationPath $extractDir -Force

# Copy executable
Copy-Item "$extractDir\kubo\ipfs.exe" -Destination $ipfsDir -Force

# Add to PATH
Write-Host "Adding to PATH..." -ForegroundColor Yellow
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$ipfsDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$ipfsDir", "User")
    $env:Path += ";$ipfsDir"
}

# Clean up
Remove-Item $zipFile -Force
Remove-Item $extractDir -Recurse -Force

Write-Host "✓ IPFS installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Close and reopen PowerShell" -ForegroundColor White
Write-Host "2. Run: ipfs init" -ForegroundColor White
Write-Host "3. Run: ipfs daemon" -ForegroundColor White
Write-Host ""
Write-Host "IPFS installed at: $ipfsDir\ipfs.exe" -ForegroundColor Gray
```

---

## After Installation - Start IPFS

Once installed, you need to start IPFS every time:

```powershell
# In a new PowerShell window
ipfs daemon
```

Keep that window open while using DecentraShare!

---

## Verify Everything Works

1. **Check IPFS is running:**
   ```powershell
   ipfs id
   ```

2. **Check backend can connect:**
   ```powershell
   Invoke-RestMethod -Uri http://localhost:8000/health
   ```
   
   Should show: `ipfs_connected: True`

3. **Try uploading a file in DecentraShare!**

---

## Troubleshooting

### "ipfs: command not found"

- Close and reopen PowerShell
- Or manually add to PATH:
  ```powershell
  $env:Path += ";$env:USERPROFILE\ipfs-bin"
  ```

### "Error: lock ... already exists"

IPFS daemon is already running somewhere. Either use that one, or:
```powershell
ipfs shutdown
```

Then start again: `ipfs daemon`
