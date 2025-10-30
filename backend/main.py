from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response
from pydantic import BaseModel
import httpx
import nacl.public
import nacl.encoding
import base64
from typing import Optional
import os
from base64 import b64encode

app = FastAPI(title="DecentraShare API", version="1.0.0")

# CORS middleware for frontend access
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        "http://localhost:5174",
        "http://localhost:3000",
        "https://fantastic-hummingbird-94cd70.netlify.app"
    ],  # Vite ports + Production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Pinata credentials
PINATA_API_KEY = os.getenv("PINATA_API_KEY", "")
PINATA_SECRET_KEY = os.getenv("PINATA_SECRET_KEY", "")
PINATA_JWT = os.getenv("PINATA_JWT", "")

# IPFS provider configuration
USE_PINATA = bool(PINATA_API_KEY or PINATA_JWT)

if USE_PINATA:
    IPFS_API_URL = "https://api.pinata.cloud"
    IPFS_GATEWAY = "https://gateway.pinata.cloud/ipfs"
    print(f"INFO: Using Pinata IPFS service")
else:
    IPFS_API_URL = os.getenv("IPFS_API_URL", "http://127.0.0.1:5001/api/v0")
    IPFS_GATEWAY = "http://127.0.0.1:8080/ipfs"
    # Ensure the URL includes /api/v0 path
    if not IPFS_API_URL.endswith("/api/v0"):
        IPFS_API_URL = f"{IPFS_API_URL}/api/v0"
    print(f"INFO: Using local/custom IPFS endpoint: {IPFS_API_URL}")

# Create auth headers for IPFS requests
def get_ipfs_headers():
    """Get headers for IPFS requests based on the provider"""
    headers = {}
    if USE_PINATA:
        # Pinata can use either JWT or API Key + Secret
        if PINATA_JWT:
            headers["Authorization"] = f"Bearer {PINATA_JWT}"
            print(f"DEBUG: Using Pinata JWT authentication")
        elif PINATA_API_KEY and PINATA_SECRET_KEY:
            headers["pinata_api_key"] = PINATA_API_KEY
            headers["pinata_secret_api_key"] = PINATA_SECRET_KEY
            print(f"DEBUG: Using Pinata API Key authentication")
    return headers

# Server keypair for key wrapping (X25519)
SERVER_PRIVATE_KEY = nacl.public.PrivateKey.generate()
SERVER_PUBLIC_KEY = SERVER_PRIVATE_KEY.public_key


class KeyWrapRequest(BaseModel):
    file_key: str  # Base64 encoded AES key
    recipient_public_key: str  # Base64 encoded X25519 public key


class KeyWrapResponse(BaseModel):
    wrapped_key: str  # Base64 encoded sealed box
    server_public_key: str  # Base64 encoded server public key


class PinRequest(BaseModel):
    cid: str


@app.get("/")
async def root():
    return {
        "name": "DecentraShare API",
        "version": "1.0.0",
        "description": "Secure Decentralized File Sharing with IPFS"
    }


@app.get("/health")
async def health_check():
    """Check if the API and IPFS node are healthy"""
    ipfs_connected = False
    ipfs_info_data = {}
    error_msg = None
    
    try:
        async with httpx.AsyncClient() as client:
            headers = get_ipfs_headers()
            
            if USE_PINATA:
                # Test Pinata authentication
                print(f"DEBUG: Testing Pinata authentication")
                response = await client.get(
                    f"{IPFS_API_URL}/data/testAuthentication",
                    headers=headers,
                    timeout=5.0
                )
                print(f"DEBUG: Pinata auth response status: {response.status_code}")
                if response.status_code == 200:
                    auth_data = response.json()
                    ipfs_connected = True
                    ipfs_info_data = {
                        "provider": "Pinata",
                        "authenticated": auth_data.get("message") == "Congratulations! You are communicating with the Pinata API!"
                    }
                else:
                    error_msg = f"Pinata returned status {response.status_code}: {response.text[:200]}"
                    print(f"DEBUG: Pinata error response: {response.text[:500]}")
            else:
                # Test local IPFS node
                print(f"DEBUG: Calling local IPFS at {IPFS_API_URL}/id")
                response = await client.post(
                    f"{IPFS_API_URL}/id", 
                    headers=headers,
                    timeout=5.0
                )
                print(f"DEBUG: IPFS response status: {response.status_code}")
                if response.status_code == 200:
                    ipfs_info = response.json()
                    ipfs_connected = True
                    ipfs_info_data = {
                        "ipfs_id": ipfs_info.get("ID"),
                        "ipfs_agent": ipfs_info.get("AgentVersion")
                    }
                else:
                    error_msg = f"IPFS returned status {response.status_code}: {response.text[:200]}"
                    print(f"DEBUG: IPFS error response: {response.text[:500]}")
    except Exception as e:
        error_msg = str(e)
        print(f"DEBUG: IPFS connection exception: {e}")
    
    result = {
        "status": "healthy" if ipfs_connected else "degraded",
        "ipfs_connected": ipfs_connected,
        "ipfs_provider": "pinata" if USE_PINATA else "local/custom",
        "ipfs_url": IPFS_API_URL,
        "has_pinata_auth": bool(PINATA_JWT or (PINATA_API_KEY and PINATA_SECRET_KEY))
    }
    
    if ipfs_connected:
        result.update(ipfs_info_data)
    elif error_msg:
        result["error"] = error_msg
    
    return result


@app.get("/api/server/public-key")
async def get_server_public_key():
    """Get server's public key for key wrapping"""
    return {
        "public_key": base64.b64encode(
            SERVER_PUBLIC_KEY.encode(encoder=nacl.encoding.RawEncoder)
        ).decode('utf-8')
    }


