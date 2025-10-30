# DecentraShare Frontend

Modern React frontend for secure decentralized file sharing with client-side encryption.

## Features

- **Client-Side Encryption**: Files encrypted in browser using AES-GCM
- **IPFS Storage**: Decentralized file storage via backend API
- **Secure Sharing**: Generate shareable links with encryption keys
- **Key Wrapping**: Optional X25519 key wrapping for recipients
- **Modern UI**: Built with React 18, TypeScript, and Vite

## Prerequisites

- Node.js 18+ and npm
- Backend API running on port 8000
- IPFS node accessible to backend

## Setup

1. Install dependencies:
```bash
npm install
```

2. Start the development server:
```bash
npm run dev
```

3. Open browser at `http://localhost:5173`

## Build for Production

```bash
npm run build
```

The built files will be in the `dist` directory.

## How It Works

### Upload Flow
1. User selects a file in the browser
2. File is encrypted using AES-GCM (Web Crypto API)
3. Encrypted blob is uploaded to backend → IPFS
4. Backend returns CID (Content Identifier)
5. Frontend generates shareable link with CID + key + IV

### Download Flow
1. User provides CID, encryption key, and IV
2. Frontend downloads encrypted file from IPFS
3. File is decrypted in browser using provided key
4. User receives original file

## Security Features

- **End-to-End Encryption**: Files never leave browser unencrypted
- **AES-GCM**: Authenticated encryption with 256-bit keys
- **Web Crypto API**: Browser-native cryptography
- **No Server Knowledge**: Backend never sees plaintext or keys
- **Optional Key Wrapping**: X25519 sealed boxes for recipient encryption

## Technology Stack

- React 18
- TypeScript
- Vite (build tool)
- Web Crypto API
- CSS3
