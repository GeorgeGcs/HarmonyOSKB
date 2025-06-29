## 【HarmonyOS 5】敏感信息本地存储详解

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

### 前言

鸿蒙其实自身已经通过多层次的安全机制，确保用户敏感信息本地存储安全。不过再此基础上，用户敏感信息一般三方应用还需要再进行加密存储。

本文章会从鸿蒙自身的安全机制进行展开，最后再说明本地敏感信息常规存储的方案。

### 一、硬件级安全隔离与加密

**可信执行环境（TEE）**
TEE 作为独立的安全区域，与主操作系统隔离，用于存储加密密钥、生物特征模板等核心敏感数据。例如，用户指纹信息在 TEE 内完成验证，防止中间人攻击。
密钥管理：密钥生成、存储和使用均在 TEE 中完成。例如，AES 加密密钥通过硬件随机数生成器生成，并存储于 TEE 的安全存储区域，确保密钥不暴露于主系统。
**全盘加密（FDE）**
设备存储的所有数据默认加密，包括用户文件、应用数据等。即使设备丢失或被破解，攻击者也无法直接读取原始数据。
动态加密：数据在写入存储介质时实时加密，读取时自动解密，对用户透明。

### 二、软件层安全机制

**沙箱隔离**
每个应用拥有专属沙箱目录（/data/data/<包名>），其他应用无法直接访问。例如，银行应用的交易记录存储在沙箱内，社交应用无法读取。
**路径隔离**
应用只能访问自身沙箱内的文件，系统文件和其他应用数据被严格限制。
数据加密与密钥管理
**对称加密**
使用 AES 算法对本地文件、数据库等进行加密。例如，用户的聊天记录通过 AES-256 加密存储，密钥由 TEE 管理。
**非对称加密**
用于密钥交换和数字签名。例如，应用在跨设备同步数据时，使用 RSA 加密会话密钥，确保传输安全。
**密钥全生命周期管理**
密钥生成、分发、更新和销毁由系统统一管理。例如，定期轮换加密密钥，降低泄露风险。
**动态权限管理**
最小权限原则：应用仅能申请必要权限。例如，地图应用请求位置权限时，系统默认推荐模糊位置（1km 精度）替代精确位置。
**实时权限监控**
后台应用异常调用摄像头或麦克风时，系统触发 “隐私盾牌” 拦截，并通知用户。
权限透明化：用户可在控制中心查看应用 24 小时内的设备使用记录，包括摄像头、麦克风激活时长。

### 三、隐私增强技术

隐私空间
独立加密存储：用户可创建隐私空间，通过指纹或密码访问，存储高敏感数据（如身份证、银行卡信息）。隐私空间与主空间完全隔离，数据加密存储。
隐藏入口：隐私空间入口可隐藏，仅通过特定指纹或密码唤醒，提升隐蔽性。
安全擦除
物理销毁：删除数据时，系统采用安全擦除技术（如多次覆写），确保数据不可恢复。例如，用户删除聊天记录后，存储块被随机数据覆盖。
云端同步擦除：设备丢失时，用户可通过 “查找设备” 功能远程擦除本地数据，防止泄露。

### 四、分布式安全与合规

跨设备数据同步
加密传输：数据在设备间同步时，使用 TLS 协议加密。例如，手机与平板同步联系人时，数据通过 SSL 加密传输。
设备安全级别匹配：根据设备安全等级（如手机为 SL2，手表为 SL1），限制可同步的数据安全标签。例如，手表无法同步机密级数据。

### 五、开发者本地敏感信息存储方案

综上所述，鸿蒙通过硬件隔离、加密技术、动态权限、隐私空间等多维度安全机制，构建了端到端的敏感信息防护体系。其核心设计理念是 “最小权限、深度隔离、硬件加密、用户可控”，确保用户数据在存储、传输和使用过程中的安全性与隐私性。开发者可通过系统提供的安全 API 和工具链，便捷地实现符合最高安全标准的应用。

**1. 使用系统加密库对数据加密**
HarmonyOS 提供了加密和解密模块，支持 AES、RSA 等算法，详情参见官方文档：[加密/解密介绍及算法规格](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/huks-encryption-decryption-overview)


*   [ ] \- \[ ] - \[ ] - \[ ] 格式转化，请参考：[@ohos.util (util工具函数)](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-util#decodetostring12)
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_02c697e7.png 'image.png')

    金融业一般会通过国密或者三方加密SDK实现。操作逻辑一致，可参考加密逻辑。以首选项存储用户的id为例，下面是一个参考国密 SM2 加密方式，结合首选项存储，对本地存储用户 ID 进行加密和解密的完整 DEMO。这个 DEMO 会生成 SM2 密钥对，使用公钥加密用户 ID 并存储到首选项中，之后使用私钥从首选项读取加密数据并解密：

