/**
 * API client for interacting with the DecentraShare backend
 */

// Use environment variable for API URL, fallback to localhost
const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000';

export interface HealthResponse {
  status: string;
  ipfs_connected: boolean;
  ipfs_id?: string;
  ipfs_agent?: string;
  error?: string;
}

export interface IPFSAddResponse {
  cid: string;
  size: string;
  name: string;
}

export interface KeyWrapResponse {
  wrapped_key: string;
  server_public_key: string;
}

export interface PeersResponse {
  peers: string[];
  count: number;
}

/**
 * Check API and IPFS health
 */
export async function checkHealth(): Promise<HealthResponse> {
  const response = await fetch(`${API_BASE_URL}/health`);
  if (!response.ok) {
    throw new Error('Health check failed');
  }
  return await response.json();
}

/**
 * Upload encrypted file to IPFS
 */
export async function uploadToIPFS(
  encryptedBlob: Blob,
  filename: string
): Promise<IPFSAddResponse> {
  const formData = new FormData();
  formData.append('file', encryptedBlob, filename);

  const response = await fetch(`${API_BASE_URL}/api/ipfs/add`, {
    method: 'POST',
    body: formData,
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.detail || 'Upload failed');
  }

  return await response.json();
}

/**
 * Download encrypted file from IPFS
 */
export async function downloadFromIPFS(cid: string): Promise<ArrayBuffer> {
  const response = await fetch(`${API_BASE_URL}/api/ipfs/cat/${cid}`);

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.detail || 'Download failed');
  }

  return await response.arrayBuffer();
}

/**
 * Wrap encryption key for recipient
 */
export async function wrapKey(
  fileKey: string,
  recipientPublicKey: string
): Promise<KeyWrapResponse> {
  const response = await fetch(`${API_BASE_URL}/api/key/wrap`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      file_key: fileKey,
      recipient_public_key: recipientPublicKey,
    }),
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.detail || 'Key wrapping failed');
  }

  return await response.json();
}

/**
 * Get server's public key
 */
export async function getServerPublicKey(): Promise<string> {
  const response = await fetch(`${API_BASE_URL}/api/server/public-key`);
  if (!response.ok) {
    throw new Error('Failed to get server public key');
  }
  const data = await response.json();
  return data.public_key;
}

/**
 * Get connected IPFS peers
 */
export async function getPeers(): Promise<PeersResponse> {
  const response = await fetch(`${API_BASE_URL}/api/node/peers`);
  if (!response.ok) {
    throw new Error('Failed to get peers');
  }
  return await response.json();
}

/**
 * Pin file to local IPFS node
 */
export async function pinFile(cid: string): Promise<void> {
  const response = await fetch(`${API_BASE_URL}/api/ipfs/pin/add`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ cid }),
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.detail || 'Pin failed');
  }
}
