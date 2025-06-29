# 【HarmonyOS 5】In-Depth Explanation of UIAbility in HarmonyOS (Part 2)  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services##HarmonyOS Financial Applications (Financial Management#  

## 一、Preface  

Today, we continue to delve deeper into UIAbility. As shown in the following diagram, in HarmonyOS, UIAbility extends from Ability, and developers cannot directly inherit from Ability. They can only use its two subclasses: UIAbility and ExtensionAbility.  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_66ff1b40.png 'image.png')  

This article will explain the three launch modes of UIAbility, how to pass data, subscribe to UIAbility lifecycle changes, and subscribe to device information changes.  


## 二、Three Launch Modes of UIAbility  

1. **Singleton (Single Instance Mode)**: In simple terms, it is a singleton pattern where only one instance of this UIAbility can exist in the App's task progress.  

2. **Multiton (Multiple Instance Mode)**: In simple terms, it allows multiple instances of this UIAbility to exist in the App's task progress.  

3. **Specified (Designated Instance Mode)**: This is slightly more complex (refer to the diagram below). It mainly uses a unique identifier key as a judgment criterion to determine whether to create a new UIAbility instance or use an existing one.  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_52884910.png 'image.png')  

You can configure the launchType field in the module.json5 configuration file as singleton, multiton, or specified.  
```dart
{
  "module": {
    // ...
    "abilities": [
      {
        "launchType": "singleton",
        // ...
      }
    ]
  }
}
```  


## 三、How to Pass Data in UIAbility  

Generally, there are two scenarios for data passing in UIAbility:  
**1. Passing data from UIAbility A to UIAbility B.**  
**2. Passing data from UIAbility A to internal pages or custom views.**  

There are three common ways to pass data:  

### 1. Singleton Object for Data Maintenance  
Transfer data through a singleton object and callback registration mechanism:  
```dart
export class EventDataMgr {
  private static mEventDataMgr: EventDataMgr | null = null;
  // Data to be processed
  public mData: XXX | null = null;

  /**
   * Get the singleton instance
   * @returns
   */
  public static getInstance(): EventDataMgr {
    if (!EventDataMgr.mEventDataMgr) {
      EventDataMgr.mEventDataMgr = new EventDataMgr();
    }
    return EventDataMgr.mEventDataMgr;
  }
}
```  

### 2. EventHub and Emitter  
Using Emitter as a data transfer solution is not recommended because it is too heavy and less convenient than EventHub.  

EventHub is obtained from the context, so in scenarios where data is shared among multiple Abilities, uniqueness processing is required for EventHub:  
```dart
import { common } from '@kit.AbilityKit';

export class EventHubUtils {
  private static mEventHub: common.EventHub | null = null;

  /**
   * Get the event notification instance
   * @returns
   */
  public static getEventHub(): common.EventHub {
    // Enforce uniqueness (different windows may return different EventHub instances)
    if (!EventHubUtils.mEventHub) {
      const context = getContext() as common.UIAbilityContext;
      EventHubUtils.mEventHub = context.eventHub;
      console.log("EventHubUtils", "Event instance initialized!");
    }
    return EventHubUtils.mEventHub;
  }
}
```  

### 3. AppStorage or LocalStorage  
- **AppStorage** is mainly used for business scenarios where data needs to be shared and transferred among multiple UIAbilities.  
- **LocalStorage** is used for data transfer from within a UIAbility to its pages or custom views.  
```dart
import { UIAbility } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

export default class EntryAbility extends UIAbility {
  private storage: LocalStorage = new LocalStorage();

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', this.storage, (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
  }
}
```  


## 四、Subscribing to UIAbility Lifecycle Changes  

This scenario is mainly used for data statistics in SDKs or third-party applications to track user interaction duration.  

