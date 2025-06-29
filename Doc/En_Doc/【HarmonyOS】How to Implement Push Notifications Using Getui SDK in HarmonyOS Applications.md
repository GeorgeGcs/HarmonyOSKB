## 【HarmonyOS】How to Implement Push Notifications Using Getui SDK in HarmonyOS Applications  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services ##HarmonyOS Financial Applications （Financial Management#  

### Preface  

Getui and JPush are mature third-party push SDKs in the market. This article explains how to integrate the Getui SDK into HarmonyOS applications.  

Third-party push SDKs offer significant advantages: they allow backend servers to use a unified API, with SDK vendors handling platform-specific differences. On the client side, SDKs provide further encapsulation and enhanced functionality, saving development and maintenance costs. The main drawback is dependency on SDK vendors for API updates, as developers must wait for vendors to upgrade before proceeding.  


### Platform Registration and Configuration  

HarmonyOS applications often choose Getui if iOS and Android versions already use Getui, ensuring consistency during migration. Company operations teams typically manage Getui platform accounts, but developers need test accounts for integration.  

1. **Register on Getui Platform**:  
   The registration process on [Getui Platform](https://dev.getui.com/dev/#/login?mode=register) is straightforward. After registration, log in to create a test application. The platform will generate an **APPID or APPKey** required for SDK initialization. Note that third-party SDKs often require internet access for client-server validation, which may cause issues in internal network environments.  


2. **Configure Huawei AGC Push Services**:  
   For details, refer to:  
   [【HarmonyOS】Experience on HarmonyOS Message Push (Part 1)](https://blog.csdn.net/superherowupan/article/details/140476623?spm=1001.2014.3001.5502)  

3. **Bind Getui and Huawei AGC Platforms**:  
   In the Getui developer center, go to **App Management** > select the HarmonyOS app > **Message Push** > **Configuration Management** > **App Configuration** > **HarmonyOS**. Upload the JSON file containing Huawei AGC credentials (generated in the [Getui HarmonyOS setup guide](https://docs.getui.com/getui/mobile/harmonyos/harmonyosstudio/)).  


### Obtain and Run the SDK Demo  

After registering the app, download the client and server SDKs from Getui. The SDK is provided as a demo project with the HAR package in the `libs` directory.  

1. **SDK Initialization**:  
   In the entry ability's `onCreate` method, initialize the SDK with the APPID obtained from the Getui platform:  

```dart
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import hilog from '@ohos.hilog';
import UIAbility from '@ohos.app.ability.UIAbility';
import Want from '@ohos.app.ability.Want';
import window from '@ohos.window';
import common from '@ohos.app.ability.common';

import PushManager from 'library';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'EntryAbility', '%{public}s', 'Ability onCreate');
    PushManager.initialize({
      appId: 'YOUR_APP_ID', // Replace with your Getui APPID
      context: getContext(this) as common.UIAbilityContext,
      onSuccess: cid => {
        hilog.debug(0x0000, "EntryAbility", '%{public}s', "cid = " + cid);
      },
      onFailed: error => {
        hilog.debug(0x0000, "EntryAbility", '%{public}s', "error = " + error);
      }
    })
  }
  
  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
    });
  }
}
```  

2. **Configure Huawei AGC Credentials**:  
   Obtain the Huawei AGC project ID and configure it in the project, as detailed in:  
   [【HarmonyOS】Experience on HarmonyOS Message Push (Part 1)](https://blog.csdn.net/superherowupan/article/details/140476623?spm=1001.2014.3001.5502)  

3. **Test the SDK**:  
   - Compile the app with your Huawei AGC test app's signature.  
   - Enable notification permissions before testing.  
   - **Important**: Ensure the device is connected to the internet for SDK validation!  


### Create and Test Push Notifications  

1. **Obtain CID**:  
   The CID (Client ID) is generated during SDK initialization and logged in the console.  

2. **Send Test Push**:  
   Use the Getui console to send a test push using the CID. For server-side API details, refer to [Getui RestAPI V2](https://docs.getui.com/getui/server/rest_v2/introduction/).  
