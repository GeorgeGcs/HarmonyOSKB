# 【HarmonyOS 5】How to Use MQTT in HarmonyOS  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services##HarmonyOS Financial Applications (Financial Management#  


### 一、What is MQTT?  

MQTT (Message Queuing Telemetry Transport) is a lightweight, publish/subscribe-based instant messaging protocol specifically designed for resource-constrained IoT (Internet of Things) devices and low-bandwidth, high-latency, or unreliable network environments.  


#### Core Features:  
- **Lightweight**: Minimal protocol overhead, suitable for low-power devices and weak network environments.  
- **Publish/Subscribe Model**: Clients are decoupled via topics (Topics), supporting one-to-many communication.  
- **Quality of Service (QoS)**: Provides 3 levels of message delivery assurance (QoS 0, 1, 2) to ensure message reliability.  
- **Last Will and Testament (LWT)**: Automatically publishes a specified message when a client disconnects abnormally.  


#### Application Scenarios:  
- **IoT device communication**: Sensor data reporting, remote device control.  
- **Financial real-time quote pushing**: Stock market data, transaction notifications.  
- **Instant messaging**: Message pushing, online status synchronization.  
- **Vehicle networking**: Vehicle status monitoring, remote diagnosis.  


### 二、Integration and Usage of MQTT in HarmonyOS  


#### 1. Environment Preparation and Dependency Configuration  

##### (1) Install the MQTT Library  
Install the official MQTT library via ohpm:  
```bash
ohpm install @ohos/mqtt
```  
Or configure dependencies in `oh-package.json5`:  
```json5
{
  "dependencies": {
    "@ohos/mqtt": "2.0.18"
  }
}
```  

##### (2) Configure Network Permissions  
Add network permission application in `module.json5`:  
```json5
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.INTERNET",
        "reason": "$string:reason_net",
        "usedScene": {
          "abilities": ["MainAbility"],
          "when": "inuse"
        }
      }
    ]
  }
}
```  


#### 2. Create and Configure MQTT Client  

HarmonyOS provides `MqttAsync` asynchronous client (recommended) and `MqttClient` synchronous client. The following uses the asynchronous client as an example:  

```typescript
import { MqttAsync, MqttConnectOptions } from '@ohos/mqtt';

// 1. Initialize the client (recommended to create in UIAbility or a global singleton)
const mqttClient = MqttAsync.createMqtt({
  url: 'mqtt://broker.example.com:1883', // MQTT server address (TCP default port 1883, SSL default 8883)
  clientId: 'harmonyos_device_001',       // Unique client identifier (must be globally unique)
  persistenceType: 1,                     // Persistence type (0=file system, 1=memory, 2=custom)
});

// 2. Connection parameter configuration (supports MQTT 3.1.1/5.0 protocols)
const connectOptions: MqttConnectOptions = {
  // Basic connection parameters
  connectTimeout: 30,         // Connection timeout (seconds)
  keepAliveInterval: 60,      // Keep-alive interval (seconds) to maintain long connection
  cleanStart: true,           // Clear session (does not retain subscriptions and incomplete messages after disconnection)
  
  // Authentication information (if required by the server)
  username: 'finance_user',
  password: '************',
  
  // MQTT 5.0 extended parameters (optional)
  // sessionExpiryInterval: 86400,       // Session expiry time (seconds)
  // receiveMaximum: 100,                 // Maximum receive message length
  // topicAliasMaximum: 512,             // Maximum topic alias value
  // requestProblemInformation: true,    // Request problem information
};

// 3. Secure connection configuration (TLS/SSL)
const tlsOptions = {
  enableServerCertAuth: true,  // Enable server certificate verification
  caFile: '/sdcard/ca.crt',    // CA root certificate path
  clientCertFile: '/sdcard/client.crt', // Client certificate path (optional)
  clientKeyFile: '/sdcard/client.key',   // Client private key path (optional)
};
```  


#### 3. Connect and Disconnect  

```typescript
// Asynchronous connection (Promise way)
async function connectToMqtt() {
  try {
    await mqttClient.connect(connectOptions);
    console.log('[MQTT] Successfully connected to the broker');
    
    // Handle connection success logic (e.g., subscribe to topics)
    await subscribeToTopics();
    
  } catch (err) {
    console.error('[MQTT] Connection failed:', err);
  }
}

// Disconnect
function disconnectFromMqtt() {
  mqttClient.disconnect()
    .then(() => console.log('[MQTT] Disconnected successfully'))
    .catch(err => console.error('[MQTT] Disconnection failed:', err));
}

// Event listening for connection status changes
mqttClient.on('connectionLost', (error) => {
  console.warn('[MQTT] Connection lost:', error);
  // Handle reconnection logic (e.g., retry after delay)
  setTimeout(connectToMqtt, 5000);
});
```  


