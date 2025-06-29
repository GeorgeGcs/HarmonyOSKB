## 【HarmonyOS 5】鸿蒙中的UIAbility详解（二）

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

## 一、前言

今天我们继续深入讲解UIAbility，根据下图可知，在鸿蒙中UIAbility继承于Ability，开发者无法直接继承Ability。只能使用其两个子类：UIAbility和ExtensionAbility。
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_66ff1b40.png 'image.png')


本文将对UIAbility的三种启动模式，数据如何传递，订阅UIAbility生命周期变化，订阅设备的信息变化进行讲解。

## 二、UIAbility的三种启动模式

singleton（单实例模式），说人话就是单例模式，App任务进度中该UIAbilty只能存在一个。

multiton（多实例模式），说人话就是单例模式，App任务进度中该UIAbilty能存在多个。

specified（指定实例模式），这玩意就有点复杂了，参见下图，主要通过唯一标识key来作为判断量，看该UIAbility是创建新的，还是使用已创建的。
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_52884910.png 'image.png')

在module.json5配置文件中的launchType字段配置为singleton，multiton，specified即可。

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

## 三、UIAbility的数据如何传递

一般而言，UIAbility的数据传递有两种场景：
**1、A UIAbility数据传递给 B UIAbility。**
**2、A UIAbility数据传给内部的page或者自定义view。**

同样通用数据传递的方式有以下三种方式进行：
**1. 单例对象维护数据**
通过单例对象和注册回调的机制，将数据进行传导：

```dart

export class EventDataMgr {

  private static mEventDataMgr : EventDataMgr  | null = null;

  // 需要处理的数据
  public mData: XXX | null = null;

  /**
   * 获取实例
   * @returns
   */
  public static Ins(){

    if(!EventDataMgr .mEventDataMgr ){
      EventDataMgr .mEventDataMgr = new EventDataMgr();
    }
    return EventDataMgr .mEventDataMgr;
  }
}
```

**2. EventHub，Emitter**
我是不建议使用Emitter作为数据传递方案，因为它太重了，使用起来也没有EventHub方便。

而EventHub是从context中获取，所以在多Ability数据共享场景中，需要对EventHub做唯一性处理

```dart
import { common } from '@kit.AbilityKit';

export class EventHubUtils {

  private static mEventHub: common.EventHub | null = null;

  /**
   * 获取事件通知实例
   * @returns
   */
  public static getEventHub(){
    // 封装唯一性。因为在不同window中会导致获取的eventhub 不是一个。
    if(!EventHubUtils.mEventHub){
      let context = getContext() as common.UIAbilityContext;
      EventHubUtils.mEventHub = context.eventHub;
      console.log("EventHubUtils", "EventIns mEventHub done !");
    }
    return EventHubUtils.mEventHub;
  }
}
```

**3. AppStroage或者LocalStroage**
AppStroage主要用于多UIAbility共享数据进行传递的业务场景。
LocalStroage用于UIAbility内部到page或者自定义view进行传递传递的业务场景。

