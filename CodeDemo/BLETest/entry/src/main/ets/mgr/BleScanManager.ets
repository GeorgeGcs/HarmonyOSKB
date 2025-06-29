import { ble } from '@kit.ConnectivityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { connection } from '@kit.ConnectivityKit';
import { EventHubUtils } from '../utils/EventHubUtils';
import { BleDeviceInfo } from '../bean/BleDeviceInfo';
import { util } from '@kit.ArkTS';

const TAG: string = 'BleScanManager';
const BLE_ADV_TYPE_FLAG = 0x01;
const BLE_ADV_TYPE_16_BIT_SERVICE_UUIDS_INCOMPLETE = 0x02;
const BLE_ADV_TYPE_16_BIT_SERVICE_UUIDS_COMPLETE = 0x03;
const BLE_ADV_TYPE_32_BIT_SERVICE_UUIDS_INCOMPLETE = 0x04;
const BLE_ADV_TYPE_32_BIT_SERVICE_UUIDS_COMPLETE = 0x05;
const BLE_ADV_TYPE_128_BIT_SERVICE_UUIDS_INCOMPLETE = 0x06;
const BLE_ADV_TYPE_128_BIT_SERVICE_UUIDS_COMPLETE = 0x07;
const BLE_ADV_TYPE_LOCAL_NAME_SHORT = 0x08;
const BLE_ADV_TYPE_LOCAL_NAME_COMPLETE = 0x09;
const BLE_ADV_TYPE_TX_POWER_LEVEL = 0x0A;
const BLE_ADV_TYPE_16_BIT_SERVICE_SOLICITATION_UUIDS = 0x14;
const BLE_ADV_TYPE_128_BIT_SERVICE_SOLICITATION_UUIDS = 0x15;
const BLE_ADV_TYPE_32_BIT_SERVICE_SOLICITATION_UUIDS = 0x1F;
const BLE_ADV_TYPE_16_BIT_SERVICE_DATA = 0x16;
const BLE_ADV_TYPE_32_BIT_SERVICE_DATA = 0x20;
const BLE_ADV_TYPE_128_BIT_SERVICE_DATA = 0x21;
const BLE_ADV_TYPE_MANUFACTURER_SPECIFIC_DATA = 0xFF;

const BLUETOOTH_UUID_16_BIT_LENGTH = 2;
const BLUETOOTH_UUID_32_BIT_LENGTH = 4;
const BLUETOOTH_UUID_128_BIT_LENGTH = 16;

const BLUETOOTH_MANUFACTURE_ID_LENGTH = 2;

export class BleScanManager {

