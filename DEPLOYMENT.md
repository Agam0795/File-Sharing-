# DecentraShare Deployment Guide

## ⚠️ Important: DecentraShare Architecture

DecentraShare is a **3-tier application**:
1. **Frontend** (React) - Can be deployed to static hosts
2. **Backend** (FastAPI/Python) - Needs a Python server
3. **IPFS Daemon** - Needs to run as a background service

## Deployment Options

### Option 1: Frontend on Vercel/Netlify + Backend Local (Easiest)

**Best for:** Development, personal use, demos

#### Step 1: Deploy Frontend

**For Netlify:**
```powershell
cd C:\Users\agam1\Desktop\filesharing
netlify deploy --prod
```

**For Vercel:**
```powershell
cd C:\Users\agam1\Desktop\filesharing
vercel --prod
```

The `netlify.toml` and `vercel.json` are now configured to build the frontend correctly.

#### Step 2: Run Backend + IPFS Locally

Keep these running on your machine:

```powershell
# Terminal 1 - IPFS
ipfs daemon

# Terminal 2 - Backend
cd C:\Users\agam1\Desktop\filesharing\backend
C:\Users\agam1\Desktop\filesharing\backend\venv\Scripts\python.exe main.py
```

#### Step 3: Configure CORS for Production

Update `backend/main.py` to allow your deployed frontend URL:

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        "http://localhost:5174",
        "https://your-site.vercel.app",  # Add your Vercel URL
        "https://your-site.netlify.app"  # Add your Netlify URL
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

**Limitation:** Users need to connect to your local backend (requires port forwarding or ngrok).

---

### Option 2: Full Deployment (Recommended for Production)

**For a production deployment, you need:**

#### 1. Frontend → Vercel/Netlify (Static)
- Already done! ✅

#### 2. Backend → Python-capable hosting

**Options:**
- **Render.com** (Free tier available)
- **Railway.app** (Free trial)
- **Fly.io** (Free tier)
- **Heroku** (Paid)
- **DigitalOcean App Platform**
- **AWS/GCP/Azure** (with Docker)

**Example for Render.com:**

1. Create account at render.com
2. Create new "Web Service"
3. Connect your GitHub repo
4. Settings:
   - **Root Directory:** `backend`
   - **Build Command:** `pip install -r requirements.txt`
   - **Start Command:** `uvicorn main:app --host 0.0.0.0 --port $PORT`
   - **Environment:** Python 3

#### 3. IPFS → Hosted IPFS Node

**Options:**
- **Pinata** (https://pinata.cloud) - Managed IPFS
- **Web3.Storage** (https://web3.storage) - Free IPFS storage
- **Infura IPFS** (https://infura.io) - IPFS API
- **Self-hosted** - Run your own IPFS node on a VPS

**Update backend to use hosted IPFS:**
```python
# In backend/main.py
IPFS_API_URL = os.getenv("IPFS_API_URL", "https://ipfs.infura.io:5001/api/v0")
```

---

### Option 3: Deploy Everything with Docker (Advanced)

Create a VPS (DigitalOcean, Linode, etc.) and use Docker Compose:

#### Create `docker-compose.yml` in project root:

```yaml
version: '3.8'

services:
  ipfs:
    image: ipfs/go-ipfs:latest
    ports:
      - "5001:5001"
      - "8080:8080"
    volumes:
      - ipfs-data:/data/ipfs

  backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      - IPFS_API_URL=http://ipfs:5001/api/v0
    depends_on:
      - ipfs

  frontend:
    build: ./frontend
    ports:
      - "80:80"
    environment:
      - VITE_API_URL=http://your-domain.com:8000
    depends_on:
      - backend

volumes:
  ipfs-data:
```

---

## Quick Fix for Your Current Deployment

You deployed to Netlify/Vercel but got "Page not found". Here's how to fix it:

### For Netlify:

```powershell
cd C:\Users\agam1\Desktop\filesharing
netlify deploy --prod
```

When prompted:
- **Publish directory:** `frontend/dist`
- Run `cd frontend && npm run build` first if needed

### For Vercel:

```powershell
cd C:\Users\agam1\Desktop\filesharing\frontend
npm run build
cd ..
vercel --prod
```

---

## Environment Variables

### Frontend `.env` (for production):

Create `frontend/.env.production`:
```
VITE_API_URL=https://your-backend-url.com
```

### Backend `.env`:

Create `backend/.env`:
```
IPFS_API_URL=http://127.0.0.1:5001/api/v0
# Or for hosted IPFS:
# IPFS_API_URL=https://ipfs.infura.io:5001/api/v0
```

---

## Testing Your Deployment

1. **Visit your frontend URL** (Vercel/Netlify)
2. **Check browser console** (F12) for errors
3. **Verify API calls** go to the right backend
4. **Ensure CORS** is configured for your frontend domain

---

## Recommended Quick Start

**For now (testing/demo):**
1. Keep backend + IPFS running locally
2. Deploy only frontend to Vercel/Netlify
3. Use the app from your deployed URL

**For production:**
1. Deploy frontend to Vercel/Netlify
2. Deploy backend to Render/Railway
3. Use Pinata/Web3.Storage for IPFS
4. Update CORS and API URLs

---

## Current Status

✅ **Frontend built:** Ready to deploy  
⚠️ **Backend:** Needs Python hosting (can't run on Vercel/Netlify)  
⚠️ **IPFS:** Needs separate hosting or use managed service  

The "Page not found" error is because Vercel/Netlify deployed the wrong folder. The config files I created will fix this!