```dart
import { UIAbility } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

export default class EntryAbility extends UIAbility {

  storage: LocalStorage = new LocalStorage();

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

## 四、订阅UIAbility生命周期变化

该场景主要用于统计SDK或者三方应用自己进行业务用户时长交互的数据统计工作。

当进程内的UIAbility生命周期变化时，如创建、可见/不可见、获焦/失焦、销毁等，会触发相应的回调函数。每次注册回调函数时，都会返回一个监听生命周期的ID，此ID会自增+1。当超过监听上限数量2^63-1时，会返回-1。

```dart
import { AbilityConstant, AbilityLifecycleCallback, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import  { BusinessError } from '@kit.BasicServicesKit';


const TAG: string = '[LifecycleAbility]';
const DOMAIN_NUMBER: number = 0xFF00;


export default class LifecycleAbility extends UIAbility {
  // 定义生命周期ID
  lifecycleId: number = -1;


  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 定义生命周期回调对象
    let abilityLifecycleCallback: AbilityLifecycleCallback = {
      // 当UIAbility创建时被调用
      onAbilityCreate(uiAbility) {
        hilog.info(DOMAIN_NUMBER, TAG, `onAbilityCreate uiAbility.launchWant: ${JSON.stringify(uiAbility.launchWant)}`);
      },
      // 当窗口创建时被调用
      onWindowStageCreate(uiAbility, windowStage: window.WindowStage) {
        hilog.info(DOMAIN_NUMBER, TAG, `onWindowStageCreate uiAbility.launchWant: ${JSON.stringify(uiAbility.launchWant)}`);
        hilog.info(DOMAIN_NUMBER, TAG, `onWindowStageCreate windowStage: ${JSON.stringify(windowStage)}`);
      },
      // 当窗口处于活动状态时被调用
      onWindowStageActive(uiAbility, windowStage: window.WindowStage) {
        hilog.info(DOMAIN_NUMBER, TAG, `onWindowStageActive uiAbility.launchWant: ${JSON.stringify(uiAbility.launchWant)}`);
        hilog.info(DOMAIN_NUMBER, TAG, `onWindowStageActive windowStage: ${JSON.stringify(windowStage)}`);
      },
      // 当窗口处于非活动状态时被调用
      onWindowStageInactive(uiAbility, windowStage: window.WindowStage) {
        hilog.info(DOMAIN_NUMBER, TAG, `onWindowStageInactive uiAbility.launchWant: ${JSON.stringify(uiAbility.launchWant)}`);
        hilog.info(DOMAIN_NUMBER, TAG, `onWindowStageInactive windowStage: ${JSON.stringify(windowStage)}`);
      },
      // 当窗口被销毁时被调用
      onWindowStageDestroy(uiAbility, windowStage: window.WindowStage) {
        hilog.info(DOMAIN_NUMBER, TAG, `onWindowStageDestroy uiAbility.launchWant: ${JSON.stringify(uiAbility.launchWant)}`);
        hilog.info(DOMAIN_NUMBER, TAG, `onWindowStageDestroy windowStage: ${JSON.stringify(windowStage)}`);
      },
      // 当UIAbility被销毁时被调用
      onAbilityDestroy(uiAbility) {
        hilog.info(DOMAIN_NUMBER, TAG, `onAbilityDestroy uiAbility.launchWant: ${JSON.stringify(uiAbility.launchWant)}`);
      },
      // 当UIAbility从后台转到前台时触发回调
      onAbilityForeground(uiAbility) {
        hilog.info(DOMAIN_NUMBER, TAG, `onAbilityForeground uiAbility.launchWant: ${JSON.stringify(uiAbility.launchWant)}`);
      },
      // 当UIAbility从前台转到后台时触发回调
      onAbilityBackground(uiAbility) {
        hilog.info(DOMAIN_NUMBER, TAG, `onAbilityBackground uiAbility.launchWant: ${JSON.stringify(uiAbility.launchWant)}`);
      },
      // 当UIAbility迁移时被调用
      onAbilityContinue(uiAbility) {
        hilog.info(DOMAIN_NUMBER, TAG, `onAbilityContinue uiAbility.launchWant: ${JSON.stringify(uiAbility.launchWant)}`);
      }
    };
    // 获取应用上下文
    let applicationContext = this.context.getApplicationContext();
    try {
      // 注册应用内生命周期回调
      this.lifecycleId = applicationContext.on('abilityLifecycle', abilityLifecycleCallback);
    } catch (err) {
      let code = (err as BusinessError).code;
      let message = (err as BusinessError).message;
      hilog.error(DOMAIN_NUMBER, TAG, `Failed to register applicationContext. Code is ${code}, message is ${message}`);
    }


    hilog.info(DOMAIN_NUMBER, TAG, `register callback number: ${this.lifecycleId}`);
  }
  //...
  onDestroy(): void {
    // 获取应用上下文
    let applicationContext = this.context.getApplicationContext();
    try {
      // 取消应用内生命周期回调
      applicationContext.off('abilityLifecycle', this.lifecycleId);
    } catch (err) {
      let code = (err as BusinessError).code;
      let message = (err as BusinessError).message;
      hilog.error(DOMAIN_NUMBER, TAG, `Failed to unregister applicationContext. Code is ${code}, message is ${message}`);
    }
  }
}
```

## 五、订阅设备的信息变化

该场景主要是系统配置更新时调用。例如设备的语言环境，设备横竖屏状态，深浅模式等。

在UIAbility中onConfigurationUpdate()回调方法中实现监测系统这些配置信息的变化。

```dart
import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';


const TAG: string = '[EntryAbility]';
const DOMAIN_NUMBER: number = 0xFF00;


let systemLanguage: string | undefined; // 系统当前语言


export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    systemLanguage = this.context.config.language; // UIAbility实例首次加载时，获取系统当前语言
    hilog.info(DOMAIN_NUMBER, TAG, `systemLanguage is ${systemLanguage}`);
  }


  onConfigurationUpdate(newConfig: Configuration): void {
            console.info(`envCallback onConfigurationUpdated success: ${JSON.stringify(config)}`);
        // 表示应用程序的当前语言，例如“zh"。
        let language = config.language;
        // 表示深浅色模式，默认为浅色。取值范围：
        //
        // - COLOR_MODE_NOT_SET：未设置
        //
        // - COLOR_MODE_LIGHT：浅色模式
        //
        // - COLOR_MODE_DARK：深色模式
        let colorMode = config.colorMode;
        // 表示屏幕方向，取值范围：
        //
        // - DIRECTION_NOT_SET：未设置
        //
        // - DIRECTION_HORIZONTAL：水平方向
        //
        // - DIRECTION_VERTICAL：垂直方向
        let direction = config.direction;
        let screenDensity = config.screenDensity;
        let displayId = config.displayId;
        let hasPointerDevice = config.hasPointerDevice;
        let fontId = config.fontId;
        let fontSizeScale = config.fontSizeScale;
        let fontWeightScale = config.fontWeightScale;
        let mcc = config.mcc;
        let mnc = config.mnc;
  }
  // ...
}
```