@app.post("/api/key/wrap", response_model=KeyWrapResponse)
async def wrap_key(request: KeyWrapRequest):
    """
    Wrap a file encryption key for a recipient using X25519 sealed box.
    The backend wraps the key but never stores or logs it.
    """
    try:
        # Decode the file key (AES key used to encrypt the file)
        file_key_bytes = base64.b64decode(request.file_key)
        
        # Decode recipient's public key
        recipient_pub_bytes = base64.b64decode(request.recipient_public_key)
        recipient_public_key = nacl.public.PublicKey(recipient_pub_bytes)
        
        # Create a sealed box (anonymous encryption)
        sealed_box = nacl.public.SealedBox(recipient_public_key)
        
        # Encrypt the file key for the recipient
        encrypted_key = sealed_box.encrypt(file_key_bytes)
        
        # Return the wrapped key
        return KeyWrapResponse(
            wrapped_key=base64.b64encode(encrypted_key).decode('utf-8'),
            server_public_key=base64.b64encode(
                SERVER_PUBLIC_KEY.encode(encoder=nacl.encoding.RawEncoder)
            ).decode('utf-8')
        )
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Key wrapping failed: {str(e)}")


@app.post("/api/ipfs/add")
async def add_to_ipfs(file: UploadFile = File(...)):
    """
    Upload an encrypted file to IPFS.
    Returns the CID (Content Identifier) for retrieval.
    """
    try:
        content = await file.read()
        
        async with httpx.AsyncClient() as client:
            if USE_PINATA:
                # Use Pinata API for file upload
                files = {"file": (file.filename, content)}
                response = await client.post(
                    f"{IPFS_API_URL}/pinning/pinFileToIPFS",
                    files=files,
                    headers=get_ipfs_headers(),
                    timeout=30.0
                )
                
                if response.status_code == 200:
                    result = response.json()
                    return {
                        "cid": result["IpfsHash"],
                        "size": result["PinSize"],
                        "name": file.filename
                    }
                else:
                    raise HTTPException(
                        status_code=response.status_code,
                        detail=f"Pinata upload failed: {response.text[:200]}"
                    )
            else:
                # Use local IPFS node
                files = {"file": (file.filename, content)}
                response = await client.post(
                    f"{IPFS_API_URL}/add",
                    files=files,
                    headers=get_ipfs_headers(),
                    params={"pin": "true"},
                    timeout=30.0
                )
                
                if response.status_code == 200:
                    result = response.json()
                    return {
                        "cid": result["Hash"],
                        "size": result["Size"],
                        "name": result["Name"]
                    }
                else:
                    raise HTTPException(
                        status_code=response.status_code,
                        detail="IPFS add failed"
                    )
    except httpx.TimeoutException:
        raise HTTPException(status_code=504, detail="IPFS request timed out")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Upload failed: {str(e)}")


@app.get("/api/ipfs/cat/{cid}")
async def cat_from_ipfs(cid: str):
    """
    Retrieve an encrypted file from IPFS by CID.
    Returns the raw encrypted bytes.
    """
    try:
        async with httpx.AsyncClient() as client:
            if USE_PINATA:
                # Use Pinata gateway for file retrieval
                response = await client.get(
                    f"{IPFS_GATEWAY}/{cid}",
                    timeout=30.0
                )
            else:
                # Use local IPFS node
                response = await client.post(
                    f"{IPFS_API_URL}/cat",
                    headers=get_ipfs_headers(),
                    params={"arg": cid},
                    timeout=30.0
                )
            
            if response.status_code == 200:
                return Response(
                    content=response.content,
                    media_type="application/octet-stream",
                    headers={
                        "Content-Disposition": f'attachment; filename="{cid}"'
                    }
                )
            else:
                raise HTTPException(
                    status_code=response.status_code,
                    detail=f"IPFS retrieval failed: {response.text[:200]}"
                )
    except httpx.TimeoutException:
        raise HTTPException(status_code=504, detail="IPFS request timed out")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Download failed: {str(e)}")


@app.post("/api/ipfs/pin/add")
async def pin_to_ipfs(request: PinRequest):
    """Pin a file to IPFS (Pinata automatically pins on upload)"""
    try:
        if USE_PINATA:
            # Pinata automatically pins files on upload, so this is a no-op for existing CIDs
            # We could use their pinByHash endpoint if needed
            return {
                "pinned": [request.cid],
                "success": True,
                "note": "Pinata automatically pins files on upload"
            }
        else:
            # Use local IPFS node pinning
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"{IPFS_API_URL}/pin/add",
                    headers=get_ipfs_headers(),
                    params={"arg": request.cid},
                    timeout=30.0
                )
                
                if response.status_code == 200:
                    result = response.json()
                    return {
                        "pinned": result["Pins"],
                        "success": True
                    }
                else:
                    raise HTTPException(
                        status_code=response.status_code,
                        detail="IPFS pin failed"
                    )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Pin failed: {str(e)}")


@app.get("/api/node/peers")
async def get_peers():
    """Get list of connected IPFS peers (only for local IPFS nodes)"""
    try:
        if USE_PINATA:
            # Pinata doesn't expose peer information
            return {
                "peers": [],
                "count": 0,
                "note": "Pinata manages peers internally"
            }
        else:
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"{IPFS_API_URL}/swarm/peers",
                    headers=get_ipfs_headers(),
                    timeout=10.0
                )
                
                if response.status_code == 200:
                    result = response.json()
                    return {
                        "peers": result.get("Peers", []),
                        "count": len(result.get("Peers", []))
                    }
                else:
                    raise HTTPException(
                        status_code=response.status_code,
                        detail="Failed to get peers"
                    )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Get peers failed: {str(e)}")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
