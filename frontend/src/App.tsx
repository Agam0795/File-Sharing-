import { useState } from 'react';
import './App.css';
import FileUpload from './components/FileUpload';
import FileDownload from './components/FileDownload';
import HealthStatus from './components/HealthStatus';

function App() {
  const [activeTab, setActiveTab] = useState<'upload' | 'download'>('upload');

  return (
    <div className="App">
      <header>
        <h1>🔒 DecentraShare</h1>
        <p>Secure Decentralized File Sharing with End-to-End Encryption</p>
      </header>

      <HealthStatus />

      <div className="tabs">
        <button
          className={activeTab === 'upload' ? 'active' : ''}
          onClick={() => setActiveTab('upload')}
        >
          Upload File
        </button>
        <button
          className={activeTab === 'download' ? 'active' : ''}
          onClick={() => setActiveTab('download')}
        >
          Download File
        </button>
      </div>

      <main>
        {activeTab === 'upload' ? <FileUpload /> : <FileDownload />}
      </main>

      <footer>
        <p>
          <strong>How it works:</strong> Files are encrypted in your browser
          before upload. They are stored on IPFS, and only you control the
          decryption keys. The server never sees your unencrypted data.
        </p>
      </footer>
    </div>
  );
}

export default App;
