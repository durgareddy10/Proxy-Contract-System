import React, { useState, useEffect } from 'react';
import { Layout, Card, Button, Row, Col, Typography, Space } from 'antd';
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import WalletConnect from '../components/WalletConnect';
import CreateProxy from '../components/CreateProxy';
import ProxyManager from '../components/ProxyManager';

const { Header, Content } = Layout;
const { Title } = Typography;

function Dashboard() {
  const { connected, account } = useWallet();

  return (
    <Layout>
      <Header style={{ background: '#001529', padding: '0 50px' }}>
        <Row justify="space-between" align="middle">
          <Col>
            <Title level={2} style={{ color: 'white', margin: 0 }}>
              Proxy Contract System
            </Title>
          </Col>
          <Col>
            <WalletConnect />
          </Col>
        </Row>
      </Header>
      
      <Content style={{ padding: '50px' }}>
        {connected ? (
          <Space direction="vertical" size="large" style={{ width: '100%' }}>
            <Card title="Account Information">
              <p><strong>Address:</strong> {account?.address}</p>
            </Card>
            
            <Row gutter={[24, 24]}>
              <Col xs={24} lg={12}>
                <CreateProxy />
              </Col>
              <Col xs={24} lg={12}>
                <ProxyManager />
              </Col>
            </Row>
          </Space>
        ) : (
          <Card style={{ textAlign: 'center' }}>
            <Title level={3}>Welcome to Proxy Contract System</Title>
            <p>Please connect your wallet to get started</p>
            <WalletConnect />
          </Card>
        )}
      </Content>
    </Layout>
  );
}

export default Dashboard;