#### 4. Publish and Subscribe to Messages  

##### (1) Publish Messages  
```typescript
// Message publishing parameters
const publishOptions = {
  topic: 'finance/stock/quotes',  // Target topic (support wildcards like 'finance/+/quotes')
  qos: 1,                         // Quality of Service (0/1/2)
  payload: JSON.stringify({       // Message payload (string or binary)
    symbol: 'AAPL',
    price: 185.50,
    timestamp: new Date().toISOString()
  }),
  retained: false,                // Whether to retain the message (broker stores the last message)
  // messageExpiryInterval: 3600000, // Message expiry time (milliseconds, MQTT 5.0)
};

// Publish message asynchronously (Promise way)
async function publishMessage() {
  try {
    const result = await mqttClient.publish(publishOptions);
    console.log('[MQTT] Message published successfully:', result);
  } catch (err) {
    console.error('[MQTT] Message publishing failed:', err);
  }
}

// Publish message with callback
mqttClient.publish(publishOptions, (err, data) => {
  if (err) {
    console.error('[MQTT] Message publishing failed:', err);
    return;
  }
  console.log('[MQTT] Message published successfully:', data);
});
```  

##### (2) Subscribe to Messages  
```typescript
// Subscription parameters
const subscribeOptions = {
  topic: 'finance/stock/updates', // Topic to subscribe to
  qos: 1,                         // Quality of Service
};

// Subscribe asynchronously (Promise way)
async function subscribeToTopics() {
  try {
    const result = await mqttClient.subscribe(subscribeOptions);
    console.log(`[MQTT] Successfully subscribed to topic: ${subscribeOptions.topic}`);
    
    // Set up message reception callback
    setupMessageListener();
    
  } catch (err) {
    console.error('[MQTT] Subscription failed:', err);
  }
}

// Set up message reception callback
function setupMessageListener() {
  mqttClient.on('message', (topic, payload) => {
    try {
      // Parse message payload (e.g., JSON)
      const messageData = JSON.parse(payload.toString());
      console.log(`[MQTT] Received message on topic [${topic}]:`, messageData);
      
      // Handle business logic (e.g., update UI, process data)
      processStockUpdate(messageData);
      
    } catch (parseErr) {
      console.error('[MQTT] Message parsing failed:', parseErr, payload.toString());
    }
  });
  
  // Handle subscription failure events
  mqttClient.on('subackError', (error) => {
    console.error('[MQTT] Subscription acknowledgment failed:', error);
  });
}

// Unsubscribe from topics
function unsubscribeFromTopics() {
  mqttClient.unsubscribe('finance/stock/updates')
    .then(() => console.log('[MQTT] Unsubscribed successfully'))
    .catch(err => console.error('[MQTT] Unsubscription failed:', err));
}
```  


#### 5. Complete Source Code Demo (MQTT 3.1.1 Protocol)  

