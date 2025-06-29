## 【HarmonyOS】Bluetooth Function Implementation in HarmonyOS Applications (Part 2)  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services ##HarmonyOS Financial Applications （Financial Management #  

### Preface  

Bluetooth technology is generally categorized into classic Bluetooth (BR/EDR) and Bluetooth Low Energy (BLE).  

HarmonyOS divides Bluetooth functional modules into fine-grained components:  
- `access` for enabling/disabling Bluetooth, querying status  
- `connection` for classic Bluetooth scanning and pairing  
- `ble` for BLE advertising, broadcasting, data transmission, and message subscription  


![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/23631c682a234b60aa93856af5069f32b1862.png)  


### Demo Example  


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

  // Bluetooth status
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
    // Current device discoverability status
    try {
      let res: boolean = connection.isBluetoothDiscovering();
      console.info(this.TAG, 'isBluetoothDiscovering: ' + res);
    } catch (err) {
      console.error(this.TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }

    // Access map service profile
    try {
      let mapMseProfile = map.createMapMseProfile();
      console.info(this.TAG, 'MapMse success:' + JSON.stringify(mapMseProfile));
    } catch (err) {
      console.error(this.TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }

    // Access phonebook service profile
    try {
      let pbapServerProfile = pbap.createPbapServerProfile();
      console.info(this.TAG, 'pbapServer success:' + JSON.stringify(pbapServerProfile));
    } catch (err) {
      console.error(this.TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }

    try {
      connection.on('bluetoothDeviceFind', (data: Array<string>)=> {
        console.info(this.TAG, 'data length' + JSON.stringify(data));
        // Get discoverable device list
        this.mListDevice = data;
      });
      connection.startBluetoothDiscovery();
    } catch (err) {
      console.error(this.TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
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
        Text("Bluetooth Status:" + this.isStartBlueTooth ? "On" : "Off")
          .id('HelloWorld')
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .onClick(this.setBlueToothState)

        Text("Bluetooth Status:" + this.isStartBlueTooth ? "On" : "Off")
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

  private advHandle: number = 0xFF; // Default invalid handle

  public static Ins(){
    if(!BlueToothMgr.mBlueToothMgr){
      BlueToothMgr.mBlueToothMgr = new BlueToothMgr();
    }
    return BlueToothMgr.mBlueToothMgr;
  }

  // STATE_OFF	0	Bluetooth is off
  // STATE_TURNING_ON	1	Bluetooth is turning on
  // STATE_ON	2	Bluetooth is on
  // STATE_TURNING_OFF	3	Bluetooth is turning off
  // STATE_BLE_TURNING_ON	4	Bluetooth is turning on in LE-only mode
  // STATE_BLE_ON	5	Bluetooth is in LE-only mode
  // STATE_BLE_TURNING_OFF	6	Bluetooth is turning off from LE-only mode

  /**
   * Set Bluetooth access status
   * @param isAccess true: Turn on Bluetooth
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
          console.info(this.TAG, 'bluetooth status: ' + btStateMessage);
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
          console.info(this.TAG, "bluetooth status: " + btStateMessage);
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

    // Advertising parameters
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
      includeDeviceName: false
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
}
```