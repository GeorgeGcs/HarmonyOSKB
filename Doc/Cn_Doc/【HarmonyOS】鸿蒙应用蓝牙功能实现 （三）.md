## 【HarmonyOS】鸿蒙应用蓝牙功能实现 （三）

## 一、蓝牙配对业务流程

**1‌.设备进入可被发现模式‌：**
首先，设备需要进入可被发现模式，这样周围的蓝牙设备才能识别到它。一方设备（如手机）会主动搜索附近的蓝牙设备，并列出所有可用的配对选项。

**2‌.选择并触发配对请求‌：**
用户从列表中选择想要连接的设备，并触发配对请求。此时，双方设备会交换一系列的身份验证信息，以确保彼此的身份安全无误。在这个过程中，可能会要求用户输入配对码（如PIN码）或在设备上确认配对请求。

**3‌.身份验证和加密‌：**
一旦身份验证通过，设备间就会建立安全的连接通道，这一过程称为“配对成功”。配对完成后，设备之间的连接就建立了，它们可以开始传输数据。

**4‌.数据传输‌：**
设备间通过蓝牙进行数据传输，可以传输音频、文件等多种类型的数据。

**5‌.断开连接‌：**
当数据传输完成后，蓝牙设备可以断开连接。断开连接的操作可以通过设备上的按钮或者软件来实现。

***蓝牙配对通常是一次性的，即一旦设备成功配对，它们会在后续的连接中自动识别并连接，无需再次进行配对过程（除非设备被重置或用户手动取消配对）***

以下是传统的蓝牙配对流程图仅供参考：
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/dd71f42b942f4a798764c193312c3f14.png)
## 二、常规蓝牙配对Demo效果：
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/d799380b1dad41889a24b3d4bbc96a4d.png)

**Demo包括以下内容：**
1.蓝牙权限开启
2.蓝牙开启/关闭
3.蓝牙扫描开启/关闭
4.蓝牙配对
5.蓝牙code协议确认

## 三、常规蓝牙配对Demo源码：

