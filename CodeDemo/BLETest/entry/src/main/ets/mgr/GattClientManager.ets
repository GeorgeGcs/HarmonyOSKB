import { ble } from '@kit.ConnectivityKit';
import { constant } from '@kit.ConnectivityKit';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { EventHubUtils } from '../utils/EventHubUtils';

const TAG: string = 'GattClientManager';

export class GattClientManager {
  device: string | undefined = undefined;
  gattClient: ble.GattClientDevice | undefined = undefined;
  connectState: ble.ProfileConnectionState = constant.ProfileConnectionState.STATE_DISCONNECTED;
  myServiceUuid: string = '00001801-0000-1000-8000-00805F9B34FB';
  myCharacteristicUuid: string = '00002A05-0000-1000-8000-00805F9B34FB';
  myFirstDescriptorUuid: string = '00002902-0000-1000-8000-00805F9B34FB'; // 2902一般用于notification或者indication
  mySecondDescriptorUuid: string = '00002903-0000-1000-8000-00805F9B34FB';
  found: boolean = false;

  // 构造BLEDescriptor
  private initDescriptor(des: string, value: ArrayBuffer): ble.BLEDescriptor {
    let descriptor: ble.BLEDescriptor = {
      serviceUuid: this.myServiceUuid,
      characteristicUuid: this.myCharacteristicUuid,
      descriptorUuid: des,
      descriptorValue: value
    };
    return descriptor;
  }

  // 构造BLECharacteristic
  private initCharacteristic(): ble.BLECharacteristic {
    let descriptors: Array<ble.BLEDescriptor> = [];
    let descBuffer = new ArrayBuffer(2);
    let descValue = new Uint8Array(descBuffer);
    descValue[0] = 11;
    descValue[1] = 12;
    descriptors[0] = this.initDescriptor(this.myFirstDescriptorUuid, new ArrayBuffer(2));
    descriptors[1] = this.initDescriptor(this.mySecondDescriptorUuid, descBuffer);
    let charBuffer = new ArrayBuffer(2);
    let charValue = new Uint8Array(charBuffer);
    charValue[0] = 1;
    charValue[1] = 2;
    let characteristic: ble.BLECharacteristic = {
      serviceUuid: this.myServiceUuid,
      characteristicUuid: this.myCharacteristicUuid,
      characteristicValue: charBuffer,
      descriptors: descriptors
    };
    return characteristic;
  }

  private logCharacteristic(char: ble.BLECharacteristic) {
    let message = 'logCharacteristic uuid:' + char.characteristicUuid + '\n';
    let value = new Uint8Array(char.characteristicValue);
    message += 'logCharacteristic value: ';
    for (let i = 0; i < char.characteristicValue.byteLength; i++) {
      message += value[i] + ' ';
    }
    console.info(TAG, message);
  }

  private logDescriptor(des: ble.BLEDescriptor) {
    let message = 'logDescriptor uuid:' + des.descriptorUuid + '\n';
    let value = new Uint8Array(des.descriptorValue);
    message += 'logDescriptor value: ';
    for (let i = 0; i < des.descriptorValue.byteLength; i++) {
      message += value[i] + ' ';
    }
    console.info(TAG, message);
  }

  private checkService(services: Array<ble.GattService>): boolean {
    for (let i = 0; i < services.length; i++) {
      if (services[i].serviceUuid != this.myServiceUuid) {
        continue;
      }
      for (let j = 0; j < services[i].characteristics.length; j++) {
        if (services[i].characteristics[j].characteristicUuid != this.myCharacteristicUuid) {
          continue;
        }
        for (let k = 0; k < services[i].characteristics[j].descriptors.length; k++) {
          if (services[i].characteristics[j].descriptors[k].descriptorUuid == this.myFirstDescriptorUuid) {
            console.info(TAG, 'find expected service from server');
            return true;
          }
        }
      }
    }
    console.error(TAG, 'no expected service from server');
    return false;
  }

