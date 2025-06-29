## 【HarmonyOS】Bluetooth Function Implementation in HarmonyOS Applications (Part 3)  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services ##HarmonyOS Financial Applications （Financial Management #  

### I. Bluetooth Pairing Business Process  

**1. Device Enters Discoverable Mode:**  
First, the device must enter discoverable mode so nearby Bluetooth devices can detect it. One device (e.g., a smartphone) actively scans for nearby Bluetooth devices and lists all available pairing options.  

**2. Select and Trigger Pairing Request:**  
The user selects a device from the list and triggers a pairing request. The devices exchange authentication information to verify each other's identity, which may require entering a pairing code (e.g., PIN) or confirming the request on the device.  

**3. Authentication and Encryption:**  
Once authentication succeeds, a secure connection channel is established ("pairing successful"). The devices can then start transmitting data.  

**4. Data Transmission:**  
Devices transfer data via Bluetooth, supporting various types like audio and files.  

**5. Disconnect:**  
After data transmission, Bluetooth devices can disconnect, either via physical buttons or software.  

***Bluetooth pairing is typically one-time: once paired, devices automatically recognize each other for subsequent connections without re-pairing (unless reset or manually unpaired).***  

The traditional Bluetooth pairing flow chart is for reference:  
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/dd71f42b942f4a798764c193312c3f14.png)  


### II. Demo Effect of Regular Bluetooth Pairing  

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/d799380b1dad41889a24b3d4bbc96a4d.png)  

**The demo includes the following features:**  
1. Bluetooth permission enabling  
2. Bluetooth on/off control  
3. Bluetooth scanning on/off control  
4. Bluetooth pairing  
5. Bluetooth code protocol confirmation  


### III. Source Code of Regular Bluetooth Pairing Demo  