```typescript
import { MqttAsync } from '@ohos/mqtt';

// ---------------------- Basic Configuration (MQTT 3.1.1 Protocol) ----------------------
const BROKER_URL = 'mqtt://test.mosquitto.org:1883'; // Public test broker (supports MQTT 3.1.1)
const CLIENT_ID = 'HarmonyOS-MQTT-Demo';            // Client ID (must be unique)
const TOPIC = 'harmonyos/finance/test';             // Subscription/publishing topic
const QOS = 1;                                      // Quality of Service (0/1/2)

// ---------------------- Create Asynchronous Client ----------------------
let mqttClient = MqttAsync.createMqtt({
  url: BROKER_URL,
  clientId: CLIENT_ID,
  persistenceType: 1 // Use memory persistence (recommended for lightweight devices)
});

// ---------------------- Core Function Implementation ----------------------
async function mqttCommunication() {
  try {
    // 1. Connect to the broker (asynchronous method, returns Promise)
    await mqttClient.connect({
      cleanSession: true,       // Clear session (does not retain subscriptions after disconnection)
      connectTimeout: 30,       // Connection timeout (seconds)
      keepAliveInterval: 60,    // Keep-alive interval (seconds)
      userName: 'guest',        // Username (optional, public broker may not require it)
      password: 'guest'         // Password (optional)
    });
    console.log('[MQTT] Connection successful');

    // 2. Subscribe to topics (supports wildcards, e.g., "finance/+/updates")
    await mqttClient.subscribe({
      topic: TOPIC,
      qos: QOS
    });
    console.log(`[MQTT] Subscribed to topic: ${TOPIC} (QoS ${QOS})`);

    // 3. Set up message reception callback
    mqttClient.on('message', (topic, payload) => {
      const message = payload.toString();
      console.log(`[MQTT] Received message on [${topic}]: ${message}`);
      // Example: Update UI with received data
      updateUIWithMessage(message);
    });

    // 4. Publish messages periodically (e.g., device status reporting)
    setInterval(() => {
      const statusMessage = JSON.stringify({
        deviceId: CLIENT_ID,
        timestamp: new Date().toISOString(),
        status: 'online'
      });
      mqttClient.publish({
        topic: TOPIC,
        payload: statusMessage,
        qos: QOS
      }).catch(err => console.error('[MQTT] Periodic publish failed:', err));
    }, 30000); // Publish every 30 seconds

  } catch (err) {
    console.error('[MQTT] Operation failed:', err.message);
  }
}

// ---------------------- UI Update Example ----------------------
function updateUIWithMessage(message: string) {
  // In a real scenario, this would update UI components
  console.log('[UI] Updating with message:', message);
  // For example:
  // this.uiElement.textContent = message;
}

// ---------------------- Start Connection ----------------------
mqttCommunication();

// ---------------------- Disconnect (call when page is destroyed) ----------------------
// mqttClient.disconnect();
```  


### 三、Key Considerations for MQTT Development in HarmonyOS  

#### 1. QoS Level Selection  
- **QoS 0 (At most once)**: Minimum overhead, suitable for real-time data with low reliability requirements (e.g., sensor data).  
- **QoS 1 (At least once)**: Ensures message delivery, may result in duplicate messages (recommended for general business scenarios).  
- **QoS 2 (Exactly once)**: Highest reliability, suitable for financial transactions and other critical scenarios.  

#### 2. Keep-Alive and Reconnection Strategies  
- **Keep-Alive Interval**: Recommend setting it to 60-120 seconds to balance network consumption and connection stability.  
- **Reconnection Logic**: Implement exponential backoff retries (e.g., 1s, 2s, 4s, 8s...) to avoid frequent reconnection attempts.  

#### 3. Security Best Practices  
- **TLS/SSL Encryption**: Always use secure connections in production environments to protect data.  
- **Client Authentication**: Use username/password, client certificates, or JWT tokens for authentication.  
- **Topic Access Control**: Configure broker-side ACL (Access Control List) to restrict topic publishing/subscription permissions.  

#### 4. Memory and Performance Optimization  
- **Persistence Selection**: Use file system persistence for devices with sufficient storage; use memory persistence for lightweight devices.  
- **Message Payload**: Minimize payload size (e.g., use Protocol Buffers instead of JSON for binary data).  
- **Connection Cleanup**: Properly release resources in `onDestroy` of UIAbility to avoid memory leaks.  


### 四、Troubleshooting Common Issues  

| Issue | Possible Cause | Solution |
|-------------------|----------------|----------|
| Connection failed | Incorrect broker URL/port | Verify broker address and port (TCP: 1883, SSL: 8883). |
| Message loss | QoS configuration error | Use QoS 1 or 2 for critical messages. |
| Frequent reconnections | Unstable network/keep-alive timeout | Adjust keep-alive interval; implement robust reconnection logic. |
| TLS handshake failure | Invalid certificate | Ensure CA certificate and client certificate paths are correct. |
| Client ID conflict | Duplicate client ID | Generate a unique client ID (e.g., combine device ID and timestamp). |


### 五、Recommended Tools for Development and Testing  

1. **Public Test Brokers**:  
   - [Eclipse Mosquitto](https://test.mosquitto.org/) (MQTT 3.1.1)  
   - [HiveMQ Cloud](https://www.hivemq.com/cloud/) (Supports MQTT 5.0)  

2. **Desktop Clients**:  
   - [MQTT.fx](https://mqttfx.jensd.de/) (Cross-platform graphical client)  
   - [Mosquitto CLI Tools](https://mosquitto.org/download/) (Command-line tools for testing)  

3. **Network Debugging**:  
   - [Wireshark](https://www.wireshark.org/) (Capture and analyze MQTT packets)  


By following the above practices, you can efficiently implement MQTT communication in HarmonyOS applications, suitable for scenarios such as financial data pushing, IoT device management, and real-time messaging.