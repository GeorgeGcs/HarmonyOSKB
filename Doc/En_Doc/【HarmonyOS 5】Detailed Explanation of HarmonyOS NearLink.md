## 【HarmonyOS 5】Detailed Explanation of HarmonyOS NearLink  

\## HarmonyOS Development Capabilities ## HarmonyOS SDK Application Services ## HarmonyOS Financial Applications (Financial Management #  


### 一、Preface  
The HarmonyOS NearLink Kit provides short-range communication services, supporting connections and data interaction between NearLink devices. For example, a mobile phone can act as a central device to connect with peripheral devices (such as mice, styluses, smart home appliances, car keys, etc.) via NearLink.  


### 二、Access and Usage of NearLink Kit  

[Click to jump to the official documentation address](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/nearlink-kit-guide)  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_daf1f8b0.png 'image.png')  


The following is a basic access code example for HarmonyOS NearLink, including core processes of device discovery, connection, and data transmission:  

```dart  
// NearLink device management service example  

import nearlink from '@ohos.nearlink';  
import nearlinkSle from '@ohos.nearlink.sle';  
import common from '@ohos.app.ability.common';  

// NearLink service management class  
export class NearLinkManager {  
  private context: common.UIAbilityContext | undefined;  
  private deviceManager: nearlinkSle.SleDeviceManager | undefined;  
  private connectedDeviceId: string | null = null;  
  private dataChannel: nearlinkSle.SleDataChannel | undefined;  
  
  constructor(context: common.UIAbilityContext) {  
    this.context = context;  
  }  
  
  // Initialize NearLink service  
  async initNearLinkService() {  
    try {  
      // Check and request NearLink permission  
      await this.checkAndRequestNearLinkPermission();  
      
      // Create device manager instance  
      this.deviceManager = await nearlinkSle.getSleDeviceManager(this.context!);  
      
      // Register device state change listener  
      this.registerDeviceStateListener();  
      
      console.info('NearLink service initialized successfully');  
    } catch (error) {  
      console.error(`Failed to initialize NearLink service: ${error}`);  
      throw error;  
    }  
  }  
  
  // Check and request NearLink permission  
  private async checkAndRequestNearLinkPermission() {  
    // Permission check logic  
    // ...  
  }  
  
  // Start scanning for nearby NearLink devices  
  async startDiscovery() {  
    if (!this.deviceManager) {  
      throw new Error('Device manager not initialized');  
    }  
    
    try {  
      // Configure scan parameters  
      const discoveryConfig = {  
        mode: nearlinkSle.SleDiscoveryMode.ACTIVE,  
        duration: 30, // Scan duration (seconds)  
        filter: {  
          deviceTypes: [nearlinkSle.SleDeviceType.ALL]  
        }  
      };  
      
      // Register device discovery callback  
      const callback = {  
        onDeviceFound: (device: nearlinkSle.SleDevice) => {  
          console.info(`Found device: ${device.deviceName}, type: ${device.deviceType}`);  
          // Process the discovered device, e.g., update UI  
          this.onDeviceDiscovered(device);  
        },  
        onDiscoveryStateChanged: (state: number) => {  
          console.info(`Discovery state changed: ${state}`);  
        }  
      };  
      
      // Start scanning  
      await this.deviceManager.startDiscovery(discoveryConfig, callback);  
      console.info('NearLink device discovery started');  
    } catch (error) {  
      console.error(`Failed to start discovery: ${error}`);  
      throw error;  
    }  
  }  
  
  // Process the discovered device  
  private onDeviceDiscovered(device: nearlinkSle.SleDevice) {  
    // Add device filtering logic here  
    // ...  
    
    // Notify UI to update device list  
    // ...  
  }  
  
  // Connect to the specified NearLink device  
  async connectToDevice(deviceId: string) {  
    if (!this.deviceManager) {  
      throw new Error('Device manager not initialized');  
    }  
    
    try {  
      // Create connection parameters  
      const connectParams = {  
        timeout: 10000, // Connection timeout (milliseconds)  
        connectionType: nearlinkSle.SleConnectionType.DATA_CHANNEL  
      };  
      
      // Connect to the device  
      const connectionResult = await this.deviceManager.connect(deviceId, connectParams);  
      if (connectionResult.resultCode === 0) {  
        this.connectedDeviceId = deviceId;  
        this.dataChannel = connectionResult.dataChannel;  
        console.info(`Connected to device: ${deviceId}`);  
        
        // Register data receive callback  
        this.registerDataReceiveListener();  
      } else {  
        console.error(`Failed to connect device, error code: ${connectionResult.resultCode}`);  
        throw new Error(`Connection failed: ${connectionResult.resultCode}`);  
      }  
    } catch (error) {  
      console.error(`Failed to connect device: ${error}`);  
      throw error;  
    }  
  }  
  
  // Register data receive listener  
  private registerDataReceiveListener() {  
    if (!this.dataChannel) return;  
    
    this.dataChannel.on('dataReceived', (data: ArrayBuffer) => {  
      // Process received data  
      const decoder = new TextDecoder();  
      const message = decoder.decode(data);  
      console.info(`Received data: ${message}`);  
      
      // Notify UI of new data arrival  
      // ...  
    });  
  }  
  
  // Send data to the connected device  
  async sendData(message: string) {  
    if (!this.dataChannel) {  
      throw new Error('Data channel not initialized');  
    }  
    
    try {  
      const encoder = new TextEncoder();  
      const data = encoder.encode(message).buffer;  
      
      // Send data  
      await this.dataChannel.send(data);  
      console.info(`Data sent successfully: ${message}`);  
    } catch (error) {  
      console.error(`Failed to send data: ${error}`);  
      throw error;  
    }  
  }  
  
  // Disconnect from the device  
  async disconnect() {  
    if (!this.deviceManager || !this.connectedDeviceId) return;  
    
    try {  
      await this.deviceManager.disconnect(this.connectedDeviceId);  
      this.connectedDeviceId = null;  
      this.dataChannel = undefined;  
      console.info('Device disconnected');  
    } catch (error) {  
      console.error(`Failed to disconnect device: ${error}`);  
      throw error;  
    }  
  }  
  
  // Register device state change listener  
  private registerDeviceStateListener() {  
    if (!this.deviceManager) return;  
    
    this.deviceManager.on('deviceStateChanged', (params) => {  
      console.info(`Device state changed: ${JSON.stringify(params)}`);  
      // Process device state changes  
      // ...  
    });  
  }  
  
  // Release resources  
  async release() {  
    await this.disconnect();  
    
    if (this.deviceManager) {  
      try {  
        await this.deviceManager.release();  
        console.info('NearLink resources released');  
      } catch (error) {  
        console.error(`Failed to release resources: ${error}`);  
      }  
    }  
  }  
}  
```  


