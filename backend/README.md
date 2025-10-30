# DecentraShare Backend

FastAPI backend for secure decentralized file sharing with IPFS integration.

## Features

- **IPFS Integration**: Upload and retrieve files from IPFS
- **Key Wrapping**: X25519 sealed box encryption for secure key exchange
- **Health Monitoring**: Check IPFS node connectivity and health
- **Peer Management**: View connected IPFS peers

## Prerequisites

- Python 3.11+ (Python 3.13 supported)
- IPFS Kubo (go-ipfs) installed and running

## Setup

1. Create and activate virtual environment:
```bash
python -m venv venv
.\venv\Scripts\Activate.ps1  # Windows PowerShell
# or: source venv/bin/activate  # Linux/Mac
```

2. Install Python dependencies:
```bash
pip install -r requirements.txt
```

3. Ensure IPFS daemon is running:
```bash
ipfs daemon
```

4. Run the backend server:
```bash
# Using venv Python directly (recommended)
.\venv\Scripts\python.exe main.py  # Windows
# or: ./venv/bin/python main.py  # Linux/Mac

# Or use uvicorn directly
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

## API Endpoints

### Health & Info
- `GET /` - API information
- `GET /health` - Health check with IPFS status
- `GET /api/server/public-key` - Get server's public key

### Key Management
- `POST /api/key/wrap` - Wrap encryption key for recipient

### File Operations
- `POST /api/ipfs/add` - Upload encrypted file to IPFS
- `GET /api/ipfs/cat/{cid}` - Download file from IPFS
- `POST /api/ipfs/pin/add` - Pin file to local node

### Node Management
- `GET /api/node/peers` - List connected IPFS peers

## Security

- The backend never sees or processes unencrypted files
- All files are encrypted client-side before upload
- Key wrapping uses X25519 elliptic curve cryptography
- No file keys or plaintext data are stored