  // 1. 订阅连接状态变化事件
  public onGattClientStateChange() {
    if (!this.gattClient) {
      console.error(TAG, 'no gattClient');
      return;
    }
    try {
      this.gattClient.on('BLEConnectionStateChange', (stateInfo: ble.BLEConnectionChangeState) => {
        let state = '';
        switch (stateInfo.state) {
          case 0:
            state = 'DISCONNECTED';
            break;
          case 1:
            state = 'CONNECTING';
            break;
          case 2:
            state = 'CONNECTED';
            break;
          case 3:
            state = 'DISCONNECTING';
            break;
          default:
            state = 'undefined';
            break;
        }
        console.info(TAG, 'onGattClientStateChange: device=' + stateInfo.deviceId + ', state=' + state);
        if (stateInfo.deviceId == this.device) {
          this.connectState = stateInfo.state;
          EventHubUtils.getEventHub().emit("ConnStateChange", state);
        }
      });
    } catch (err) {
      console.error(TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  // 2. client端主动连接时调用
  public startConnect(peerDevice: string) { // 对端设备一般通过ble scan获取到
    if (this.connectState != constant.ProfileConnectionState.STATE_DISCONNECTED) {
      console.error(TAG, 'startConnect failed');
      return;
    }
    console.info(TAG, 'startConnect ' + peerDevice);
    this.device = peerDevice;
    // 2.1 使用device构造gattClient，后续的交互都需要使用该实例
    this.gattClient = ble.createGattClientDevice(peerDevice);
    try {
      this.onGattClientStateChange(); // 2.2 订阅连接状态
      this.gattClient.connect(); // 2.3 发起连接
    } catch (err) {
      console.error(TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  // 3. client端连接成功后，需要进行服务发现
  public discoverServices() {
    if (!this.gattClient) {
      console.info(TAG, 'no gattClient');
      return;
    }
    console.info(TAG, 'discoverServices');
    try {
      this.gattClient.getServices().then((result: Array<ble.GattService>) => {
        console.info(TAG, 'getServices success: ' + JSON.stringify(result));
        this.found = this.checkService(result); // 要确保server端的服务内容有业务所需要的服务
      });
    } catch (err) {
      console.error(TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  // 4. 在确保拿到了server端的服务结果后，读取server端特定服务的特征值时调用
  public readCharacteristicValue() {
    if (!this.gattClient || this.connectState != constant.ProfileConnectionState.STATE_CONNECTED) {
      console.error(TAG, 'no gattClient or not connected');
      return;
    }
    if (!this.found) { // 要确保server端有对应的characteristic
      console.error(TAG, 'no characteristic from server');
      return;
    }

    let characteristic = this.initCharacteristic();
    console.info(TAG, 'readCharacteristicValue');
    try {
      this.gattClient.readCharacteristicValue(characteristic).then((outData: ble.BLECharacteristic) => {
        this.logCharacteristic(outData);
      })
    } catch (err) {
      console.error(TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  // 5. 在确保拿到了server端的服务结果后，写入server端特定服务的特征值时调用
  public writeCharacteristicValue() {
    if (!this.gattClient || this.connectState != constant.ProfileConnectionState.STATE_CONNECTED) {
      console.error(TAG, 'no gattClient or not connected');
      return;
    }
    if (!this.found) { // 要确保server端有对应的characteristic
      console.error(TAG, 'no characteristic from server');
      return;
    }

    let characteristic = this.initCharacteristic();
    console.info(TAG, 'writeCharacteristicValue');
    try {
      this.gattClient.writeCharacteristicValue(characteristic, ble.GattWriteType.WRITE, (err) => {
        if (err) {
          console.error(TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
          return;
        }
        console.info(TAG, 'writeCharacteristicValue success');
      });
    } catch (err) {
      console.error(TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  // 6. 在确保拿到了server端的服务结果后，读取server端特定服务的描述符时调用
  public readDescriptorValue() {
    if (!this.gattClient || this.connectState != constant.ProfileConnectionState.STATE_CONNECTED) {
      console.error(TAG, 'no gattClient or not connected');
      return;
    }
    if (!this.found) { // 要确保server端有对应的descriptor
      console.error(TAG, 'no descriptor from server');
      return;
    }

    let descBuffer = new ArrayBuffer(0);
    let descriptor = this.initDescriptor(this.mySecondDescriptorUuid, descBuffer);
    console.info(TAG, 'readDescriptorValue');
    try {
      this.gattClient.readDescriptorValue(descriptor).then((outData: ble.BLEDescriptor) => {
        this.logDescriptor(outData);
      });
    } catch (err) {
      console.error(TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  // 7. 在确保拿到了server端的服务结果后，写入server端特定服务的描述符时调用
  public writeDescriptorValue() {
    if (!this.gattClient || this.connectState != constant.ProfileConnectionState.STATE_CONNECTED) {
      console.error(TAG, 'no gattClient or not connected');
      return;
    }
    if (!this.found) { // 要确保server端有对应的descriptor
      console.error(TAG, 'no descriptor from server');
      return;
    }

    let descBuffer = new ArrayBuffer(2);
    let descValue = new Uint8Array(descBuffer);
    descValue[0] = 11;
    descValue[1] = 12;
    let descriptor = this.initDescriptor(this.mySecondDescriptorUuid, descBuffer);
    console.info(TAG, 'writeDescriptorValue');
    try {
      this.gattClient.writeDescriptorValue(descriptor, (err) => {
        if (err) {
          console.error(TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
          return;
        }
        console.info(TAG, 'writeDescriptorValue success');
      });
    } catch (err) {
      console.error(TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  // 8.client端主动断开时调用
  public stopConnect() {
    if (!this.gattClient || this.connectState != constant.ProfileConnectionState.STATE_CONNECTED) {
      console.error(TAG, 'no gattClient or not connected');
      return;
    }

    console.info(TAG, 'stopConnect ' + this.device);
    try {
      this.gattClient.disconnect(); // 8.1 断开连接
      this.gattClient.off('BLEConnectionStateChange', (stateInfo: ble.BLEConnectionChangeState) => {
      });
      this.gattClient.close() // 8.2 如果不再使用此gattClient，则需要close
    } catch (err) {
      console.error(TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }
}

let gattClientManager = new GattClientManager();
export default gattClientManager as GattClientManager;