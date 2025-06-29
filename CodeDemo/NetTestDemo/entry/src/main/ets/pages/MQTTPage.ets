import { MqttAsync } from '@ohos/mqtt';

@Entry
@Component
struct MQTTPage {

  aboutToAppear(): void {
    this.initMQTT();
  }

  async initMQTT() {
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


  @State message: string = 'Hello World';

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('MQTTPageHelloWorld')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
          this.message = 'Welcome';
        })
    }
    .height('100%')
    .width('100%')
  }
}