## 【HarmonyOS 5】Bluetooth Function Implementation in HarmonyOS Applications (Part 1)  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services ##HarmonyOS Financial Applications （Financial Management#  

### Preface  

Bluetooth technology is a wireless communication technology for short-range data transmission. Proposed by Ericsson in 1994, it uses the 2.4 GHz ISM band and communicates within a range of about 10 meters. It connects devices like smartphones, headphones, speakers, keyboards, mice, and printers.  

Features include low power consumption, low cost, and ease of use. Currently in its fifth generation, it supports higher data transmission rates and broader coverage.  

**Bluetooth Implementation Principle**  

Bluetooth operates on short-range communication protocols based on radio technology, using 2.4GHz radio waves and Frequency Hopping Spread Spectrum (FHSS) to avoid interference with other wireless devices. During communication, Bluetooth devices send and receive data packets, employing different Bluetooth protocols to control communication flows and data transmission.  

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/e67b10ed88514ad98da40b309b84047cb1862.png)  

**Principle of Bluetooth Frequency Hopping Technology**  

Bluetooth frequency hopping technology relies on rapidly switching between different frequencies to transmit data. This technique prevents interference and noise from affecting data transmission, enhancing reliability. Specifically, when a frequency is disturbed, the system automatically switches to another frequency to ensure data integrity and stability.  


### DEMO Example  

The following demonstrates Bluetooth switch and state control:  


```dart
import { access } from '@kit.ConnectivityKit';
import { BusinessError } from '@kit.BasicServicesKit';

export class BlueToothMgr {

  private static mBlueToothMgr: BlueToothMgr | undefined = undefined;

  public Ins(){
    if(BlueToothMgr.mBlueToothMgr){
      BlueToothMgr.mBlueToothMgr = new BlueToothMgr();
    }
    return BlueToothMgr.mBlueToothMgr;
  }

  // STATE_OFF	0	Indicates Bluetooth is off.
  // STATE_TURNING_ON	1	Indicates Bluetooth is turning on.
  // STATE_ON	2	Indicates Bluetooth is on.
  // STATE_TURNING_OFF	3	Indicates Bluetooth is turning off.
  // STATE_BLE_TURNING_ON	4	Indicates Bluetooth is turning on in LE-only mode.
  // STATE_BLE_ON	5	Indicates Bluetooth is in LE-only mode.
  // STATE_BLE_TURNING_OFF	6	Indicates Bluetooth is turning off from LE-only mode.

  /**
   * Set Bluetooth access (on/off state)
   * @param isAccess true: Turn on Bluetooth
   */
  setBlueToothAccess(isAccess: boolean){
    try {
      if(isAccess){
        access.enableBluetooth();
        access.on('stateChange', (data: access.BluetoothState) => {
          let btStateMessage = this.switchState(data);
          if (btStateMessage == 'STATE_ON') {
            access.off('stateChange');
          }
          console.info('bluetooth statues: ' + btStateMessage);
        })
      }else{
        access.disableBluetooth();
        access.on('stateChange', (data: access.BluetoothState) => {
          let btStateMessage = this.switchState(data);
          if (btStateMessage == 'STATE_OFF') {
            access.off('stateChange');
          }
          console.info("bluetooth statues: " + btStateMessage);
        })
      }
    } catch (err) {
      console.error('errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
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
}
```  


```dart
import { access } from '@kit.ConnectivityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { BlueToothMgr } from '../manager/BlueToothMgr';
import { abilityAccessCtrl, common } from '@kit.AbilityKit';

@Entry
@Component
struct Index {

  private TAG: string = "BlueToothTest";

  // Bluetooth status
  @State isStartBlueTooth: boolean = false;
  @State userGrant: boolean = false;

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

  // Request permissions from the user
  async reqPermissionsFromUser(): Promise<number[]> {
    let context = getContext() as common.UIAbilityContext;
    let atManager = abilityAccessCtrl.createAtManager();
    let grantStatus = await atManager.requestPermissionsFromUser(context, ['ohos.permission.ACCESS_BLUETOOTH']);
    return grantStatus.authResults;
  }

  // Request Bluetooth permission from the user
  async requestBlueToothPermission() {
    let grantStatus = await this.reqPermissionsFromUser();
    for (let i = 0; i < grantStatus.length; i++) {
      if (grantStatus[i] === 0) {
        // User authorized, can proceed with target operations
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
      }
    }
    .height('100%')
    .width('100%')
  }
}
```  


**Permission Configuration:**  

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/73124bd21bc14bbb857dbbe5873ac819b1862.png)  

```dart
"requestPermissions": [
  {
    "name" : "ohos.permission.ACCESS_BLUETOOTH",
    "reason": "$string:permission_name",
    "usedScene": {
      "abilities": [
        "EntryAbility"
      ],
      "when":"inuse"
    }
  }
]
```  


**Operation Log:**  

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/16e68deab2984d6b99ad2a069668b5e7b1862.png)
