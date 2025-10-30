import { useState, useEffect } from 'react';
import { checkHealth, HealthResponse } from '../api';

function HealthStatus() {
  const [health, setHealth] = useState<HealthResponse | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchHealth = async () => {
      try {
        const data = await checkHealth();
        setHealth(data);
      } catch (error) {
        console.error('Health check failed:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchHealth();
    const interval = setInterval(fetchHealth, 10000); // Check every 10s

    return () => clearInterval(interval);
  }, []);

  if (loading) {
    return <div className="card">Loading...</div>;
  }

  const isHealthy = health?.ipfs_connected && health?.status === 'healthy';

  return (
    <div className="card">
      <h3>System Status</h3>
      <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
        <span
          className={`status-indicator ${
            isHealthy ? 'healthy' : 'degraded'
          }`}
        ></span>
        <span>
          {isHealthy ? 'All Systems Operational' : 'IPFS Not Connected'}
        </span>
      </div>
      {health?.ipfs_id && (
        <p style={{ fontSize: '0.85em', marginTop: '0.5rem', color: '#888' }}>
          IPFS Node: {health.ipfs_id.substring(0, 12)}...
        </p>
      )}
      {health?.error && (
        <p className="error" style={{ fontSize: '0.85em', marginTop: '0.5rem' }}>
          {health.error}
        </p>
      )}
    </div>
  );
}

export default HealthStatus;
