## 【HarmonyOS】鸿蒙应用蓝牙功能实现 （二）

##鸿蒙开发能力 ##HarmonyOS SDK 应用服务 ##鸿蒙金融类应用 （金融理财 #

## 前言

蓝牙一般分为传统蓝牙(BR/EDR)，低功耗蓝牙(BLE)两种。

鸿蒙将蓝牙的功能模块分的非常细。

基本上我们会用到access进行蓝牙状态的开启和关闭，以及状态查询。

在使用connection进行传统蓝牙模式的扫描和配对。

或者再使用ble低功耗蓝牙模式进行广播，发起广播，传输数据，以及消息订阅。

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/23631c682a234b60aa93856af5069f32b1862.png)

## Demo示例：

```dart
import { access } from '@kit.ConnectivityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { BlueToothMgr } from '../manager/BlueToothMgr';
import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import { connection } from '@kit.ConnectivityKit';
import { map } from '@kit.ConnectivityKit';
import { pbap } from '@kit.ConnectivityKit';

@Entry
@Component
struct Index {

  private TAG: string = "BlueToothTest";

  // 蓝牙状态
  @State @Watch('onChangeBlueTooth') isStartBlueTooth: boolean = false;
  @State userGrant: boolean = false;

  @State mListDevice: Array<string> = [];

  async aboutToAppear() {
    await this.requestBlueToothPermission();

    let state = access.getState();
    console.log(this.TAG, "getState state: " + state);
    if(state == 2){
      this.isStartBlueTooth = true;
    }else{
      this.isStartBlueTooth = false;
    }
  }

  private onChangeBlueTooth(){
    if(!this.isStartBlueTooth){
      return;
    }
    // 当前设备的蓝牙可发现状态
    try {
      let res: boolean = connection.isBluetoothDiscovering();
      console.info(this.TAG, 'isBluetoothDiscovering: ' + res);
    } catch (err) {
      console.error(this.TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }

    // 访问信息相关功能
    try {
      let mapMseProfile = map.createMapMseProfile();
      console.info(this.TAG, 'MapMse success:' + JSON.stringify(mapMseProfile));
    } catch (err) {
      console.error(this.TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }

    // 访问电话簿相关功能
    try {
      let pbapServerProfile = pbap.createPbapServerProfile();
      console.info(this.TAG, 'pbapServer success:' + JSON.stringify(pbapServerProfile));
    } catch (err) {
      console.error(this.TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }

    try {
      connection.on('bluetoothDeviceFind', (data: Array<string>)=> {
        console.info(this.TAG, 'data length' + JSON.stringify(data));
        // 获取扫描可配对的设备列表
        this.mListDevice = data;
      });
      connection.startBluetoothDiscovery();
    } catch (err) {
      console.error(this.TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  // 用户申请权限
  async reqPermissionsFromUser(): Promise<number[]> {
    let context = getContext() as common.UIAbilityContext;
    let atManager = abilityAccessCtrl.createAtManager();
    let grantStatus = await atManager.requestPermissionsFromUser(context, ['ohos.permission.ACCESS_BLUETOOTH']);
    return grantStatus.authResults;
  }

  // 用户申请蓝牙权限
  async requestBlueToothPermission() {
    let grantStatus = await this.reqPermissionsFromUser();
    for (let i = 0; i < grantStatus.length; i++) {
      if (grantStatus[i] === 0) {
        // 用户授权，可以继续访问目标操作
        this.userGrant = true;
      }
    }
  }

  setBlueToothState =()=>{
    try {
      if(!this.isStartBlueTooth){
        BlueToothMgr.Ins().setBlueToothAccess(true);
      }else{
        BlueToothMgr.Ins().setBlueToothAccess(false);
      }
      let state = access.getState();
      if(state == 2){
        this.isStartBlueTooth = true;
      }else{
        this.isStartBlueTooth = false;
      }
      console.log(this.TAG, "getState state: " + state);
    } catch (err) {
      console.error(this.TAG,'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  build() {
    RelativeContainer() {
      if(this.userGrant){
        Text("蓝牙状态:" + this.isStartBlueTooth ? "开启" : "关闭")
          .id('HelloWorld')
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .onClick(this.setBlueToothState)

        Text("蓝牙状态:" + this.isStartBlueTooth ? "开启" : "关闭")
          .id('HelloWorld')
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .onClick(this.setBlueToothState)


      }
    }
    .height('100%')
    .width('100%')
  }

  @Builder ListView(){
    List() {
      ForEach(this.mListDevice, (item: string, index: number) => {
        ListItem() {
          Row() {
            Text(item).fontSize(px2fp(22)).fontColor(Color.Black)
          }
          .width('100%')
          .height(px2vp(100))
          .justifyContent(FlexAlign.Start)
        }
      }, (item: string, index: number) => JSON.stringify(item) + index)
    }
    .width('100%')
    .height('100%')
  }
}

```

```dart
import { access, ble } from '@kit.ConnectivityKit';
import { BusinessError } from '@kit.BasicServicesKit';

export class BlueToothMgr {

  private TAG: string = "BlueToothTest";

  private static mBlueToothMgr: BlueToothMgr | undefined = undefined;

  private advHandle: number = 0xFF; // default invalid value

  public static Ins(){
    if(!BlueToothMgr.mBlueToothMgr){
      BlueToothMgr.mBlueToothMgr = new BlueToothMgr();
    }
    return BlueToothMgr.mBlueToothMgr;
  }

  // STATE_OFF	0	表示蓝牙已关闭。
  // STATE_TURNING_ON	1	表示蓝牙正在打开。
  // STATE_ON	2	表示蓝牙已打开。
  // STATE_TURNING_OFF	3	表示蓝牙正在关闭。
  // STATE_BLE_TURNING_ON	4	表示蓝牙正在打开LE-only模式。
  // STATE_BLE_ON	5	表示蓝牙正处于LE-only模式。
  // STATE_BLE_TURNING_OFF	6	表示蓝牙正在关闭LE-only模式。

  /**
   * 设置蓝牙访问(开关状态)
   * @param isAccess true: 打开蓝牙
   */
  setBlueToothAccess(isAccess: boolean){
    try {
      if(isAccess){
        console.info(this.TAG, 'bluetooth enableBluetooth 1');
        access.enableBluetooth();
        console.info(this.TAG, 'bluetooth enableBluetooth ');
        access.on('stateChange', (data: access.BluetoothState) => {
          let btStateMessage = this.switchState(data);
          if (btStateMessage == 'STATE_ON') {
            access.off('stateChange');
          }
          console.info(this.TAG, 'bluetooth statues: ' + btStateMessage);
        })
      }else{
        console.info(this.TAG, 'bluetooth disableBluetooth 1');
        access.disableBluetooth();
        console.info(this.TAG, 'bluetooth disableBluetooth ');
        access.on('stateChange', (data: access.BluetoothState) => {
          let btStateMessage = this.switchState(data);
          if (btStateMessage == 'STATE_OFF') {
            access.off('stateChange');
          }
          console.info(this.TAG, "bluetooth statues: " + btStateMessage);
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

}

```

