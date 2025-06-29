# 【HarmonyOS 5】Introduction, Definition, and Authorization Guide for Application Permissions in HarmonyOS  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services##HarmonyOS Financial Applications (Financial Management#  


Permissions in the HarmonyOS system are categorized into different levels and authorization methods based on their impact on user privacy and system security. Below is a detailed explanation of permission levels, authorization methods, and application processes.  


## 一、Permission APL Levels  

HarmonyOS classifies permissions into three levels based on the risk they pose to user privacy and the operating system: **normal, system_basic, system_core**.  

1. **Normal Permissions**:  
   - Granted to ordinary applications.  
   - Allows access to resources like the camera, Wi-Fi information, etc.  

2. **System_Basic Permissions**:  
   - Granted to special applications.  
   - Allows access to sensitive resources like user identity authentication.  

3. **System_Core Permissions**:  
   - Granted to system applications.  
   - Allows access to all system resources.  


## 二、Authorization Methods  

Permissions can be authorized in two ways based on how they are granted to applications: **system_grant, user_grant**.  

1. **System_Grant (System Authorization)**:  
   - Permissions are automatically granted if configured in the application.  
   - No user interaction is required.  

2. **User_Grant (User Authorization)**:  
   - Applications must explicitly request permission before use.  
   - Users decide whether to authorize through a prompt.  


## 三、Access Control List (ACL)  

ACL (Access Control List) addresses scenarios where a low-APL application needs to use high-level permissions:  
- Enables limited access to restricted permissions for specific business scenarios.  
- Applications must undergo review by the AppGallery Connect (AGC) based on their usage scenarios.  
- Restricted permissions are typically not available to third-party applications. Special scenarios require submitting application materials to AGC for permission certification.  
- **Alternative solutions (e.g., Pickers/controls) are recommended to avoid complex permission application processes.**  


## 四、Permission Application Process for Normal-Level Applications  

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/403340bd3daa4c5490c7679f753a6b31b1862.png)  


## 五、Permission Application Code Example  

### 1. Declare Permissions in Configuration  

Take motor vibration and camera permissions as examples in `module.json5`:  
```json
{
  "module": {
    "name": "entry",
    "type": "entry",
    "description": "$string:module_desc",
    "mainElement": "EntryAbility",
    "deviceTypes": [
      "phone",
      "tablet",
      "2in1"
    ],
    "deliveryWithInstall": true,
    "installationFree": false,
    "pages": "$profile:main_pages",
    "abilities": [
      {
        "name": "EntryAbility",
        "srcEntry": "./ets/entryability/EntryAbility.ets",
        "description": "$string:EntryAbility_desc",
        "icon": "$media:layered_image",
        "label": "$string:EntryAbility_label",
        "startWindowIcon": "$media:startIcon",
        "startWindowBackground": "$color:start_window_background",
        "exported": true,
        "skills": [
          {
            "entities": [
              "entity.system.home"
            ],
            "actions": [
              "action.system.home"
            ]
          }
        ]
      }
    ],
    "requestPermissions": [
      {
        // Motor vibration (system permission, no user authorization needed)
        "name": "ohos.permission.VIBRATE"
      },
      {
        // Camera permission (user permission, requires user authorization)
        "name": "ohos.permission.CAMERA",
        "reason": "$string:Camera_reason",
        "usedScene": {
          "when": "always"
        }
      }
    ]
  }
}
```  

**Refer to the [Application Permission List](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/permissions-for-all-V5?catalogVersion=V5) for specific permission classifications.**  


### 2. Request User Authorization Before Using Permissions  

Modern applications request permissions when a specific function is triggered (e.g., camera access when a user clicks a button), improving user experience:  

```typescript
import { abilityAccessCtrl, common } from '@ohos.app.ability';

/**
 * Permission utility class
 */
export class PermissionsUtil {
  static async requestPermissionsFromUser(): Promise<number[]> {
    const context = getContext() as common.UIAbilityContext;
    const atManager = abilityAccessCtrl.createAtManager();
    const grantStatus = await atManager.requestPermissionsFromUser(context, ['ohos.permission.CAMERA']);
    return grantStatus.authResults;
  }

  /**
   * Request camera permission
   * @returns Authorization result
   */
  static async requestCameraPermission(): Promise<boolean> {
    const grantStatus = await PermissionsUtil.requestPermissionsFromUser();
    for (let i = 0; i < grantStatus.length; i++) {
      if (grantStatus[i] === 0) {
        // User authorized
        return true;
      }
    }
    return false;
  }
}
```  

```typescript
import { PermissionsUtil } from '../../utils/PermissionsUtil';
import { BusinessError } from '@ohos.base';
import { promptAction } from '@ohos.arkui';

/**
 * Permission request page component
 */
@Entry
@Component
struct PermissionPage {
  private TAG: string = "permissionPage";

  private showToast(content: string) {
    try {
      promptAction.showToast({
        message: content,
        duration: 2000
      });
    } catch (error) {
      const message = (error as BusinessError).message;
      const code = (error as BusinessError).code;
      console.error(this.TAG, `showToast error code: ${code}, message: ${message}`);
    }
  }

  private onClickCamera = async () => {
    console.log(this.TAG, " onClickCamera");
    const isAuthorized: boolean = await PermissionsUtil.requestCameraPermission();
    if (isAuthorized) {
      this.showToast("User authorized camera access");
    } else {
      this.showToast("User denied camera access");
    }
  }

  build() {
    Row() {
      Button("Access Camera")
        .fontSize(px2vp(42))
        .size({
          width: px2vp(350),
          height: px2vp(200)
        })
        .onClick(this.onClickCamera)
    }
    .size({
      width: "100%",
      height: "100%"
    })
    .justifyContent(FlexAlign.Center)
  }
}
```  


## Key Notes  

1. **User Authorization Flow**:  
   - If a user denies a permission request, subsequent requests will fail by default.  
   - Guide users to enable permissions in system settings instead of prompting again via the app.  

2. **Permission Review**:  
   - Applications using restricted permissions must pass AGC review based on their usage scenarios.  
   - Alternative UI components (e.g., Pickers) are recommended to avoid complex permission applications.  

By following these guidelines, developers can properly handle permission management in HarmonyOS applications, balancing functionality with user privacy and security.
