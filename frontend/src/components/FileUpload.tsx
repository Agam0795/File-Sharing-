import { useState, useRef } from 'react';
import {
  encryptFile,
  exportKey,
  arrayBufferToBase64,
  uint8ArrayToHex,
} from '../crypto';
import { uploadToIPFS, wrapKey } from '../api';

interface ShareLink {
  cid: string;
  key: string;
  iv: string;
  wrappedKey?: string;
}

function FileUpload() {
  const [file, setFile] = useState<File | null>(null);
  const [uploading, setUploading] = useState(false);
  const [shareLink, setShareLink] = useState<ShareLink | null>(null);
  const [error, setError] = useState<string>('');
  const [recipientPublicKey, setRecipientPublicKey] = useState<string>('');
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFileSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
    const selectedFile = event.target.files?.[0];
    if (selectedFile) {
      setFile(selectedFile);
      setShareLink(null);
      setError('');
    }
  };

  const handleUpload = async () => {
    if (!file) return;

    setUploading(true);
    setError('');
    setShareLink(null);

    try {
      // Step 1: Encrypt file in browser
      console.log('Encrypting file...');
      const { encryptedData, key, iv } = await encryptFile(file);

      // Step 2: Export key for sharing
      const rawKey = await exportKey(key);
      const keyBase64 = arrayBufferToBase64(rawKey);
      const ivHex = uint8ArrayToHex(iv);

      // Step 3: Upload encrypted blob to IPFS
      console.log('Uploading to IPFS...');
      const encryptedBlob = new Blob([encryptedData]);
      const result = await uploadToIPFS(
        encryptedBlob,
        `encrypted_${file.name}`
      );

      console.log('File uploaded! CID:', result.cid);

      // Step 4: Optionally wrap key for recipient
      let wrappedKey: string | undefined;
      if (recipientPublicKey.trim()) {
        try {
          console.log('Wrapping key for recipient...');
          const wrapResult = await wrapKey(keyBase64, recipientPublicKey.trim());
          wrappedKey = wrapResult.wrapped_key;
          console.log('Key wrapped successfully');
        } catch (err) {
          console.warn('Key wrapping failed:', err);
          // Continue without wrapped key
        }
      }

      // Step 5: Create share link
      setShareLink({
        cid: result.cid,
        key: keyBase64,
        iv: ivHex,
        wrappedKey,
      });
    } catch (err) {
      console.error('Upload error:', err);
      setError(
        err instanceof Error ? err.message : 'Upload failed. Please try again.'
      );
    } finally {
      setUploading(false);
    }
  };

  const generateShareableLink = () => {
    if (!shareLink) return '';

    const params = new URLSearchParams({
      cid: shareLink.cid,
      key: shareLink.key,
      iv: shareLink.iv,
    });

    if (shareLink.wrappedKey) {
      params.append('wrapped', shareLink.wrappedKey);
    }

    return `${window.location.origin}?${params.toString()}`;
  };

  const copyToClipboard = async () => {
    const link = generateShareableLink();
    try {
      await navigator.clipboard.writeText(link);
      alert('Link copied to clipboard!');
    } catch (err) {
      console.error('Copy failed:', err);
    }
  };

  return (
    <div className="card">
      <h2>Upload & Encrypt File</h2>

      <div style={{ marginBottom: '1rem' }}>
        <input
          ref={fileInputRef}
          type="file"
          onChange={handleFileSelect}
          id="file-input"
        />
        <label htmlFor="file-input" className="file-input-label">
          Choose File
        </label>
        {file && (
          <p style={{ marginTop: '0.5rem' }}>
            Selected: <strong>{file.name}</strong> ({(file.size / 1024).toFixed(2)} KB)
          </p>
        )}
      </div>

      <div style={{ marginBottom: '1rem' }}>
        <label htmlFor="recipient-key" style={{ display: 'block', marginBottom: '0.5rem' }}>
          Recipient Public Key (optional):
        </label>
        <input
          id="recipient-key"
          type="text"
          placeholder="Base64 encoded X25519 public key"
          value={recipientPublicKey}
          onChange={(e) => setRecipientPublicKey(e.target.value)}
          style={{
            width: '100%',
            padding: '0.5rem',
            borderRadius: '4px',
            border: '1px solid #444',
            backgroundColor: '#2a2a2a',
            color: 'inherit',
          }}
        />
        <p style={{ fontSize: '0.85em', color: '#888', marginTop: '0.3rem' }}>
          If provided, the encryption key will be wrapped for this recipient
        </p>
      </div>

      <button
        onClick={handleUpload}
        disabled={!file || uploading}
        style={{ width: '100%', padding: '1em' }}
      >
        {uploading ? 'Encrypting & Uploading...' : 'Encrypt & Upload to IPFS'}
      </button>

      {error && (
        <div className="error" style={{ marginTop: '1rem' }}>
          <strong>Error:</strong> {error}
        </div>
      )}

      {shareLink && (
        <div style={{ marginTop: '2rem' }}>
          <h3 className="success">✓ Upload Successful!</h3>

          <div style={{ marginTop: '1rem' }}>
            <p>
              <strong>IPFS CID:</strong>
            </p>
            <div className="link-box">{shareLink.cid}</div>
          </div>

          <div style={{ marginTop: '1rem' }}>
            <p>
              <strong>Encryption Key:</strong>
            </p>
            <div className="link-box">{shareLink.key}</div>
          </div>

          <div style={{ marginTop: '1rem' }}>
            <p>
              <strong>IV (Initialization Vector):</strong>
            </p>
            <div className="link-box">{shareLink.iv}</div>
          </div>

          {shareLink.wrappedKey && (
            <div style={{ marginTop: '1rem' }}>
              <p>
                <strong>Wrapped Key (for recipient):</strong>
              </p>
              <div className="link-box">{shareLink.wrappedKey}</div>
            </div>
          )}

          <div style={{ marginTop: '1.5rem' }}>
            <p>
              <strong>Shareable Link:</strong>
            </p>
            <div className="link-box">{generateShareableLink()}</div>
            <button
              onClick={copyToClipboard}
              style={{ marginTop: '1rem', width: '100%' }}
            >
              Copy Link to Clipboard
            </button>
          </div>

          <p className="info" style={{ marginTop: '1rem', fontSize: '0.9em' }}>
            ⚠️ Keep this information safe! Anyone with the CID and key can
            decrypt your file.
          </p>
        </div>
      )}
    </div>
  );
}

export default FileUpload;