**蓝牙UI交互类**
```dart
import { access } from '@kit.ConnectivityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { BlueToothMgr } from '../manager/BlueToothMgr';
import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import { connection } from '@kit.ConnectivityKit';
import { map } from '@kit.ConnectivityKit';
import { pbap } from '@kit.ConnectivityKit';
import { HashMap } from '@kit.ArkTS';
import { DeviceInfo } from '../info/DeviceInfo';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct Index {

  private TAG: string = "BlueToothTest";

  // 扫描状态定时器
  private mNumInterval: number = -1;
  // 当前设备蓝牙名
  @State mCurrentDeviceName: string = "";
  // 蓝牙状态
  @State @Watch('onChangeBlueTooth') isStartBlueTooth: boolean = false;
  // 蓝牙扫描状态
  @State @Watch('onChangeBlueTooth') isStartScan: boolean = false;
  // 当前蓝牙权限
  @State userGrant: boolean = false;
  // 扫描到设备名
  @State mMapDevice: HashMap<string, DeviceInfo> = new HashMap();
  // ui展现的设备列表
  @State mListDeviceInfo: Array<DeviceInfo> = new Array();

  async aboutToAppear() {
    await this.requestBlueToothPermission();

    let state = access.getState();
    console.log(this.TAG, "getState state: " + state);
    if(state == 2){
      this.isStartBlueTooth = true;
      console.log(this.TAG, "getState isStartBlueTooth: " + this.isStartBlueTooth);
    }else{
      this.isStartBlueTooth = false;
      console.log(this.TAG, "getState isStartBlueTooth: " + this.isStartBlueTooth);
    }
  }

  private onChangeBlueTooth(){
    if(!this.isStartBlueTooth){
      this.mMapDevice = new HashMap();
      return;
    }

    this.mCurrentDeviceName = BlueToothMgr.Ins().getCurrentDeviceName();
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
        promptAction.showToast({ message: "蓝牙授权成功！"});
      }else{
        promptAction.showToast({ message: "蓝牙授权失败！"});
      }
    }
  }

  setBlueToothScan = ()=>{
    if(!this.isStartScan){
      promptAction.showToast({ message: "开启扫描！"});
      BlueToothMgr.Ins().startScanDevice((data: Array<string>)=>{
        let deviceId: string = data[0];
        if(this.mMapDevice.hasKey(deviceId)){
          // 重复设备，丢弃不处理
        }else{
          // 添加到表中
          let deviceInfo: DeviceInfo = new DeviceInfo();
          deviceInfo.deviceId = deviceId;
          deviceInfo.deviceName = BlueToothMgr.Ins().getDeviceName(deviceId);
          deviceInfo.deviceClass = BlueToothMgr.Ins().getDeviceClass(deviceId);
          this.mMapDevice.set(deviceId, deviceInfo);
          this.mListDeviceInfo = this.mListDeviceInfo.concat(deviceInfo);
        }
      });
      this.mMapDevice.clear();
      this.mListDeviceInfo = [];
      // 开启定时器
      this.mNumInterval = setInterval(()=>{
        let discovering = BlueToothMgr.Ins().isCurrentDiscovering();
        if(!discovering){
          this.closeScanDevice();
        }
      }, 1000);
      this.isStartScan = true;
    }else{
      promptAction.showToast({ message: "关闭扫描！"});
      BlueToothMgr.Ins().stopScanDevice();
      this.closeScanDevice();
    }
  }

  private closeScanDevice(){
    clearInterval(this.mNumInterval);
    this.isStartScan = false;
  }

  setBlueToothState = ()=>{
    try {
      if(!this.isStartBlueTooth){
        // 开启蓝牙
        BlueToothMgr.Ins().setBlueToothAccess(true, (state: access.BluetoothState) => {
          console.log(this.TAG, "getState setBlueToothAccessTrue: " + state);
          if(state == access.BluetoothState.STATE_ON){
            this.isStartBlueTooth = true;
            promptAction.showToast({ message: "开启蓝牙！"});
            console.log(this.TAG, "getState isStartBlueTooth: " + this.isStartBlueTooth);
          }
        });
      }else{
        BlueToothMgr.Ins().setBlueToothAccess(false, (state: access.BluetoothState) => {
          console.log(this.TAG, "getState setBlueToothAccessFalse: " + state);
          if(state == access.BluetoothState.STATE_OFF){
            this.isStartBlueTooth = false;
            promptAction.showToast({ message: "关闭蓝牙！"});
            console.log(this.TAG, "getState isStartBlueTooth: " + this.isStartBlueTooth);
          }
        });
      }
    } catch (err) {
      console.error(this.TAG,'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  private isLog(){
    console.log(this.TAG, "isLog isStartBlueTooth: " + this.isStartBlueTooth);
    return true;
  }

  build() {
    Column() {
      if(this.userGrant){
        if(this.isLog()){
          Text("当前蓝牙设备信息:\n " + this.mCurrentDeviceName)
            .fontSize(px2fp(80))
            .margin({ top: px2vp(100) })
            .fontWeight(FontWeight.Bold)

          Text(this.isStartBlueTooth ? "蓝牙状态: 开启" : "蓝牙状态: 关闭")
            .fontSize(px2fp(80))
            .margin({ top: px2vp(100) })
            .fontWeight(FontWeight.Bold)
            .onClick(this.setBlueToothState)

          Text(this.isStartScan ? "蓝牙扫描: 开启ing" : "蓝牙扫描: 关闭")
            .margin({ top: px2vp(100) })
            .fontSize(px2fp(80))
            .fontWeight(FontWeight.Bold)
            .onClick(this.setBlueToothScan)

          this.ListView()
        }
      }
    }
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .width('100%')
  }

  @Builder ListView(){
    List() {
      ForEach(this.mListDeviceInfo, (item: DeviceInfo, index: number) => {
        ListItem() {
          Column(){
            Row() {
              Text("设备ID: " + item.deviceId).fontSize(px2fp(42)).fontColor(Color.Black)
              Blank()
              Text("设备名: " + item.deviceName).fontSize(px2fp(42)).fontColor(Color.Black)
            }
            .width('100%')
            Text(item.deviceClass).fontSize(px2fp(42)).fontColor(Color.Black)
          }
          .width('100%')
          .height(px2vp(200))
          .justifyContent(FlexAlign.Start)
          .onClick(()=>{
            // 点击选择处理配对
            AlertDialog.show({
              title:"选择配对",
              message:"是否选择该设备进行蓝牙配对？",
              autoCancel: true,
              primaryButton: {
                value:"确定",
                action:()=>{
                  promptAction.showToast({ message: item.deviceName + "配对ing！"});
                  BlueToothMgr.Ins().pairDevice(item.deviceId);
                }
              },
              secondaryButton: {
                value:"取消",
                action:()=>{
                  promptAction.showToast({ message: "取消！"});
                }
              },
              cancel:()=>{
                promptAction.showToast({ message: "取消！"});
              }
            })
          })
        }
      }, (item: string, index: number) => JSON.stringify(item) + index)
    }
    .width('100%')
  }
}
```

**蓝牙管理类**
```dart
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

```

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/fda00352f394401cbc3a6b884469f6ce.png![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/2208c37af700411ea0140f7e4141d59c.png)

[DEMO完成示例资源下载链接](https://download.csdn.net/download/u010949451/89673582)

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/76f52513c0ee45ddbf7d07406fa37c07.png)
