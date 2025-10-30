# 🚀 DecentraShare - Complete Startup Guide

This guide will walk you through starting DecentraShare from scratch.

## Prerequisites Check

Before starting, ensure you have:
- ✅ Python 3.11+ installed
- ✅ Node.js 18+ installed
- ✅ IPFS (Kubo) installed

## Step-by-Step Startup

### Step 1: Start IPFS Daemon (Required!)

IPFS must be running before starting the backend.

**Option A - Use the helper script:**
```powershell
cd C:\Users\agam1\Desktop\filesharing
powershell -ExecutionPolicy Bypass -File .\start-ipfs.ps1
```

**Option B - Start manually:**
```powershell
# First time only
ipfs init

# Every time
ipfs daemon
```

**What to look for:**
```
Daemon is ready
API server listening on /ip4/127.0.0.1/tcp/5001
```

✅ **Keep this terminal open!** Don't close it while using DecentraShare.

---

### Step 2: Start Backend Server

Open a **new terminal** (keep IPFS terminal open):

```powershell
cd C:\Users\agam1\Desktop\filesharing\backend
C:\Users\agam1\Desktop\filesharing\backend\venv\Scripts\python.exe main.py
```

**What to look for:**
```
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
```

**Verify backend is working:**
- Open browser: http://localhost:8000/health
- Should see: `"ipfs_connected": true` ✅

✅ **Keep this terminal open!**

---

### Step 3: Start Frontend Server

Open a **new terminal** (keep the other two open):

```powershell
cd C:\Users\agam1\Desktop\filesharing\frontend
npm run dev
```

**What to look for:**
```
VITE v5.x.x ready in xxx ms
Local:   http://localhost:5173/
```

✅ **Keep this terminal open!**

---

### Step 4: Access DecentraShare

Open your browser and go to:
```
http://localhost:5173
```
(or http://localhost:5174 if 5173 was in use)

**You should see:**
- 🟢 Green status indicator saying "All Systems Operational"
- Upload and Download tabs
- Health status showing IPFS connected

---

## Quick Test

### Test File Upload:

1. Click **"Upload File"** tab
2. Click **"Choose File"** and select any small file (e.g., a text file)
3. Click **"Encrypt & Upload to IPFS"**
4. Wait for encryption and upload (may take a few seconds)
5. You should see:
   - ✅ Success message
   - IPFS CID (like `QmXxxx...`)
   - Encryption key (Base64 string)
   - IV (hex string)
   - Shareable link

### Test File Download:

1. Copy the CID, key, and IV from the upload
2. Click **"Download File"** tab
3. Paste each value into the corresponding field
4. Click **"Download & Decrypt"**
5. Your file should download! 🎉

---

## Troubleshooting

### "All connection attempts failed" Error

**Problem:** Backend can't connect to IPFS

**Solution:**
1. Check if IPFS daemon is running (look for terminal with IPFS output)
2. If not running, start it: `ipfs daemon`
3. Restart the backend server
4. Check http://localhost:8000/health - should show `"ipfs_connected": true`

### "Failed to fetch" Error

**Problem:** Frontend can't connect to backend

**Solutions:**
1. Verify backend is running on port 8000
2. Check browser console (F12) for specific error
3. Make sure you're accessing the correct frontend URL
4. Try refreshing the page (Ctrl+F5)

### "IPFS Not Connected" Red Indicator

**Problem:** Health check shows IPFS not connected

**Solution:**
1. Start IPFS daemon: `ipfs daemon`
2. Refresh the page
3. Should turn green ✅

### Port Already in Use

**Backend (port 8000):**
```powershell
Get-NetTCPConnection -LocalPort 8000 | Select-Object -ExpandProperty OwningProcess | ForEach-Object { Stop-Process -Id $_ -Force }
```

**Frontend (port 5173):**
- Vite automatically tries the next port (5174, 5175, etc.)
- Just note which port it uses and access that

**IPFS (port 5001):**
```powershell
ipfs shutdown
# Then restart: ipfs daemon
```

---

## Summary of Terminal Windows

You should have **3 terminal windows** open:

| Terminal | Command | Port | Status |
|----------|---------|------|--------|
| **1. IPFS** | `ipfs daemon` | 5001 | Shows peer connections |
| **2. Backend** | `python.exe main.py` | 8000 | Shows API requests |
| **3. Frontend** | `npm run dev` | 5173/5174 | Shows Vite output |

**To stop:** Press `Ctrl+C` in each terminal window (stop in reverse order: Frontend → Backend → IPFS)

---

## Quick Reference Commands

### Start Everything:

**Terminal 1 - IPFS:**
```powershell
ipfs daemon
```

**Terminal 2 - Backend:**
```powershell
cd C:\Users\agam1\Desktop\filesharing\backend
C:\Users\agam1\Desktop\filesharing\backend\venv\Scripts\python.exe main.py
```

**Terminal 3 - Frontend:**
```powershell
cd C:\Users\agam1\Desktop\filesharing\frontend
npm run dev
```

### Check Status:

```powershell
# Check IPFS
Invoke-RestMethod -Uri http://127.0.0.1:5001/api/v0/id -Method Post

# Check Backend
Invoke-WebRequest -Uri http://localhost:8000/health -UseBasicParsing

# Check Frontend (in browser)
http://localhost:5173
```

---

## Next Steps

Once everything is running:

1. **Upload a file** and save the shareable link
2. **Try downloading** using the link (even in a different browser!)
3. **Share the link** with someone - they can decrypt and download your file
4. **Explore** the IPFS Web UI: http://127.0.0.1:5001/webui

---

## Need More Help?

- **IPFS Installation:** See `IPFS-SETUP.md`
- **Troubleshooting:** See `TROUBLESHOOTING.md`
- **Backend Docs:** See `backend/README.md`
- **Frontend Docs:** See `frontend/README.md`

---

## First Time Setup (One-Time Only)

If this is your first time running DecentraShare:

```powershell
# 1. Install IPFS (choose one method)
choco install ipfs          # OR
winget install ipfs.kubo    # OR download from https://dist.ipfs.tech/#kubo

# 2. Initialize IPFS (only once!)
ipfs init

# 3. Install backend dependencies (already done if you followed setup)
cd backend
python -m venv venv
.\venv\Scripts\pip.exe install -r requirements.txt

# 4. Install frontend dependencies (already done if you followed setup)
cd ..\frontend
npm install

# Now you're ready! Go back to Step 1 above.
```

---

**Happy secure file sharing! 🔒🚀**