When the lifecycle of a UIAbility within the process changes (such as creation, visibility/invisibility, focus/loss of focus, destruction, etc.), corresponding callback functions are triggered. Each time a callback function is registered, a lifecycle monitoring ID is returned, which increments by 1. When the upper limit of monitoring (2^63-1) is exceeded, -1 is returned.  
```dart
import { AbilityConstant, AbilityLifecycleCallback, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG: string = '[LifecycleAbility]';
const DOMAIN_NUMBER: number = 0xFF00;

export default class LifecycleAbility extends UIAbility {
  // Define the lifecycle ID
  private lifecycleId: number = -1;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // Define the lifecycle callback object
    const abilityLifecycleCallback: AbilityLifecycleCallback = {
      // Called when the UIAbility is created
      onAbilityCreate(uiAbility: UIAbility): void {
        hilog.info(DOMAIN_NUMBER, TAG, `onAbilityCreate uiAbility.launchWant: ${JSON.stringify(uiAbility.launchWant)}`);
      },
      // Called when the window stage is created
      onWindowStageCreate(uiAbility: UIAbility, windowStage: window.WindowStage): void {
        hilog.info(DOMAIN_NUMBER, TAG, `onWindowStageCreate uiAbility.launchWant: ${JSON.stringify(uiAbility.launchWant)}`);
        hilog.info(DOMAIN_NUMBER, TAG, `onWindowStageCreate windowStage: ${JSON.stringify(windowStage)}`);
      },
      // Called when the window stage is active
      onWindowStageActive(uiAbility: UIAbility, windowStage: window.WindowStage): void {
        hilog.info(DOMAIN_NUMBER, TAG, `onWindowStageActive uiAbility.launchWant: ${JSON.stringify(uiAbility.launchWant)}`);
        hilog.info(DOMAIN_NUMBER, TAG, `onWindowStageActive windowStage: ${JSON.stringify(windowStage)}`);
      },
      // Called when the window stage is inactive
      onWindowStageInactive(uiAbility: UIAbility, windowStage: window.WindowStage): void {
        hilog.info(DOMAIN_NUMBER, TAG, `onWindowStageInactive uiAbility.launchWant: ${JSON.stringify(uiAbility.launchWant)}`);
        hilog.info(DOMAIN_NUMBER, TAG, `onWindowStageInactive windowStage: ${JSON.stringify(windowStage)}`);
      },
      // Called when the window stage is destroyed
      onWindowStageDestroy(uiAbility: UIAbility, windowStage: window.WindowStage): void {
        hilog.info(DOMAIN_NUMBER, TAG, `onWindowStageDestroy uiAbility.launchWant: ${JSON.stringify(uiAbility.launchWant)}`);
        hilog.info(DOMAIN_NUMBER, TAG, `onWindowStageDestroy windowStage: ${JSON.stringify(windowStage)}`);
      },
      // Called when the UIAbility is destroyed
      onAbilityDestroy(uiAbility: UIAbility): void {
        hilog.info(DOMAIN_NUMBER, TAG, `onAbilityDestroy uiAbility.launchWant: ${JSON.stringify(uiAbility.launchWant)}`);
      },
      // Called when the UIAbility moves to the foreground from the background
      onAbilityForeground(uiAbility: UIAbility): void {
        hilog.info(DOMAIN_NUMBER, TAG, `onAbilityForeground uiAbility.launchWant: ${JSON.stringify(uiAbility.launchWant)}`);
      },
      // Called when the UIAbility moves to the background from the foreground
      onAbilityBackground(uiAbility: UIAbility): void {
        hilog.info(DOMAIN_NUMBER, TAG, `onAbilityBackground uiAbility.launchWant: ${JSON.stringify(uiAbility.launchWant)}`);
      },
      // Called when the UIAbility is migrated
      onAbilityContinue(uiAbility: UIAbility): void {
        hilog.info(DOMAIN_NUMBER, TAG, `onAbilityContinue uiAbility.launchWant: ${JSON.stringify(uiAbility.launchWant)}`);
      }
    };
    // Get the application context
    const applicationContext = this.context.getApplicationContext();
    try {
      // Register the in-app lifecycle callback
      this.lifecycleId = applicationContext.on('abilityLifecycle', abilityLifecycleCallback);
    } catch (err) {
      const code = (err as BusinessError).code;
      const message = (err as BusinessError).message;
      hilog.error(DOMAIN_NUMBER, TAG, `Failed to register applicationContext. Code: ${code}, Message: ${message}`);
    }

    hilog.info(DOMAIN_NUMBER, TAG, `Registered callback ID: ${this.lifecycleId}`);
  }

  onDestroy(): void {
    // Get the application context
    const applicationContext = this.context.getApplicationContext();
    try {
      // Unregister the in-app lifecycle callback
      applicationContext.off('abilityLifecycle', this.lifecycleId);
    } catch (err) {
      const code = (err as BusinessError).code;
      const message = (err as BusinessError).message;
      hilog.error(DOMAIN_NUMBER, TAG, `Failed to unregister applicationContext. Code: ${code}, Message: ${message}`);
    }
  }
}
```  


## 五、Subscribing to Device Information Changes  

This scenario is triggered when system configurations are updated, such as device language environment, screen orientation, light/dark mode, etc.  

Monitor changes in these system configurations by implementing the onConfigurationUpdate() callback method in UIAbility.  
```dart
import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = '[EntryAbility]';
const DOMAIN_NUMBER: number = 0xFF00;

let systemLanguage: string | undefined; // Current system language

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    systemLanguage = this.context.config.language; // Get the current system language when the UIAbility instance is first loaded
    hilog.info(DOMAIN_NUMBER, TAG, `System language: ${systemLanguage}`);
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    console.info(`envCallback onConfigurationUpdated success: ${JSON.stringify(newConfig)}`);
    // Current application language, e.g., "zh"
    const language = newConfig.language;
    // Light/dark mode, default is light. Values:
    // - COLOR_MODE_NOT_SET: Not set
    // - COLOR_MODE_LIGHT: Light mode
    // - COLOR_MODE_DARK: Dark mode
    const colorMode = newConfig.colorMode;
    // Screen orientation. Values:
    // - DIRECTION_NOT_SET: Not set
    // - DIRECTION_HORIZONTAL: Horizontal
    // - DIRECTION_VERTICAL: Vertical
    const direction = newConfig.direction;
    const screenDensity = newConfig.screenDensity;
    const displayId = newConfig.displayId;
    const hasPointerDevice = newConfig.hasPointerDevice;
    const fontId = newConfig.fontId;
    const fontSizeScale = newConfig.fontSizeScale;
    const fontWeightScale = newConfig.fontWeightScale;
    const mcc = newConfig.mcc;
    const mnc = newConfig.mnc;
  }
}
```