**Bluetooth UI Interaction Class**  
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

  // Scan status timer
  private mNumInterval: number = -1;
  // Current device Bluetooth name
  @State mCurrentDeviceName: string = "";
  // Bluetooth status
  @State @Watch('onChangeBlueTooth') isStartBlueTooth: boolean = false;
  // Bluetooth scanning status
  @State @Watch('onChangeBlueTooth') isStartScan: boolean = false;
  // Current Bluetooth permission status
  @State userGrant: boolean = false;
  // Discovered device list
  @State mMapDevice: HashMap<string, DeviceInfo> = new HashMap();
  // UI-displayed device list
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

  // Request user permission
  async reqPermissionsFromUser(): Promise<number[]> {
    let context = getContext() as common.UIAbilityContext;
    let atManager = abilityAccessCtrl.createAtManager();
    let grantStatus = await atManager.requestPermissionsFromUser(context, ['ohos.permission.ACCESS_BLUETOOTH']);
    return grantStatus.authResults;
  }

  // Request Bluetooth permission
  async requestBlueToothPermission() {
    let grantStatus = await this.reqPermissionsFromUser();
    for (let i = 0; i < grantStatus.length; i++) {
      if (grantStatus[i] === 0) {
        // User authorized
        this.userGrant = true;
        promptAction.showToast({ message: "Bluetooth authorization successful!"});
      }else{
        promptAction.showToast({ message: "Bluetooth authorization failed!"});
      }
    }
  }

  setBlueToothScan = ()=>{
    if(!this.isStartScan){
      promptAction.showToast({ message: "Scan started!"});
      BlueToothMgr.Ins().startScanDevice((data: Array<string>)=>{
        let deviceId: string = data[0];
        if(this.mMapDevice.hasKey(deviceId)){
          // Skip duplicate devices
        }else{
          // Add to map
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
      // Start timer
      this.mNumInterval = setInterval(()=>{
        let discovering = BlueToothMgr.Ins().isCurrentDiscovering();
        if(!discovering){
          this.closeScanDevice();
        }
      }, 1000);
      this.isStartScan = true;
    }else{
      promptAction.showToast({ message: "Scan stopped!"});
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
        // Turn on Bluetooth
        BlueToothMgr.Ins().setBlueToothAccess(true, (state: access.BluetoothState) => {
          console.log(this.TAG, "getState setBlueToothAccessTrue: " + state);
          if(state == access.BluetoothState.STATE_ON){
            this.isStartBlueTooth = true;
            promptAction.showToast({ message: "Bluetooth turned on!"});
            console.log(this.TAG, "getState isStartBlueTooth: " + this.isStartBlueTooth);
          }
        });
      }else{
        BlueToothMgr.Ins().setBlueToothAccess(false, (state: access.BluetoothState) => {
          console.log(this.TAG, "getState setBlueToothAccessFalse: " + state);
          if(state == access.BluetoothState.STATE_OFF){
            this.isStartBlueTooth = false;
            promptAction.showToast({ message: "Bluetooth turned off!"});
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
          Text("Current Bluetooth device info:\n " + this.mCurrentDeviceName)
            .fontSize(px2fp(80))
            .margin({ top: px2vp(100) })
            .fontWeight(FontWeight.Bold)

          Text(this.isStartBlueTooth ? "Bluetooth status: On" : "Bluetooth status: Off")
            .fontSize(px2fp(80))
            .margin({ top: px2vp(100) })
            .fontWeight(FontWeight.Bold)
            .onClick(this.setBlueToothState)

          Text(this.isStartScan ? "Bluetooth scanning: On" : "Bluetooth scanning: Off")
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
              Text("Device ID: " + item.deviceId).fontSize(px2fp(42)).fontColor(Color.Black)
              Blank()
              Text("Device name: " + item.deviceName).fontSize(px2fp(42)).fontColor(Color.Black)
            }
            .width('100%')
            Text(item.deviceClass).fontSize(px2fp(42)).fontColor(Color.Black)
          }
          .width('100%')
          .height(px2vp(200))
          .justifyContent(FlexAlign.Start)
          .onClick(()=>{
            // Handle pairing on click
            AlertDialog.show({
              title:"Select to Pair",
              message:"Do you want to pair with this device?",
              autoCancel: true,
              primaryButton: {
                value:"Confirm",
                action:()=>{
                  promptAction.showToast({ message: item.deviceName + " pairing in progress!"});
                  BlueToothMgr.Ins().pairDevice(item.deviceId);
                }
              },
              secondaryButton: {
                value:"Cancel",
                action:()=>{
                  promptAction.showToast({ message: "Cancelled!"});
                }
              },
              cancel:()=>{
                promptAction.showToast({ message: "Cancelled!"});
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

**Bluetooth Management Class**  
```dart
import { access, ble } from '@kit.ConnectivityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { connection } from '@kit.ConnectivityKit';

export class BlueToothMgr {

  private TAG: string = "BlueToothTest";

  private static mBlueToothMgr: BlueToothMgr | undefined = undefined;

  private advHandle: number = 0xFF; // Default invalid handle

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
        // data is the pairing request parameter
        console.info("BlueToothTest",'pinRequired pin required = '+ JSON.stringify(data));
      });
    } catch (err) {
      console.error("BlueToothTest", 'pinRequired errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  /**
   * Get the current device's Bluetooth name
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
   * Check if the current device is discoverable
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

  // STATE_OFF	0	Bluetooth is off.
  // STATE_TURNING_ON	1	Bluetooth is turning on.
  // STATE_ON	2	Bluetooth is on.
  // STATE_TURNING_OFF	3	Bluetooth is turning off.
  // STATE_BLE_TURNING_ON	4	Bluetooth is turning on in LE-only mode.
  // STATE_BLE_ON	5	Bluetooth is in LE-only mode.
  // STATE_BLE_TURNING_OFF	6	Bluetooth is turning off from LE-only mode.

  public getBlueToothState(): access.BluetoothState {
    let state = access.getState();
    return state;
  }

  /**
   * Set Bluetooth access status (on/off)
   * @param isAccess true: Turn on Bluetooth
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
          console.info(this.TAG, 'bluetooth status: ' + btStateMessage);
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
          console.info(this.TAG, "bluetooth status: " + btStateMessage);
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
   * Register for Bluetooth advertising events
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
   * Start BLE advertising
   */
  public async startBroadcast(valueBuffer: Uint8Array){

    // Advertising settings
    let setting: ble.AdvertiseSetting = {
      interval: 160,         // Advertising interval (160 slots = 100ms)
      txPower: 0,            // Transmission power (0 = medium)
      connectable: true      // Connectable advertising
    };

    // Manufacturer-specific data in advertisement
    let manufactureDataUnit: ble.ManufactureData = {
      manufactureId: 4567,
      manufactureValue: valueBuffer.buffer
    };

    let serviceValueBuffer = new Uint8Array(4);
    serviceValueBuffer[0] = 5;
    serviceValueBuffer[1] = 6;
    serviceValueBuffer[2] = 7;
    serviceValueBuffer[3] = 8;

    // Service data in advertisement
    let serviceDataUnit: ble.ServiceData = {
      serviceUuid: "00001888-0000-1000-8000-00805f9b34fb",
      serviceValue: serviceValueBuffer.buffer
    };

    // Advertisement data content
    let advData: ble.AdvertiseData = {
      serviceUuids: ["00001888-0000-1000-8000-00805f9b34fb"],
      manufactureData: [manufactureDataUnit],
      serviceData: [serviceDataUnit],
      includeDeviceName: false // Optional, do not exceed 31 bytes if included
    };

    // Scan response data
    let advResponse: ble.AdvertiseData = {
      serviceUuids: ["00001888-0000-1000-8000-00805f9b34fb"],
      manufactureData: [manufactureDataUnit],
      serviceData: [serviceDataUnit]
    };

    // Advertising parameters
    let advertisingParams: ble.AdvertisingParams = {
      advertisingSettings: setting,
      advertisingData: advData,
      advertisingResponse: advResponse,
      duration: 0  // 0 = continuous advertising
    }

    // Start advertising and get handle
    try {
      this.registerBroadcast();
      this.advHandle = await ble.startAdvertising(advertisingParams);
    } catch (err) {
      console.error(this.TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  /**
   * Start Bluetooth scanning
   */
  public startScanDevice(callback: Callback<Array<string>>){
    try {
      connection.on('bluetoothDeviceFind', (data: Array<string>)=>{
        // Random MAC address
        console.info(this.TAG, 'bluetooth device bluetoothDeviceFind = '+ JSON.stringify(data));
        callback(data);
      });
      connection.startBluetoothDiscovery();
    } catch (err) {
      console.error(this.TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  /**
   * Stop Bluetooth scanning
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
  // BOND_STATE_INVALID	0	Invalid pairing.
  // BOND_STATE_BONDING	1	Pairing in progress.
  // BOND_STATE_BONDED	2	Paired.

  /**
   * Initiate Bluetooth pairing
   */
  public pairDevice(deviceID: string){
    try {
      connection.on('bondStateChange', (data: connection.BondStateParam) =>{
        console.info(this.TAG, 'pairDevice pair state = '+ JSON.stringify(data));
        // Call when pairing type is PIN_TYPE_ENTER_PIN_CODE or PIN_TYPE_PIN_16_DIGITS
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

[Download Link for Completed Demo Resources](https://download.csdn.net/download/u010949451/89673582)  

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/76f52513c0ee45ddbf7d07406fa37c07.png)