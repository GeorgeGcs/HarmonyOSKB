# 【HarmonyOS】Experience Sharing on HarmonyOS Message Push (Part 1)  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services##HarmonyOS Financial Applications (Financial Management#  


## Preface  

After researching the implementation of HarmonyOS message push in recent days, I have formed a development design plan and would like to share my insights.  

Initially, I thought this was a simple function—merely communicating with Huawei servers to send notifications, setting up notification bar UI, and handling jumps or displays based on received keywords. However, diving into the official documentation revealed a much more complex landscape, especially with third-party push SDKs.  


## Effect and Functionality of HarmonyOS Push Kit  

Understanding the background of a technology is crucial before delving into details. This approach provides a framework for thinking and helps focus on critical details. Diving straight into API coding without context is inefficient, like navigating a game without a map.  

HarmonyOS uses Huawei's Push Kit as the message push service, part of HMS Core - App Services.  

### (1) Service Definition  
Push Kit is a message push platform provided by Huawei, establishing a messaging channel from the cloud to end devices. By integrating Push Kit, you can push real-time messages to client applications, fostering user engagement and increasing activity.  
![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/428b139f93f04259b7f1b1d8cac36c35b1862.png)  

### (2) Service Performance  
Notification messages are delivered directly via the push service channel and displayed in the device's notification center, requiring no background process. Users can trigger actions (e.g., opening an app or webpage) by clicking notification messages.  

Customize notification styles (thumbnails, buttons) and alert methods (lock screen, banners, badges) to attract users and increase daily active users.  

### Common Scenarios  
- Instant messaging notifications  
- Account activity alerts  


## Enabling Push Service and Configuring Settings on AGC Platform  

First, enable the push service for your app on the Huawei AGC platform—push functionality is not enabled by default.  
![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/92c0c48e1ed8487a951ba6e0e6940801b1862.png)  

After enabling the service, go to the configuration tab. Complete steps 2 and 3 as shown:  
![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/703b2b1f683a430b928bd2338315a7b6b1862.png)  

Huawei's push includes standard default types and self-classified rights. Without enabling step 3, only 2 notifications can be sent daily. Self-classified rights require application—follow the prompts on the platform.  


## Code Explanation  

### Configuration in module.json5  
```json
"metadata": [
  {
    "name": "client_id",
    "value": "xxxxxx" // Client ID from AGC platform
  },
]
```  

### Obtaining Push Token and Binding User ID  
The following code demonstrates obtaining a Push Kit token and binding a user ID, which is essential for targeted pushes:  

```typescript
import { AbilityConstant, UIAbility, Want } from '@ohos.app.ability';
import { hilog } from '@ohos.hiviewdfx';
import { window } from '@ohos.arkui';
import { AAID, pushCommon, pushService } from '@ohos.push';
import { BusinessError } from '@ohos.base';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');

    // Get AAID (Anonymous Application Identifier)
    AAID.getAAID((err: BusinessError, data: string) => {
      if (err) {
        hilog.error(0x0000, 'testTag', 'Failed to get AAID: %{public}d %{public}s', err.code, err.message);
      } else {
        hilog.info(0x0000, 'testTag', 'Succeeded in getting AAID');
      }
    });

    // Get push token
    pushService.getToken((err: BusinessError, data: string) => {
      if (err) {
        hilog.error(0x0000, 'testTag', 'Failed to get push token: %{public}d %{public}s', err.code, err.message);
      } else {
        hilog.info(0x0000, 'testTag', 'Succeeded in getting push token');
      }
    });

    // Define profile ID to bind (recommend using an anonymous identifier instead of real user ID)
    const profileId: string = '1****9';
    // Bind app profile ID (application account type in this example)
    pushService.bindAppProfileId(pushCommon.AppProfileType.PROFILE_TYPE_APPLICATION_ACCOUNT, profileId, (err: BusinessError) => {
      if (err) {
        hilog.error(0x0000, 'testTag', 'Failed to bind app profile id: %{public}d %{public}s', err.code, err.message);
      } else {
        hilog.info(0x0000, 'testTag', 'Succeeded in binding app profile id.');
      }
    });
  }

  // Other lifecycle methods
  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
  }
}
```  


## Key Insights  

1. **SDK-Free Integration**: Push Kit APIs are下沉 (sunk) into HarmonyOS, allowing integration without additional SDKs.  
2. **System-Level Long Connection**: Enables real-time message delivery even when the app is not running.  
3. **Daily Push Limit**: Defaults to 2 notifications per day; apply for self-classified rights for higher limits.  
4. **User ID Binding**: Use anonymous identifiers instead of real user IDs for better privacy protection.  
5. **AGC Configuration**: Ensure client ID and profile binding are correctly set up to avoid push failures.  

By leveraging Push Kit's capabilities and following best practices, developers can implement robust message push functionality while maintaining user privacy and experience. Stay tuned for Part 2, which will delve into advanced push scenarios and optimization strategies.