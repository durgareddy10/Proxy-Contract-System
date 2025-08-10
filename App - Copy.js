import React from 'react';
import { ConfigProvider } from 'antd';
import Dashboard from './pages/Dashboard';
import 'antd/dist/reset.css';

function App() {
  return (
    <ConfigProvider
      theme={{
        token: {
          colorPrimary: '#667eea',
          borderRadius: 8,
        },
      }}
    >
      <div style={{ minHeight: '100vh', background: '#f5f5f5' }}>
        <Dashboard />
      </div>
    </ConfigProvider>
  );
}

export default App;