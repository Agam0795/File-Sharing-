# Backend Deployment Guide

Your local version is working! Now let's deploy the backend to make your production site fully functional.

## Option 1: Deploy to Render.com (Recommended - Free Tier Available)

### Step 1: Push to GitHub
1. Create a GitHub account if you don't have one: https://github.com
2. Create a new repository called "decentrashare"
3. Run these commands in PowerShell:

```powershell
cd C:\Users\agam1\Desktop\filesharing
git remote add origin https://github.com/YOUR_USERNAME/decentrashare.git
git branch -M main
git push -u origin main
```

### Step 2: Deploy on Render
1. Go to https://render.com and sign up (free tier available)
2. Click "New +" → "Web Service"
3. Connect your GitHub account and select the `decentrashare` repository
4. Configure:
   - **Name**: decentrashare-backend
   - **Region**: Oregon (US West) or closest to you
   - **Branch**: main
   - **Root Directory**: backend
   - **Runtime**: Python 3
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `uvicorn main:app --host 0.0.0.0 --port $PORT`
5. Add Environment Variable:
   - **Key**: `IPFS_API_URL`
   - **Value**: `https://ipfs.infura.io:5001`
6. Click "Create Web Service"

### Step 3: Wait for Deployment
- Render will build and deploy your backend (takes 3-5 minutes)
- You'll get a URL like: `https://decentrashare-backend.onrender.com`

### Step 4: Update Frontend
Update your Netlify deployment with the backend URL:

```powershell
cd C:\Users\agam1\Desktop\filesharing\frontend
$env:VITE_API_URL="https://decentrashare-backend.onrender.com"
npm run build
cd ..
netlify deploy --prod
```

---

## Option 2: Deploy to Railway.app

### Step 1: Push to GitHub (same as above if not done)

### Step 2: Deploy on Railway
1. Go to https://railway.app and sign up
2. Click "New Project" → "Deploy from GitHub repo"
3. Select your `decentrashare` repository
4. Click "Add variables":
   - `IPFS_API_URL` = `https://ipfs.infura.io:5001`
5. In Settings:
   - **Root Directory**: `/backend`
   - **Start Command**: `uvicorn main:app --host 0.0.0.0 --port $PORT`
6. Deploy!

### Step 3: Get Your URL
- Railway will give you a URL like: `https://decentrashare-backend-production.up.railway.app`

### Step 4: Update Frontend (same as Option 1)

---

## Option 3: Infura IPFS API (For Production)

For production, consider using Infura's managed IPFS:

1. Sign up at https://infura.io
2. Create a new IPFS project
3. Get your Project ID and Secret
4. Update backend environment variable:
   ```
   IPFS_API_URL=https://ipfs.infura.io:5001/api/v0
   INFURA_PROJECT_ID=your_project_id
   INFURA_PROJECT_SECRET=your_project_secret
   ```

---

## Quick Verification

After deployment, test your backend:

```powershell
curl https://YOUR-BACKEND-URL.com/health
```

Should return:
```json
{"status":"healthy","ipfs_connected":true}
```

---

## Current Status

✅ **Frontend**: Deployed at https://fantastic-hummingbird-94cd70.netlify.app  
⏳ **Backend**: Ready to deploy (choose option above)  
⏳ **IPFS**: Will use Infura's public gateway once backend is deployed

Once you deploy the backend and update the frontend, your DecentraShare will be fully functional in production!
