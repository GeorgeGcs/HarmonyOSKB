import { ble } from '@kit.ConnectivityKit';
import { BusinessError } from '@kit.BasicServicesKit';


const TAG: string = 'BleAdvertisingManager';

export class BleAdvertisingManager {

  myServiceUuid: string = '00001810-0000-1000-8000-00805F9B34FB'; // 00001888-0000-1000-8000-00805f9b34fb 00001810-0000-1000-8000-00805F9B34F
  private advHandle: number = 0xFF; // default invalid value

  // 1 订阅广播状态
  public onAdvertisingStateChange(callBack: (state: number) => void) {
    try {
      ble.on('advertisingStateChange', (data: ble.AdvertisingStateChangeInfo) => {
        console.info(TAG, 'bluetooth advertising state = ' + JSON.stringify(data));
        AppStorage.setOrCreate('advertiserState', data.state);
        callBack(data.state);
      });
    } catch (err) {
      callBack((err as BusinessError).code);
      console.error(TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  // 2 首次启动广播
  public async startAdvertising(callBack: (state: number) => void) {
    // 2.1 设置广播发送的参数
    let setting: ble.AdvertiseSetting = {
      interval: 160,
      txPower: 0,
      connectable: true
    };
    // 2.2 构造广播数据
    let manufactureValueBuffer = new Uint8Array(1);
    manufactureValueBuffer[0] = 1;
    // manufactureValueBuffer[1] = 2;
    // manufactureValueBuffer[2] = 3;
    // manufactureValueBuffer[3] = 4;
    let serviceValueBuffer = new Uint8Array(1);
    serviceValueBuffer[0] = 5;
    // serviceValueBuffer[1] = 6;
    // serviceValueBuffer[2] = 7;
    // serviceValueBuffer[3] = 8;
    let manufactureDataUnit: ble.ManufactureData = {
      manufactureId: 4567,
      manufactureValue: manufactureValueBuffer.buffer
    };
    let serviceDataUnit: ble.ServiceData = {
      serviceUuid: this.myServiceUuid,
      serviceValue: serviceValueBuffer.buffer
    };
    let advData: ble.AdvertiseData = {
      serviceUuids: [this.myServiceUuid],
      manufactureData: [manufactureDataUnit],
      serviceData: [serviceDataUnit],
      includeDeviceName: true // 表示是否携带设备名，可选参数。注意带上设备名时广播包长度不能超出31个字节。
    };
    let advResponse: ble.AdvertiseData = {
      serviceUuids: [this.myServiceUuid],
      manufactureData: [manufactureDataUnit],
      serviceData: [serviceDataUnit]
    };
    // 2.3 构造广播启动完整参数AdvertisingParams
    let advertisingParams: ble.AdvertisingParams = {
      advertisingSettings: setting,
      advertisingData: advData,
      advertisingResponse: advResponse,
      duration: 0 // 可选参数，若大于0，则广播发送一段时间后，则会临时停止，可重新启动发送
    }

    // 2.4 首次启动广播，且获取所启动广播的标识ID
    try {
      this.onAdvertisingStateChange(callBack);
      this.advHandle = await ble.startAdvertising(advertisingParams);
    } catch (err) {
      callBack((err as BusinessError).code );
      console.error(TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  // 4 临时停止广播，该广播资源仍然存在
  public async disableAdvertising() {
    // 4.1 构造临时停止广播参数
    let advertisingDisableParams: ble.AdvertisingDisableParams = {
      advertisingId: this.advHandle // 使用首次启动广播时获取到的广播标识ID
    }
    // 4.2 临时停止
    try {
      await ble.disableAdvertising(advertisingDisableParams);
    } catch (err) {
      console.error(TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  // 5 再次启动广播
  public async enableAdvertising(enableDuration: number) {
    // 5.1 构造临时启动广播参数
    let advertisingEnableParams: ble.AdvertisingEnableParams = {
      advertisingId: this.advHandle, // 使用首次启动广播时获取到的广播标识ID
      duration: enableDuration
    }
    // 5.2 再次启动
    try {
      await ble.enableAdvertising(advertisingEnableParams);
    } catch (err) {
      console.error(TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  // 6 完全关闭广播，释放广播资源
  public async stopAdvertising(callBack: (str: string)=> void) {
    if(this.advHandle == 0xFF){
      callBack("还未开启广播！");
    }
    try {
      await ble.stopAdvertising(this.advHandle);
      ble.off('advertisingStateChange');
      callBack("关闭广播成功！");
    } catch (err) {
      console.error(TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
      callBack("关闭错误：" + (err as BusinessError).code );
    }
  }
}

let bleAdvertisingManager = new BleAdvertisingManager();

export default bleAdvertisingManager as BleAdvertisingManager;