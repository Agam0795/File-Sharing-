# 🔒 DecentraShare

**Secure Decentralized File Sharing with End-to-End Encryption**

DecentraShare is a modern web application that combines client-side encryption with IPFS (InterPlanetary File System) storage to create a secure, private, and decentralized file sharing solution.

## ✨ Features

### 🔐 Security First
- **End-to-End Encryption**: Files are encrypted in the browser before upload
- **AES-GCM 256-bit**: Industry-standard authenticated encryption
- **X25519 Key Wrapping**: Secure key exchange for recipients
- **Zero-Knowledge Backend**: Server never sees plaintext data or keys

### 🌐 Decentralized Storage
- **IPFS Integration**: Content-addressable storage
- **No Single Point of Failure**: Distributed across the IPFS network
- **Permanent & Resilient**: Files remain available as long as they're pinned

### 🚀 Modern Stack
- **Backend**: FastAPI (Python) with PyNaCl cryptography
- **Frontend**: React 18 + TypeScript + Vite
- **Crypto**: Web Crypto API for browser-native encryption

## 🏗️ Architecture

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────┐
│                 │         │                  │         │             │
│  React Frontend │◄───────►│  FastAPI Backend │◄───────►│  IPFS Node  │
│  (Encryption)   │         │  (Key Wrapping)  │         │  (Storage)  │
│                 │         │                  │         │             │
└─────────────────┘         └──────────────────┘         └─────────────┘
      Browser                     Server                    Network
    (Plaintext)              (Encrypted Only)           (Encrypted Only)
```

## 📋 Prerequisites

Before you begin, ensure you have installed:

- **Python 3.11+** - [Download](https://www.python.org/downloads/)
- **Node.js 18+** - [Download](https://nodejs.org/)
- **IPFS Kubo** - [Installation Guide](https://docs.ipfs.tech/install/)

## 🚀 Quick Start

### 1. Install and Start IPFS

**Quick Start - Use the provided script:**
```powershell
cd C:\Users\agam1\Desktop\filesharing
powershell -ExecutionPolicy Bypass -File .\start-ipfs.ps1
```

**Or install manually:**

**Option A - Using Chocolatey:**
```powershell
choco install ipfs
ipfs init
ipfs daemon
```

**Option B - Using Winget (Windows 11):**
```powershell
winget install ipfs.kubo
ipfs init
ipfs daemon
```

**Option C - Manual Download:**
- Download from https://dist.ipfs.tech/#kubo
- Extract and add `ipfs.exe` to your PATH
- Run: `ipfs init` then `ipfs daemon`

**⚠️ Important:** Keep the IPFS daemon running in a terminal while using DecentraShare!

The IPFS daemon runs on `http://127.0.0.1:5001` and must be running before starting the backend.

**See detailed instructions in:** `IPFS-SETUP.md`

### 2. Setup Backend

```powershell
# Navigate to backend directory
cd backend

# Create virtual environment
python -m venv venv

# Install dependencies (from outside venv to avoid path issues)
.\venv\Scripts\pip.exe install -r requirements.txt

# Run the server
.\venv\Scripts\python.exe main.py
```

Backend will be available at `http://localhost:8000`

**Note**: The requirements use flexible version pins (`>=`) to ensure compatibility with Python 3.13+

### 3. Setup Frontend

Open a new terminal:

```powershell
# Navigate to frontend directory
cd frontend

# Install dependencies
npm install

# Start development server
npm run dev
```

Frontend will be available at `http://localhost:5173`

### 4. Access the Application

Open your browser and navigate to:
```
http://localhost:5173
```

## 📖 Usage

### Uploading Files

1. Click **"Upload File"** tab
2. Select a file from your computer
3. (Optional) Enter recipient's X25519 public key for key wrapping
4. Click **"Encrypt & Upload to IPFS"**
5. Copy the generated shareable link

### Downloading Files

1. Click **"Download File"** tab
2. Enter the IPFS CID, encryption key, and IV
   - Or paste the shareable link (auto-fills fields)
3. Click **"Download & Decrypt"**
4. File will be decrypted and downloaded

## 🔧 Configuration

### Backend Configuration

