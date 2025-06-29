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