```javascript
import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { huks } from '@kit.UniversalKeystoreKit';
import { util } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';

// 首选项名称
const PRE_FS_NAME = 'user_id_storage';

// 加密算法枚举
enum EncryptionAlgorithm {
  SM2 = 'SM2',
  // 可根据需求添加更多算法
}

/**
 * 加密工具类
 */
class EncryptionUtils {
  private keyAlias: string;

  constructor(keyAlias: string) {
    this.keyAlias = keyAlias;
  }

  /**
   * 生成密钥
   * @param algorithm 加密算法
   */
  async generateKey(algorithm: EncryptionAlgorithm) {
    let properties: Array<huks.HuksParam>;
    switch (algorithm) {
      case EncryptionAlgorithm.SM2:
        properties = [
          {
            tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
            value: huks.HuksKeyAlg.HUKS_ALG_SM2
          },
          {
            tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
            value: huks.HuksKeySize.HUKS_SM2_KEY_SIZE_256
          },
          {
            tag: huks.HuksTag.HUKS_TAG_PURPOSE,
            value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT |
            huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT
          }
        ];
        break;
      default:
        throw new Error(`Unsupported algorithm: ${algorithm}`);
    }
    const options: huks.HuksOptions = {
      properties
    };
    await huks.generateKeyItem(this.keyAlias, options)
      .then((data) => {
        console.info(`Generate ${algorithm} key success, data = ${JSON.stringify(data)}`);
      })
      .catch((error: Error) => {
        console.error(`Generate ${algorithm} key failed, ${JSON.stringify(error)}`);
        throw error;
      });
  }

  /**
   * 加密数据
   * @param data 待加密的数据
   * @param algorithm 加密算法
   * @returns 加密后的数据
   */
  async encrypt(data: string, algorithm: EncryptionAlgorithm): Promise<string> {
    let properties: Array<huks.HuksParam>;
    switch (algorithm) {
      case EncryptionAlgorithm.SM2:
        properties = [
          {
            tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
            value: huks.HuksKeyAlg.HUKS_ALG_SM2
          },
          {
            tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
            value: huks.HuksKeySize.HUKS_SM2_KEY_SIZE_256
          },
          {
            tag: huks.HuksTag.HUKS_TAG_PURPOSE,
            value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT
          },
          {
            tag: huks.HuksTag.HUKS_TAG_DIGEST,
            value: huks.HuksKeyDigest.HUKS_DIGEST_SM3
          }
        ];
        break;
      default:
        throw new Error(`Unsupported algorithm: ${algorithm}`);
    }
    const options: huks.HuksOptions = {
      properties,
      inData: new Uint8Array(data.split('').map(c => c.charCodeAt(0)))
    };
    let handleObj = await huks.initSession(this.keyAlias, options)
    const result = await huks.finishSession(handleObj.handle, options)
      .catch((error: Error) => {
        console.error(`Finish ${algorithm} encryption session failed: ${JSON.stringify(error)}`);
        throw error;
      });

    let base64Helper = new util.Base64Helper();
    let retStr = base64Helper.encodeToStringSync(result.outData as Uint8Array);
    return retStr;
  }

  /**
   * 解密数据
   * @param encryptedData 加密后的数据
   * @param algorithm 加密算法
   * @returns 解密后的数据
   */
  async decrypt(encryptedData: string, algorithm: EncryptionAlgorithm): Promise<string> {
    let properties: Array<huks.HuksParam>;
    switch (algorithm) {
      case EncryptionAlgorithm.SM2:
        properties = [
          {
            tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
            value: huks.HuksKeyAlg.HUKS_ALG_SM2
          },
          {
            tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
            value: huks.HuksKeySize.HUKS_SM2_KEY_SIZE_256
          },
          {
            tag: huks.HuksTag.HUKS_TAG_PURPOSE,
            value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT
          },
          {
            tag: huks.HuksTag.HUKS_TAG_DIGEST,
            value: huks.HuksKeyDigest.HUKS_DIGEST_SM3
          }
        ];
        break;
      default:
        throw new Error(`Unsupported algorithm: ${algorithm}`);
    }
    let base64Helper = new util.Base64Helper();
    let inData = base64Helper.decodeSync(encryptedData);
    const options: huks.HuksOptions = {
      properties,
      inData
    };
    let handleObj = await huks.initSession(this.keyAlias, options)
    const result = await huks.finishSession(handleObj.handle, options)
      .catch((error: Error) => {
        console.error(`Finish ${algorithm} decryption session failed: ${JSON.stringify(error)}`);
        throw error;
      });

    let retStr = base64Helper.encodeToStringSync(result.outData as Uint8Array);
    return retStr;
  }
}

/**
 * 首选项工具类
 */
class PreferencesUtils {
  private preFs: preferences.Preferences | null = null;
  private context: common.UIAbilityContext;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  /**
   * 初始化首选项实例
   */
  async init() {
    let options: preferences.Options = { name: PRE_FS_NAME };
    this.preFs = preferences.getPreferencesSync(this.context, options);
  }

  /**
   * 存储数据
   * @param key 键
   * @param value 值
   */
  async put(key: string, value: string) {
    await this.preFs?.put(key, value)
      .then(() => console.info(`数据 ${key} 存储成功`))
      .catch((err: BusinessError) => {
        console.error(`存储失败: ${err.code}, ${err.message}`);
      });
    await this.preFs?.flush();
  }

  /**
   * 读取数据
   * @param key 键
   * @returns 值或 null
   */
  async get(key: string): Promise<preferences.ValueType> {
    let res = await this.preFs?.get(key, 'default') ?? "";
    return res;
  }
}

```
