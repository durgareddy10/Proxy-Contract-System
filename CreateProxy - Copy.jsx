import React, { useState } from 'react';
import { Card, Form, Input, Button, message } from 'antd';
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { aptosClient } from '../utils/aptosClient';
import { MODULE_ADDRESS, MODULE_NAME } from '../utils/constants';

function CreateProxy() {
  const { account, signAndSubmitTransaction } = useWallet();
  const [loading, setLoading] = useState(false);
  const [form] = Form.useForm();

  const handleCreateProxy = async (values) => {
    if (!account) return;
    
    setLoading(true);
    try {
      const payload = {
        type: "entry_function_payload",
        function: `${MODULE_ADDRESS}::${MODULE_NAME}::create_proxy`,
        arguments: [
          values.implementationAddress,
          parseInt(values.version)
        ],
        type_arguments: []
      };

      const response = await signAndSubmitTransaction(payload);
      await aptosClient.waitForTransaction({ transactionHash: response.hash });
      
      message.success('Proxy created successfully!');
      form.resetFields();
    } catch (error) {
      console.error('Error creating proxy:', error);
      message.error('Failed to create proxy');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Card title="Create New Proxy">
      <Form form={form} layout="vertical" onFinish={handleCreateProxy}>
        <Form.Item
          label="Implementation Address"
          name="implementationAddress"
          rules={[{ required: true, message: 'Please input implementation address!' }]}
        >
          <Input placeholder="0x..." />
        </Form.Item>
        
        <Form.Item
          label="Version"
          name="version"
          rules={[{ required: true, message: 'Please input version!' }]}
        >
          <Input type="number" placeholder="1" />
        </Form.Item>
        
        <Form.Item>
          <Button type="primary" htmlType="submit" loading={loading} block>
            Create Proxy
          </Button>
        </Form.Item>
      </Form>
    </Card>
  );
}

export default CreateProxy;