import bleAdvertisingManager from "./BleAdvertisingManager";
import bleScanManager from "./BleScanManager";
import { access } from '@kit.ConnectivityKit';
import gattServerManager from "./GattServerManager";
import { connection } from '@kit.ConnectivityKit';
import { BusinessError } from "@kit.BasicServicesKit";
import gattClientManager from "./GattClientManager";

const TAG: string = "BLEMgr";

export class BLEMgr {

  public getBluetoothState(): boolean {
    let state = access.getState();
    return this.getStateName(state) == "STATE_ON" ? true : false;
  }

  /**
   * 当前设备蓝牙设备名称
   */
  public getCurrentDeviceName(){
    let localName: string = "";
    try {
      localName = connection.getLocalName();
      console.info(TAG, 'getCurrentDeviceName localName: ' + localName);
    } catch (err) {
      console.error(TAG, 'getCurrentDeviceName errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
    return localName;
  }

  /**
   * 蓝牙广播状态
   * @param state
   * @returns
   */
  public getAdvState(state: number){
    switch (state) {
      case 1:
        // 首次启动广播后的状态。
        return 'STARTED';
      case 2:
        // 临时启动广播后的状态。
        return 'ENABLED';
      case 3:
        // 临时停止广播后的状态。
        return 'DISABLED';
      case 4:
        // 完全停止广播后的状态。
        return 'STOPPED';
      default:
        return 'unknown status';
    }
  }

  /**
   * 蓝牙开启状态
   * @param state
   * @returns
   */
  private getStateName(state: number): string {
    switch (state) {
      case 0:
        // 蓝牙已关闭。
        return 'STATE_OFF'; ;
      case 1:
        // 蓝牙正在打开。
        return 'STATE_TURNING_ON';
      case 2:
        // 蓝牙已打开。
        return 'STATE_ON';
      case 3:
        // 蓝牙正在关闭。
        return 'STATE_TURNING_OFF';
      case 4:
        // 蓝牙正在打开LE-only模式。
        return 'STATE_BLE_TURNING_ON';
      case 5:
        // 蓝牙正处于LE-only模式。
        return 'STATE_BLE_ON';
      case 6:
        // 蓝牙正在关闭LE-only模式。
        return 'STATE_BLE_TURNING_OFF';
      default:
        return 'unknown status';
    }
  }

  /**
   * 开启蓝牙
   */
  public startBluetooth(callback: (str: string)=> void){
    try {
      access.enableBluetooth();
    } catch (err) {
      let errStr: string = JSON.stringify(err);
      console.info(TAG, 'startBluetooth enableBluetooth err: ' + errStr);
      callback(errStr);
    }
    access.on('stateChange', (data) => {
      let btStateMessage = this.getStateName(data);
      callback(btStateMessage);
      if (btStateMessage == 'STATE_ON') {
        access.off('stateChange');
      }
      console.info('bluetooth statues: ' + btStateMessage);
    });
  }

  /**
   * 关闭蓝牙
   */
  public closeBluetooth(callback: (str: string)=> void){
    access.disableBluetooth();
    access.on('stateChange', (data) => {
      let btStateMessage = this.getStateName(data);
      callback(btStateMessage);
      if (btStateMessage == 'STATE_OFF') {
        access.off('stateChange');
      }
      console.info("bluetooth statues: " + btStateMessage);
    })
  }

  /**
   * 创建GATT服务器，注册服务
   */
  public registerServer(callBack: (str: string)=> void){
    gattServerManager.registerServer(callBack);
  }

  /**
   * 删除服务，关闭GATT服务器
   */
  public unRegisterServer(callBack: (str: string)=> void){
    gattServerManager.unRegisterServer(callBack);
  }

  /**
   * 开启广播
   */
  public async startAdvertising(callBack: (state: string)=> void) {
    await bleAdvertisingManager.startAdvertising((state: number)=>{
      let advState: string = this.getAdvState(state);
      callBack(advState);
    });
  }

  /**
   * 关闭广播
   */
  public async stopAdvertising(callBack: (str: string)=> void) {
    await bleAdvertisingManager.stopAdvertising(callBack);
  }

  /**
   * 开始扫描
   */
  public startScan() {
    bleScanManager.startScan();
  }

  /**
   * 关闭扫描
   */
  public stopScan() {
    bleScanManager.stopScan();
  }

  /**
   * 连接设备
   * @param peerDevice
   */
  public startConnect(peerDevice: string){
    gattClientManager.startConnect(peerDevice);
  }

  /**
   * 关闭连接设备
   */
  public stopConnect(){
    gattClientManager.stopConnect();
  }

  public discoverServices(){
    gattClientManager.discoverServices();
  }

  public getClient(){
    return gattClientManager;
  }

}