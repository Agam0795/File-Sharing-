import { useState } from 'react';
import {
  importKey,
  decryptFile,
  base64ToArrayBuffer,
  hexToUint8Array,
} from '../crypto';
import { downloadFromIPFS } from '../api';

function FileDownload() {
  const [cid, setCid] = useState<string>('');
  const [key, setKey] = useState<string>('');
  const [iv, setIv] = useState<string>('');
  const [downloading, setDownloading] = useState(false);
  const [error, setError] = useState<string>('');
  const [success, setSuccess] = useState<string>('');

  // Load from URL parameters on mount
  useState(() => {
    const params = new URLSearchParams(window.location.search);
    const cidParam = params.get('cid');
    const keyParam = params.get('key');
    const ivParam = params.get('iv');

    if (cidParam) setCid(cidParam);
    if (keyParam) setKey(keyParam);
    if (ivParam) setIv(ivParam);
  });

  const handleDownload = async () => {
    if (!cid || !key || !iv) {
      setError('Please provide CID, key, and IV');
      return;
    }

    setDownloading(true);
    setError('');
    setSuccess('');

    try {
      // Step 1: Download encrypted file from IPFS
      console.log('Downloading from IPFS...');
      const encryptedData = await downloadFromIPFS(cid);

      // Step 2: Import the key
      console.log('Importing key...');
      const keyData = base64ToArrayBuffer(key);
      const cryptoKey = await importKey(keyData);

      // Step 3: Decrypt the file
      console.log('Decrypting file...');
      const ivBytes = hexToUint8Array(iv);
      const decryptedData = await decryptFile(encryptedData, cryptoKey, ivBytes);

      // Step 4: Create a download link
      const blob = new Blob([decryptedData]);
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `decrypted_file_${Date.now()}`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);

      setSuccess('File downloaded and decrypted successfully!');
      console.log('Download complete');
    } catch (err) {
      console.error('Download error:', err);
      setError(
        err instanceof Error ? err.message : 'Download/decryption failed'
      );
    } finally {
      setDownloading(false);
    }
  };

  return (
    <div className="card">
      <h2>Download & Decrypt File</h2>

      <div style={{ marginBottom: '1rem' }}>
        <label htmlFor="cid-input" style={{ display: 'block', marginBottom: '0.5rem' }}>
          IPFS CID:
        </label>
        <input
          id="cid-input"
          type="text"
          placeholder="QmXxx..."
          value={cid}
          onChange={(e) => setCid(e.target.value)}
          style={{
            width: '100%',
            padding: '0.5rem',
            borderRadius: '4px',
            border: '1px solid #444',
            backgroundColor: '#2a2a2a',
            color: 'inherit',
          }}
        />
      </div>

      <div style={{ marginBottom: '1rem' }}>
        <label htmlFor="key-input" style={{ display: 'block', marginBottom: '0.5rem' }}>
          Encryption Key (Base64):
        </label>
        <input
          id="key-input"
          type="text"
          placeholder="Base64 encoded key"
          value={key}
          onChange={(e) => setKey(e.target.value)}
          style={{
            width: '100%',
            padding: '0.5rem',
            borderRadius: '4px',
            border: '1px solid #444',
            backgroundColor: '#2a2a2a',
            color: 'inherit',
          }}
        />
      </div>

      <div style={{ marginBottom: '1rem' }}>
        <label htmlFor="iv-input" style={{ display: 'block', marginBottom: '0.5rem' }}>
          IV (Hex):
        </label>
        <input
          id="iv-input"
          type="text"
          placeholder="Initialization vector in hex"
          value={iv}
          onChange={(e) => setIv(e.target.value)}
          style={{
            width: '100%',
            padding: '0.5rem',
            borderRadius: '4px',
            border: '1px solid #444',
            backgroundColor: '#2a2a2a',
            color: 'inherit',
          }}
        />
      </div>

      <button
        onClick={handleDownload}
        disabled={!cid || !key || !iv || downloading}
        style={{ width: '100%', padding: '1em' }}
      >
        {downloading ? 'Downloading & Decrypting...' : 'Download & Decrypt'}
      </button>

      {error && (
        <div className="error" style={{ marginTop: '1rem' }}>
          <strong>Error:</strong> {error}
        </div>
      )}

      {success && (
        <div className="success" style={{ marginTop: '1rem' }}>
          <strong>✓ {success}</strong>
        </div>
      )}

      <div style={{ marginTop: '2rem', padding: '1rem', backgroundColor: '#2a2a2a', borderRadius: '4px' }}>
        <h4>How to use:</h4>
        <ol style={{ marginLeft: '1.5rem', marginTop: '0.5rem' }}>
          <li>Paste the IPFS CID (content identifier)</li>
          <li>Paste the Base64 encoded encryption key</li>
          <li>Paste the hex encoded IV (initialization vector)</li>
          <li>Click "Download & Decrypt" to retrieve your file</li>
        </ol>
        <p style={{ marginTop: '1rem', fontSize: '0.9em', color: '#888' }}>
          💡 Tip: If you received a share link, it will automatically fill these fields.
        </p>
      </div>
    </div>
  );
}

export default FileDownload;
