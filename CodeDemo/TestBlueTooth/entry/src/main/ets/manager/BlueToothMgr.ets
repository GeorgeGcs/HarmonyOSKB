import { access, ble } from '@kit.ConnectivityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { connection } from '@kit.ConnectivityKit';

export class BlueToothMgr {

  private TAG: string = "BlueToothTest";

  private static mBlueToothMgr: BlueToothMgr | undefined = undefined;

  private advHandle: number = 0xFF; // default invalid value

  private mDeviceDiscoverArr: Array<string> = new Array<string>();

  public static Ins(){
    if(!BlueToothMgr.mBlueToothMgr){
      BlueToothMgr.mBlueToothMgr = new BlueToothMgr();
      BlueToothMgr.init();
    }
    return BlueToothMgr.mBlueToothMgr;
  }

  private static init(){
    try {
      connection.on('pinRequired', (data: connection.PinRequiredParam) =>{
        // data为配对请求参数
        console.info("BlueToothTest",'pinRequired pin required = '+ JSON.stringify(data));
      });
    } catch (err) {
      console.error("BlueToothTest", 'pinRequired errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  /**
   * 当前设备蓝牙设备名称
   */
  public getCurrentDeviceName(){
    let localName: string = "";
    try {
      localName = connection.getLocalName();
      console.info(this.TAG, 'getCurrentDeviceName localName: ' + localName);
    } catch (err) {
      console.error(this.TAG, 'getCurrentDeviceName errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
    return localName;
  }

  /**
   * 当前设备蓝牙可发现状态
   */
  public isCurrentDiscovering(){
    let res: boolean = false;
    try {
      res = connection.isBluetoothDiscovering();
      console.info(this.TAG, 'isCurrentDiscovering isBluetoothDiscovering: ' + res);
    } catch (err) {
      console.error(this.TAG, 'isCurrentDiscovering errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
    return res;
  }

  // STATE_OFF	0	表示蓝牙已关闭。
  // STATE_TURNING_ON	1	表示蓝牙正在打开。
  // STATE_ON	2	表示蓝牙已打开。
  // STATE_TURNING_OFF	3	表示蓝牙正在关闭。
  // STATE_BLE_TURNING_ON	4	表示蓝牙正在打开LE-only模式。
  // STATE_BLE_ON	5	表示蓝牙正处于LE-only模式。
  // STATE_BLE_TURNING_OFF	6	表示蓝牙正在关闭LE-only模式。

  public getBlueToothState(): access.BluetoothState {
    let state = access.getState();
    return state;
  }

  /**
   * 设置蓝牙访问(开关状态)
   * @param isAccess true: 打开蓝牙
   */
  setBlueToothAccess(isAccess: boolean, callbackBluetoothState: Callback<access.BluetoothState>){
    try {
      if(isAccess){
        console.info(this.TAG, 'bluetooth enableBluetooth 1');
        access.enableBluetooth();
        console.info(this.TAG, 'bluetooth enableBluetooth 2');
        access.on('stateChange', (data: access.BluetoothState) => {
          let btStateMessage = this.switchState(data);
          if (btStateMessage == 'STATE_ON') {
            access.off('stateChange');
          }
          console.info(this.TAG, 'bluetooth statues: ' + btStateMessage);
          callbackBluetoothState(data);
        })
      }else{
        console.info(this.TAG, 'bluetooth disableBluetooth 1');
        access.disableBluetooth();
        console.info(this.TAG, 'bluetooth disableBluetooth 2');
        access.on('stateChange', (data: access.BluetoothState) => {
          let btStateMessage = this.switchState(data);
          if (btStateMessage == 'STATE_OFF') {
            access.off('stateChange');
          }
          console.info(this.TAG, "bluetooth statues: " + btStateMessage);
          callbackBluetoothState(data);
        })
      }
    } catch (err) {
      console.error(this.TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  private switchState(data: access.BluetoothState){
    let btStateMessage = '';
    switch (data) {
      case 0:
        btStateMessage += 'STATE_OFF';
        break;
      case 1:
        btStateMessage += 'STATE_TURNING_ON';
        break;
      case 2:
        btStateMessage += 'STATE_ON';
        break;
      case 3:
        btStateMessage += 'STATE_TURNING_OFF';
        break;
      case 4:
        btStateMessage += 'STATE_BLE_TURNING_ON';
        break;
      case 5:
        btStateMessage += 'STATE_BLE_ON';
        break;
      case 6:
        btStateMessage += 'STATE_BLE_TURNING_OFF';
        break;
      default:
        btStateMessage += 'unknown status';
        break;
    }
    return btStateMessage;
  }

  /**
   * 主播蓝牙广播
   */
  public registerBroadcast(){
    try {
      ble.on('advertisingStateChange', (data: ble.AdvertisingStateChangeInfo) => {
        console.info(this.TAG, 'bluetooth advertising state = ' + JSON.stringify(data));
        AppStorage.setOrCreate('advertiserState', data.state);
      });
    } catch (err) {
      console.error(this.TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  /**
   * 开启蓝牙广播
   */
  public async startBroadcast(valueBuffer: Uint8Array){

    // 表示发送广播的相关参数。
    let setting: ble.AdvertiseSetting = {
      // 表示广播间隔，最小值设置160个slot表示100ms，最大值设置16384个slot，默认值设置为1600个slot表示1s。
      interval: 160,
      // 表示发送功率，最小值设置-127，最大值设置1，默认值设置-7，单位dbm。推荐值：高档（1），中档（-7），低档（-15）。
      txPower: 0,
      // 表示是否是可连接广播，默认值设置为true，表示可连接，false表示不可连接。
      connectable: true
    };

    // BLE广播数据包的内容。
    let manufactureDataUnit: ble.ManufactureData = {
      // 表示制造商的ID，由蓝牙SIG分配。
      manufactureId: 4567,
      manufactureValue: valueBuffer.buffer
    };

    let serviceValueBuffer = new Uint8Array(4);
    serviceValueBuffer[0] = 5;
    serviceValueBuffer[1] = 6;
    serviceValueBuffer[2] = 7;
    serviceValueBuffer[3] = 8;

    // 广播包中服务数据内容。
    let serviceDataUnit: ble.ServiceData = {
      serviceUuid: "00001888-0000-1000-8000-00805f9b34fb",
      serviceValue: serviceValueBuffer.buffer
    };

    // 表示广播的数据包内容。
    let advData: ble.AdvertiseData = {
      serviceUuids: ["00001888-0000-1000-8000-00805f9b34fb"],
      manufactureData: [manufactureDataUnit],
      serviceData: [serviceDataUnit],
      includeDeviceName: false // 表示是否携带设备名，可选参数。注意带上设备名时广播包长度不能超出31个字节。
    };

    // 表示回复扫描请求的响应内容。
    let advResponse: ble.AdvertiseData = {
      serviceUuids: ["00001888-0000-1000-8000-00805f9b34fb"],
      manufactureData: [manufactureDataUnit],
      serviceData: [serviceDataUnit]
    };

    // 首次启动广播设置的参数。
    let advertisingParams: ble.AdvertisingParams = {
      advertisingSettings: setting,
      advertisingData: advData,
      advertisingResponse: advResponse,
      // 	表示发送广播持续的时间。单位为10ms，有效范围为1(10ms)到65535(655350ms)，如果未指定此参数或者将其设置为0，则会连续发送广播。
      duration: 0 // 可选参数，若大于0，则广播发送一段时间后，则会临时停止，可重新启动发送
    }

    // 首次启动广播，且获取所启动广播的标识ID
    try {
      this.registerBroadcast();
      this.advHandle = await ble.startAdvertising(advertisingParams);
    } catch (err) {
      console.error(this.TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  /**
   * 开始蓝牙扫描
   */
  public startScanDevice(callback: Callback<Array<string>>){
    try {
      connection.on('bluetoothDeviceFind', (data: Array<string>)=>{
        // 随机MAC地址
        console.info(this.TAG, 'bluetooth device bluetoothDeviceFind = '+ JSON.stringify(data));
        callback(data);
      });
      connection.startBluetoothDiscovery();
    } catch (err) {
      console.error(this.TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  /**
   * 停止蓝牙扫描
   */
  public stopScanDevice(){
    try {
      connection.off('bluetoothDeviceFind');
      connection.stopBluetoothDiscovery();
    } catch (err) {
      console.error(this.TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  public getDeviceName(deviceID: string){
    let remoteDeviceName: string = "";
    try {
      remoteDeviceName = connection.getRemoteDeviceName(deviceID);
      console.info(this.TAG, 'getDeviceName device = '+ JSON.stringify(remoteDeviceName));
    } catch (err) {
      console.error(this.TAG, 'getDeviceName errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
    return remoteDeviceName;
  }

  public getDeviceClass(deviceID: string){
    let remoteDeviceClass: string = "";
    try {
      let classObj = connection.getRemoteDeviceClass(deviceID);
      remoteDeviceClass = JSON.stringify(classObj);
    } catch (err) {
      console.error(this.TAG, 'getDeviceName errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
    return remoteDeviceClass;
  }

  // BondState
  // BOND_STATE_INVALID	0	无效的配对。
  // BOND_STATE_BONDING	1	正在配对。
  // BOND_STATE_BONDED	2	已配对。

  /**
   * 发起配对蓝牙
   */
  public pairDevice(deviceID: string){
    try {
      connection.on('bondStateChange', (data: connection.BondStateParam) =>{
        console.info(this.TAG, 'pairDevice pair state = '+ JSON.stringify(data));
        // 当蓝牙配对类型PinType为PIN_TYPE_ENTER_PIN_CODE或PIN_TYPE_PIN_16_DIGITS时调用此接口，请求用户输入PIN码。
      });
      connection.pairDevice(deviceID, (err: BusinessError) => {
        console.info(this.TAG, 'pairDevice device name err:' + JSON.stringify(err));
      });
    } catch (err) {
      console.error(this.TAG, 'pairDevice errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

}
