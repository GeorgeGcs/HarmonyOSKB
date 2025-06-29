【HarmonyOS】鸿蒙应用蓝牙功能实现（一）

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

## 前言

蓝牙技术是一种无线通信技术，可以在短距离内传输数据。它是由爱立信公司于1994年提出的，使用2.4 GHz的ISM频段，可以在10米左右的距离内进行通信。可以用于连接手机、耳机、音箱、键盘、鼠标、打印机等各种设备。

特点是低功耗、低成本、简单易用。目前已经发展到了第五代，支持更高的数据传输速率和更广的覆盖范围。

**蓝牙实现原理**

蓝牙的实现原理是基于无线电技术的短距离通信协议，使用2.4GHz频段的无线电波进行通信，使用频率跳跃技术（Frequency Hopping Spread Spectrum，FHSS）来避免与其他无线设备的干扰。
在通信过程中，蓝牙设备会发送和接收数据包，并且使用不同的蓝牙协议来控制通信流程和数据传输。

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/e67b10ed88514ad98da40b309b84047cb1862.png)

**蓝牙跳频技术的原理**

蓝牙跳频技术主要基于频率跳跃技术，即通过在不同频率上快速跳跃来发送数据。这种技术可以防止干扰和噪声影响数据传输，提高数据传输的可靠性。具体来说，当某条频率受到干扰或噪声时，系统会自动切换到其他频率上进行传输，从而确保数据的完整性和稳定性。

## DEMO示例

以下为蓝牙开关和状态控制

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

  // 蓝牙状态
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
      }
    }
    .height('100%')
    .width('100%')
  }
}
```

**加权限配置：**

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

**操作日志：**

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/16e68deab2984d6b99ad2a069668b5e7b1862.png)