### 三、Technical Indicator Comparison of HarmonyOS NearLink  

The following table compares HarmonyOS NearLink, Bluetooth, and NFC in terms of technical performance, application scenarios, cost, and ecosystem:  

| Comparison Item       | HarmonyOS NearLink                                                                 | Bluetooth                                                      | NFC                                   |  
|---------------------|--------------------------------------------------------------------------|--------------------------------------------------------------|-------------------------------------|  
| Transfer Rate         | Up to 2.5Gbps, peak rate in low-power mode reaches 12Mbps                                          | Bluetooth 5.2 has a transfer rate of 400Mbps; asynchronous connections allow data transfer rates of up to 721kbps in one direction and 57.6kbps in the reverse direction | No (data transfer rate is typically much lower than the former two)             |  
| Latency Performance   | Transmission latency as low as 20 microseconds, response latency 0.25ms                                            | Latency about 600 microseconds, response latency about 10ms                                        | No (mainly used for close-range quick interaction, latency indicators are not emphasized) |  
| Number of Connected Devices | Supports up to 4,096 devices connected simultaneously                                              | Generally can only connect 8 devices; one Bluetooth device can join 8 different piconets simultaneously                          | No (generally used for one-to-one quick connections, not emphasizing multi-device connections) |  
| Anti-Interference Capability | Adopts multiple anti-interference technologies, anti-interference capability improved by more than 10dB compared to Bluetooth                               | Adopts frequency-hopping spread spectrum technology, strong anti-interference, not easy to eavesdrop                             | No (short working distance, relatively small interference)                  |  
| Power Consumption     | Adopts advanced power management strategies, power consumption only 60% of Bluetooth                                     | Low power consumption, suitable for various low-power devices                                           | Low power consumption (short working time)                            |  
| Applications in Consumer Electronics | Enables high-definition lossless audio transmission and low-latency interactive experience, such as Huawei MatePad Pro 13.2-inch tablet and FreeBuds Pro 3 wireless headphones | Widely used for audio transmission in wireless headphones, speakers, and other devices                                   | Can be used for fast pairing and data transmission between devices, such as quick connection between mobile phones and speakers/headphones |  
| Applications in Smart Home | Enables seamless connection of multiple smart devices, supports more devices online simultaneously                                 | Used to connect smart home appliances for remote control and other functions                                    | Can quickly switch mobile phone modes or control smart home switches/modes via NFC tags         |  
| Applications in Smart Vehicles | Enables high-speed, low-latency data exchange between in-vehicle and external devices, enhancing the safety and efficiency of autonomous driving                     | Used to connect in-vehicle devices, such as in-vehicle Bluetooth calls and Bluetooth music playback                          | Can be used for car key functions, realizing vehicle unlocking/starting via mobile phone NFC       |  
| Applications in Industrial Manufacturing | Meets the needs of high-precision control and large data transmission, promoting the realization of Industry 4.0                              | Used for wireless connection between industrial devices, such as sensor data transmission                               | No (generally not used in industrial manufacturing scenarios)             |  
| Cost                | Costs of related solutions and chip modules are still relatively high                                           | Mature technology, low cost                                                  | Relatively low cost                          |  
| Ecosystem           | Ecosystem is not yet perfect, with relatively few devices supporting NearLink technology                                   | Has a huge and mature ecosystem, with almost all electronic devices supporting Bluetooth                               | Widely used in mobile payment, transportation, and other fields, with a relatively mature ecosystem |  
| Connection Method and Range | Coverage is about twice that of Bluetooth, with a conventional coverage distance of up to 20 meters; device connections require pairing and connection within a certain range               | General effective transmission distance is 10cm - 10m, which can reach 100m with increased transmission power; requires pairing and connection operations            | Very short working distance, generally within a few centimeters, usually used for close-range quick touch connections between devices |