  /**
   * 获取蓝牙设备名称
   */
  public getDeviceName(deviceId: string){
    let deviceName: string = "";
    try {
      deviceName = connection.getRemoteDeviceName(deviceId);
    } catch (err) {
      console.error(TAG, 'getCurrentDeviceName errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
    return deviceName;
  }

  // 1 订阅扫描结果
  public onScanResult() {
    ble.on('BLEDeviceFind', (data: Array<ble.ScanResult>) => {
      if (data.length > 0) {
        // console.info(TAG, 'BLE scan result = ' + JSON.stringify(data[0]));
        // let name: string = this.getDeviceName(data[0].deviceId);
        let name = data[0].deviceName;
        if(name){
          console.info(TAG, 'BLE scan name = ' + name);
          this.parseScanResult(data[0]);
        }
      }
    });
  }

  private parseScanResult(res: ble.ScanResult) {
    let data: ArrayBuffer = res.data;
    let advData = new Uint8Array(data);
    if (advData.byteLength == 0) {
      console.warn(TAG, 'nothing, adv data length is 0');
      return;
    }
    console.info(TAG, 'advData: ' + JSON.stringify(advData));

    let advFlags: number = -1;
    let txPowerLevel: number = -1;
    let localName: string = "";
    let serviceUuids: string[] = [];
    let serviceSolicitationUuids: string[] = [];
    let serviceDatas: Record<string, Uint8Array> = {};
    let manufactureSpecificDatas: Record<number, Uint8Array> = {};

    let curPos = 0;
    while (curPos < advData.byteLength) {
      let length = advData[curPos++];
      if (length == 0) {
        break;
      }
      let advDataLength = length - 1;
      let advDataType = advData[curPos++];
      switch (advDataType) {
        case BLE_ADV_TYPE_FLAG:
          advFlags = advData[curPos];
          break;
        case BLE_ADV_TYPE_LOCAL_NAME_SHORT:
        case BLE_ADV_TYPE_LOCAL_NAME_COMPLETE:
          let arr:Uint8Array = advData.slice(curPos, curPos + advDataLength)
          let base64 = new util.Base64Helper();
          localName = base64.encodeToStringSync(arr); // Uint8Array转base64
          break;
        case BLE_ADV_TYPE_TX_POWER_LEVEL:
          txPowerLevel = advData[curPos];
          break;
        case BLE_ADV_TYPE_16_BIT_SERVICE_UUIDS_INCOMPLETE:
        case BLE_ADV_TYPE_16_BIT_SERVICE_UUIDS_COMPLETE:
          this.parseServiceUuid(BLUETOOTH_UUID_16_BIT_LENGTH, curPos, advDataLength, advData, serviceUuids);
          break;
        case BLE_ADV_TYPE_32_BIT_SERVICE_UUIDS_INCOMPLETE:
        case BLE_ADV_TYPE_32_BIT_SERVICE_UUIDS_COMPLETE:
          this.parseServiceUuid(BLUETOOTH_UUID_32_BIT_LENGTH, curPos, advDataLength, advData, serviceUuids);
          break;
        case BLE_ADV_TYPE_128_BIT_SERVICE_UUIDS_INCOMPLETE:
        case BLE_ADV_TYPE_128_BIT_SERVICE_UUIDS_COMPLETE:
          this.parseServiceUuid(BLUETOOTH_UUID_128_BIT_LENGTH, curPos, advDataLength, advData, serviceUuids);
          break;
        case BLE_ADV_TYPE_16_BIT_SERVICE_SOLICITATION_UUIDS:
          this.parseServiceSolicitationUuid(BLUETOOTH_UUID_16_BIT_LENGTH, curPos, advDataLength,
            advData, serviceSolicitationUuids);
          break;
        case BLE_ADV_TYPE_32_BIT_SERVICE_SOLICITATION_UUIDS:
          this.parseServiceSolicitationUuid(BLUETOOTH_UUID_32_BIT_LENGTH, curPos, advDataLength,
            advData, serviceSolicitationUuids);
          break;
        case BLE_ADV_TYPE_128_BIT_SERVICE_SOLICITATION_UUIDS:
          this.parseServiceSolicitationUuid(BLUETOOTH_UUID_128_BIT_LENGTH, curPos, advDataLength,
            advData, serviceSolicitationUuids);
          break;
        case BLE_ADV_TYPE_16_BIT_SERVICE_DATA:
          this.parseServiceData(BLUETOOTH_UUID_16_BIT_LENGTH, curPos, advDataLength, advData, serviceDatas);
          break;
        case BLE_ADV_TYPE_32_BIT_SERVICE_DATA:
          this.parseServiceData(BLUETOOTH_UUID_32_BIT_LENGTH, curPos, advDataLength, advData, serviceDatas);
          break;
        case BLE_ADV_TYPE_128_BIT_SERVICE_DATA:
          this.parseServiceData(BLUETOOTH_UUID_128_BIT_LENGTH, curPos, advDataLength, advData, serviceDatas);
          break;
        case BLE_ADV_TYPE_MANUFACTURER_SPECIFIC_DATA:
          this.parseManufactureData(curPos, advDataLength, advData, manufactureSpecificDatas);
          break;
        default:
          break;
      }
      curPos += advDataLength;
    }

    let info: BleDeviceInfo = new BleDeviceInfo();
    info.DeviceData = res;
    info.advFlags = advFlags;
    info.txPowerLevel = txPowerLevel;
    info.localName = localName;
    info.serviceUuids = serviceUuids;
    info.serviceSolicitationUuids = serviceSolicitationUuids;
    info.serviceDatas = serviceDatas;
    info.manufactureSpecificDatas = manufactureSpecificDatas;
    info.curPos = curPos;
    EventHubUtils.getEventHub().emit("ScanRes", info);
  }

  private parseServiceUuid(uuidLength: number, curPos: number, advDataLength: number,
    advData: Uint8Array, serviceUuids: string[]) {
    while (advDataLength > 0) {
      let tmpData: Uint8Array = advData.slice(curPos, curPos + uuidLength);
      serviceUuids.push(this.getUuidFromUint8Array(uuidLength, tmpData));
      advDataLength -= uuidLength;
      curPos += uuidLength;
    }
  }

  private parseServiceSolicitationUuid(uuidLength: number, curPos: number, advDataLength: number,
    advData: Uint8Array, serviceSolicitationUuids: string[]) {
    while (advDataLength > 0) {
      let tmpData: Uint8Array = advData.slice(curPos, curPos + uuidLength);
      serviceSolicitationUuids.push(this.getUuidFromUint8Array(uuidLength, tmpData));
      advDataLength -= uuidLength;
      curPos += uuidLength;
    }
  }

  private getUuidFromUint8Array(uuidLength: number, uuidData: Uint8Array): string {
    let uuid = "";
    let temp: string = "";
    for (let i = uuidLength - 1; i > -1; i--) {
      temp += uuidData[i].toString(16).padStart(2, "0");
    }
    switch (uuidLength) {
      case BLUETOOTH_UUID_16_BIT_LENGTH:
        uuid = `0000${temp}-0000-1000-8000-00805F9B34FB`;
        break;
      case BLUETOOTH_UUID_32_BIT_LENGTH:
        uuid = `${temp}-0000-1000-8000-00805F9B34FB`;
        break;
      case BLUETOOTH_UUID_128_BIT_LENGTH:
        uuid = `${temp.substring(0, 8)}-${temp.substring(8, 12)}-${temp.substring(12, 16)}-${temp.substring(16, 20)}-${temp.substring(20, 32)}`;
        break;
      default:
        break;
    }
    return uuid;
  }

  private parseServiceData(uuidLength: number, curPos: number, advDataLength: number,
    advData: Uint8Array, serviceDatas: Record<string, Uint8Array>) {
    let tmpUuid: Uint8Array = advData.slice(curPos, curPos + uuidLength);
    let tmpValue: Uint8Array = advData.slice(curPos + uuidLength, curPos + advDataLength);
    serviceDatas[tmpUuid.toString()] = tmpValue;
  }

  private parseManufactureData(curPos: number, advDataLength: number,
    advData: Uint8Array, manufactureSpecificDatas: Record<number, Uint8Array>) {
    let manufactureId: number = (advData[curPos + 1] << 8) + advData[curPos];
    let tmpValue: Uint8Array = advData.slice(curPos + BLUETOOTH_MANUFACTURE_ID_LENGTH, curPos + advDataLength);
    manufactureSpecificDatas[manufactureId] = tmpValue;
  }

  // 2 开启扫描
  public startScan() {
    // 2.1 构造扫描过滤器，需要能够匹配预期的广播包内容
    let manufactureId = 4567;
    let manufactureData: Uint8Array = new Uint8Array([1, 2, 3, 4]);
    let manufactureDataMask: Uint8Array = new Uint8Array([0xFF, 0xFF, 0xFF, 0xFF]);
    let scanFilter: ble.ScanFilter = { // 根据业务实际情况定义过滤器
      // manufactureId: manufactureId,
      // manufactureData: manufactureData.buffer,
      // manufactureDataMask: manufactureDataMask.buffer
    };

    // 2.2 构造扫描参数
    let scanOptions: ble.ScanOptions = {
      interval: 0,
      dutyMode: ble.ScanDuty.SCAN_MODE_LOW_POWER,
      matchMode: ble.MatchMode.MATCH_MODE_AGGRESSIVE
    }
    try {
      this.onScanResult(); // 订阅扫描结果
      ble.startBLEScan([scanFilter], scanOptions);
      console.info(TAG, 'startBleScan success');
    } catch (err) {
      console.error(TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  // 3 关闭扫描
  public stopScan() {
    try {
      ble.off('BLEDeviceFind', (data: Array<ble.ScanResult>) => { // 取消订阅扫描结果
        console.info(TAG, 'off success');
      });
      ble.stopBLEScan();
      console.info(TAG, 'stopBleScan success');
    } catch (err) {
      console.error(TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }
}

let bleScanManager = new BleScanManager();
export default bleScanManager as BleScanManager;