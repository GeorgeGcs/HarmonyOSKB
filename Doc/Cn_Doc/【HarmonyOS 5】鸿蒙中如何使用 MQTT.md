【HarmonyOS 5】鸿蒙中如何使用MQTT

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

### 一、MQTT是什么？

MQTT（Message Queuing Telemetry Transport，消息队列遥测传输）是一种轻量级、基于发布 / 订阅（Publish/Subscribe）模式的即时通讯协议，专为资源受限的物联网（IoT）设备和低带宽、高延迟或不可靠网络环境设计。

目前在物联网，车载，即时通讯，JG领域用的很多。MQTT模式是有个服务器，若干个客户端，订阅Topic作为事件ID，用来订阅广播，发送广播。类似于EventHub和Emitter的发布订阅机制。使用起来很简单。

### 二、MQTT在鸿蒙中怎么使用？

在鸿蒙（HarmonyOS）中使用MQTT协议主要通过官方提供的@ohos/mqtt库实现。
<https://ohpm.openharmony.cn/#/cn/detail/@ohos%2Fmqtt>
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_fd78ec12.png 'image.png')

配置依赖：

```typescript
ohpm install @ohos/mqtt

或者在oh-package.json5中配置：

  "dependencies": {
        "@ohos/mqtt":"2.0.18",
  }
```

记得配置网络权限：

```typescript
在module.json5中配置：
    "requestPermissions":[
      {
        "name" : "ohos.permission.INTERNET",
        "reason": "$string:reason_net",
        "usedScene": {
          "abilities": [
            "FormAbility"
          ],
          "when":"inuse"
        }
      }
    ]
```

1.  创建MQTT客户端
    @ohos/mqtt 库的官方文档，该库提供了 同步（MqttClient） 和 异步（MqttAsync） 两种客户端实现。推荐使用 异步客户端（MqttAsync） 以适配 HarmonyOS 的异步编程模型。

```typescript
import { MqttAsync, MqttConnectOptions } from '@ohos/mqtt';

// 初始化客户端
const mqttClient = MqttAsync.createMqtt({
  clientId: 'device_001', // 唯一客户端ID
  persistenceType: 1, // 内存持久化
});

// 连接参数配置
const connectOptions: MqttConnectOptions = {
  connectTimeout: 30, // 连接超时时间（秒）
  keepAliveInterval: 60, // 心跳间隔（秒）
  username: 'user', // 用户名（可选）
  password: 'password', // 密码（可选）
  cleanStart: true, // 清除会话
  // 若使用TLS，需配置证书
  // enableServerCertAuth: true,
  // caFile: 'ca.crt',
  // clientCertFile: 'device.crt',
  // clientKeyFile: 'device.key',
};
```

2.  MQTT的连接与断开

```javascript
// 异步回调方式
mqttClient.connect(connectOptions, (err, data) => {
  if (err) {
    console.error('连接失败:', err);
    return;
  }
  console.log('连接成功:', data);
});

// Promise方式
mqttClient.connect(connectOptions)
  .then(data => console.log('连接成功:', data))
  .catch(err => console.error('连接失败:', err));

// 断开连接
mqttClient.disconnect();
```

3.  发布和订阅消息

```javascript
const publishOptions = {
  topic: 'home/temperature',
  qos: 1, // 服务质量等级（0/1/2）
  payload: JSON.stringify({ value: 25.5 }), // 消息负载
  // 可选：设置消息过期时间（毫秒）
  // messageExpiryInterval: 3600000,
};

// 异步回调方式
mqttClient.publish(publishOptions, (err, data) => {
  if (err) {
    console.error('消息发布失败:', err);
    return;
  }
  console.log('消息发布成功:', data);
});

// Promise方式
mqttClient.publish(publishOptions)
  .then(data => console.log('消息发布成功:', data))
  .catch(err => console.error('消息发布失败:', err));


const subscribeOptions = {
  topic: 'home/temperature',
  qos: 1, // 服务质量等级
};

// 订阅并设置消息回调
mqttClient.subscribe(subscribeOptions, (err, data) => {
  if (err) {
    console.error('订阅失败:', err);
    return;
  }
  console.log('订阅成功:', data);
});

// 接收消息的回调
mqttClient.on('message', (topic, payload) => {
  console.log(`收到消息 [${topic}]:`, payload);
  // 处理消息负载（如解析JSON）
  const data = JSON.parse(payload.toString());
  // 更新UI或业务逻辑
});
```

### 三、源码DEMO示例：

```typescript
import { MqttAsync } from '@ohos/mqtt';

// ---------------------- 基础配置（MQTT 3.1.1 协议） ----------------------
const BROKER_URL = 'mqtt://test.mosquitto.org:1883'; // 公共测试Broker（支持MQTT 3.1.1）
const CLIENT_ID = 'HarmonyOS-MQTT3-Demo';           // 客户端ID（需唯一）
const TOPIC = 'harmonyos/classic/test';             // 订阅/发布主题
const QOS = 1;                                      // 服务质量等级（0/1/2）

// ---------------------- 创建异步客户端 ----------------------
    let client = MqttAsync.createMqtt({
      url: BROKER_URL,
      clientId: CLIENT_ID,
      // 客户端持久化类型（0=文件系统，1=内存，2=自定义）
      persistenceType: 1 // 使用内存持久化（轻量设备推荐）
    })

// ---------------------- 核心功能实现 ----------------------
async function mqttCommunication() {
  try {
    // 1. 连接到Broker（异步方法，返回Promise）
    await client.connect({
      // MQTT 3.1.1 连接参数
      cleanSession: true,       // 清除会话（断开后不保留订阅和消息）
      connectTimeout: 30,       // 连接超时时间（秒）
      keepAliveInterval: 60,    // 心跳间隔（秒），维持长连接
      // 认证信息（若Broker需要）
      userName: 'user',         // 用户名（可选）
      password: 'password',     // 密码（可选）
    });
    console.log('[MQTT 3.1.1] 连接成功');

    // 2. 订阅主题（支持通配符，如 "home/+/temp"）
      await client.subscribe({
        topic: TOPIC,
        qos: QOS
      });
    console.log(`[MQTT 3.1.1] 已订阅主题：${TOPIC}（QoS ${QOS}）`);

    // 3. 发布消息（字符串或二进制 payload）
    const message = 'Hello from HarmonyOS with MQTT 3.1.1!';
    await client.publish({
      topic: TOPIC,
      payload: message,
      qos: QOS,
      retained: false, // 是否保留消息（Broker存储最后一条消息）
    });
    console.log(`[MQTT 3.1.1] 消息已发布：${message}`);

    // 4. 监听消息接收事件
      client.subscribe({
        topic: TOPIC,
        qos: QOS,
      },(MqttResponse)=>{
        console.log(`[接收消息] 主题：${MqttResponse}`);
      })


  } catch (err) {
    console.error('[MQTT 3.1.1] 操作失败:', err.message);
  }
}

// ---------------------- 启动连接 ----------------------
mqttCommunication();

// ---------------------- 断开连接（如页面销毁时调用） ----------------------
// client.disconnect();
```
