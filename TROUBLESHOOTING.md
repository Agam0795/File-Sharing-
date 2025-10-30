# DecentraShare - Troubleshooting Guide

## "Failed to fetch" Error

This error occurs when the frontend cannot connect to the backend API. Here are the solutions:

### Quick Fix

1. **Verify both servers are running:**
   - Backend: http://localhost:8000 (check with browser or `Invoke-WebRequest http://localhost:8000/health`)
   - Frontend: http://localhost:5173 or http://localhost:5174

2. **Restart backend with CORS fix:**
   ```powershell
   # Navigate to backend directory
   cd C:\Users\agam1\Desktop\filesharing\backend
   
   # Stop any running backend (press Ctrl+C in the terminal, or use Task Manager to kill python.exe)
   
   # Start backend
   .\venv\Scripts\python.exe main.py
   ```

3. **The backend now supports these frontend URLs:**
   - http://localhost:5173
   - http://localhost:5174
   - http://localhost:3000

### Common Issues

#### Port Already in Use

**Backend (port 8000):**
```powershell
# Find and stop the process using port 8000
Get-NetTCPConnection -LocalPort 8000 | Select-Object -ExpandProperty OwningProcess | ForEach-Object { Stop-Process -Id $_ -Force }
```

**Frontend (port 5173):**
- Vite will automatically use the next available port (5174, 5175, etc.)
- Update the CORS in `backend/main.py` if needed

#### CORS Issues

If you see CORS errors in the browser console:

1. Open `backend/main.py`
2. Find the `CORSMiddleware` section
3. Add your frontend URL to the `allow_origins` list:
   ```python
   allow_origins=[
       "http://localhost:5173",
       "http://localhost:5174",
       "http://localhost:YOUR_PORT"
   ]
   ```
4. Restart the backend

#### IPFS Not Connected

**Error:** "IPFS Not Connected" or "All connection attempts failed"

**Solution:**
1. Install IPFS if not already installed:
   ```powershell
   choco install ipfs
   ```

2. Initialize IPFS (first time only):
   ```powershell
   ipfs init
   ```

3. Start IPFS daemon:
   ```powershell
   ipfs daemon
   ```

4. Keep the IPFS daemon running in a separate terminal

5. Refresh the DecentraShare page - status should turn green

#### Module Import Errors

**Error:** `ModuleNotFoundError: No module named 'fastapi'`

**Solution:**
```powershell
cd C:\Users\agam1\Desktop\filesharing\backend
.\venv\Scripts\pip.exe install -r requirements.txt
```

#### Python Version Issues

**Error:** Compilation errors for `pydantic-core`

**Solution:** The `requirements.txt` has been updated to use flexible versions (`>=`) that work with Python 3.13. Just run:
```powershell
.\venv\Scripts\pip.exe install -r requirements.txt
```

## Testing the Application

### 1. Check Backend Health
```powershell
Invoke-WebRequest -Uri http://localhost:8000/health -UseBasicParsing
```

Expected response:
```json
{
  "status": "healthy",
  "ipfs_connected": true,
  "ipfs_id": "Qm...",
  "ipfs_agent": "kubo/..."
}
```

### 2. Test Upload (via browser)

1. Open http://localhost:5174 (or your frontend port)
2. Go to "Upload File" tab
3. Select a small test file
4. Click "Encrypt & Upload to IPFS"
5. Should see success message with CID, key, and IV

### 3. Test Download

1. Copy the CID, key, and IV from upload
2. Go to "Download File" tab
3. Paste the values
4. Click "Download & Decrypt"
5. File should download successfully

## Server Start Commands

### Option 1: Manual Start (Recommended for troubleshooting)

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

### Option 2: Using PowerShell Scripts

**Backend:**
```powershell
cd C:\Users\agam1\Desktop\filesharing\backend
powershell -ExecutionPolicy Bypass -File .\start-backend.ps1
```

**Frontend:**
```powershell
cd C:\Users\agam1\Desktop\filesharing\frontend
powershell -ExecutionPolicy Bypass -File .\start-frontend.ps1
```

## Browser Console Errors

### "Failed to fetch"
- Backend not running → Start backend
- CORS issue → Restart backend with updated CORS
- Wrong URL → Check API_BASE_URL in `frontend/src/api.ts`

### "NetworkError" or "ERR_CONNECTION_REFUSED"
- Backend not running on port 8000
- Firewall blocking the connection

### "CORS policy" errors
- Frontend port not in backend's `allow_origins`
- Restart backend after adding the port

## Still Having Issues?

1. Check all three servers are running:
   - IPFS daemon
   - Backend (port 8000)
   - Frontend (port 5173/5174)

2. Clear browser cache and reload

3. Check browser console (F12) for detailed error messages

4. Verify network requests in browser DevTools → Network tab

5. Check backend logs in the terminal for errors

## Quick Health Check

Run this in PowerShell to verify everything:

```powershell
# Check backend
$backend = Invoke-WebRequest -Uri http://localhost:8000/health -UseBasicParsing
Write-Host "Backend Status:" $backend.StatusCode
$backend.Content | ConvertFrom-Json | Format-List

# Check IPFS
$ipfs = Invoke-RestMethod -Uri http://127.0.0.1:5001/api/v0/id -Method Post
Write-Host "IPFS ID:" $ipfs.ID
```

If both commands work, your system is healthy! 🎉