Edit `backend/.env`:
```env
IPFS_API_URL=http://127.0.0.1:5001/api/v0
HOST=0.0.0.0
PORT=8000
```

### Frontend Configuration

Edit `frontend/vite.config.ts` to change proxy settings:
```typescript
proxy: {
  '/api': {
    target: 'http://localhost:8000',
    changeOrigin: true,
  }
}
```

## 📡 API Endpoints

### Health & Info
- `GET /` - API information
- `GET /health` - Health check with IPFS status
- `GET /api/server/public-key` - Server's public key

### Key Management
- `POST /api/key/wrap` - Wrap encryption key for recipient

### File Operations
- `POST /api/ipfs/add` - Upload encrypted file to IPFS
- `GET /api/ipfs/cat/{cid}` - Download file from IPFS
- `POST /api/ipfs/pin/add` - Pin file to local node

### Node Management
- `GET /api/node/peers` - List connected IPFS peers

## 🔒 Security Model

### Threat Model

**Protected Against:**
- ✅ Server compromise (end-to-end encryption)
- ✅ Network eavesdropping (TLS + encryption)
- ✅ IPFS storage snooping (encrypted at rest)
- ✅ Man-in-the-middle (authenticated encryption)

**Not Protected Against:**
- ❌ Compromised client device
- ❌ Malicious browser extensions
- ❌ Key leakage via insecure channels
- ❌ Social engineering attacks

### Best Practices

1. **Key Management**: Never share encryption keys over insecure channels
2. **HTTPS**: Use HTTPS in production to prevent MitM attacks
3. **Key Wrapping**: Use X25519 key wrapping for secure key exchange
4. **Secure Deletion**: Clear browser cache after sensitive operations
5. **Verify Recipients**: Always verify recipient public keys out-of-band

## 🛠️ Development

### Project Structure

```
filesharing/
├── backend/
│   ├── main.py              # FastAPI application
│   ├── requirements.txt     # Python dependencies
│   └── README.md           # Backend documentation
│
└── frontend/
    ├── src/
    │   ├── components/     # React components
    │   ├── crypto.ts       # Cryptography utilities
    │   ├── api.ts          # API client
    │   ├── App.tsx         # Main app component
    │   └── main.tsx        # Entry point
    ├── package.json        # Node dependencies
    ├── vite.config.ts      # Vite configuration
    └── README.md           # Frontend documentation
```

### Running Tests

Backend:
```powershell
cd backend
pytest
```

Frontend:
```powershell
cd frontend
npm run test
```

### Building for Production

Backend:
```powershell
cd backend
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```

Frontend:
```powershell
cd frontend
npm run build
# Serve dist/ directory with your web server
```

## 🐛 Troubleshooting

### IPFS Connection Issues

**Problem**: "IPFS Not Connected" error

**Solution**:
```powershell
# Check if IPFS daemon is running
ipfs id

# If not, start it
ipfs daemon
```

### Backend Can't Connect to IPFS

**Problem**: Backend health check fails

**Solution**:
```powershell
# Verify IPFS API is accessible
curl http://127.0.0.1:5001/api/v0/id

# Check firewall settings
# Ensure port 5001 is not blocked
```

### CORS Errors

**Problem**: Frontend can't access backend

**Solution**:
- Verify backend CORS settings in `main.py`
- Ensure frontend URL is in `allow_origins`
- Check browser console for specific errors

### Crypto Errors

**Problem**: "Key wrapping failed" or decryption errors

**Solution**:
- Verify all parameters (CID, key, IV) are correct
- Check that key is valid Base64
- Ensure IV is valid hex string

## 📚 Resources

- [IPFS Documentation](https://docs.ipfs.tech/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Web Crypto API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Crypto_API)
- [PyNaCl Documentation](https://pynacl.readthedocs.io/)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests.

## 📄 License

MIT License - feel free to use this project for any purpose.

## ⚠️ Disclaimer

This is a demonstration project. While it implements strong cryptography, it should be thoroughly audited before use in production environments with sensitive data.

## 🙏 Acknowledgments

- IPFS Protocol Labs for decentralized storage
- FastAPI for the excellent Python framework
- React and Vite teams for modern web development tools
- The cryptography community for proven encryption standards

---

**Built with ❤️ for privacy and decentralization**
