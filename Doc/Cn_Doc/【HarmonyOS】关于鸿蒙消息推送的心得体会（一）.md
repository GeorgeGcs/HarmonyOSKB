## 【HarmonyOS】关于鸿蒙消息推送的心得体会（一）

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

## 前言

这几天调研了鸿蒙消息推送的实现方式，形成了开发设计方案，颇有体会，与各位分享。

虽然没做之前觉得很简单的小功能，貌似只需要和华为服务器通信，发送通知即可，然后做做通知栏的UI设置，应用接收关键字处理跳转or展示表现。

但是万万没想到，光是摸了一下官方文档就感觉水很深。更别说第三方厂商封装的推送SDK了。

## 鸿蒙Push Kit的效果和功能表现

学习和了解一个事物，我本人喜欢先研究其背景，知其然才能知其所以然。这样我们才能有具体的事务框架思路，在细节上才能有的放矢。若一上来就看API写代码，就像打游戏不看全地图一样，效率会很低。

首先我们要知道，在鸿蒙中使用的推送服务，是华为HMS能力中的推送服务。

**HMS Core - App Services - PushKit。**

**(1) 服务定义：**
推送服务（Push Kit）是华为提供的消息推送平台，建立了从云端到终端的消息推送通道。您通过集成推送服务，可以向客户端应用实时推送消息，构筑良好的用户关系，提升用户的感知度和活跃度。

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/428b139f93f04259b7f1b1d8cac36c35b1862.png)

**(2) 服务表现：**
通知栏消息通过推送服务通道直接下发，在终端设备的通知中心呈现，不需要应用进程驻留后台。用户点击通知栏消息后触发相应的动作，如打开应用、打开网页等。

可以自定义通知栏消息样式（小图、按钮等）和提醒方式（锁屏、横幅和角标）来吸引用户，从而提高应用的日活跃用户数量。

**服务常用场景**：即时通讯消息传送、帐号动态等。

## AGC平台开通推送服务，配置推送设置项

首先要去华为AGC平台去将你的应用开通推送服务，一般应用是不会有推送，必须去平台开通才行。

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/92c0c48e1ed8487a951ba6e0e6940801b1862.png)

开通服务之后，点击配置tab，进去配置页面。可以看到如图所示内容，刚才我们已经完成第一步，现在需要进行第二步和第三步。

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/703b2b1f683a430b928bd2338315a7b6b1862.png)

华为的推送包括标准默认的推送类型 和 自分类权益。如果不开通第三步，每天最多只能推送两条通知。当然自分类权益是需要申请，点击去看要求傻瓜操作即可。

# 代码讲解

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/83427008257b4e44abca228a8a03f2c7b1862.png)

```dart
"metadata": [
  {
    "name": "client_id",
    "value": "xxxxxx" // AGC平台上的clientid
  },
],
```

然后我们需要获取Push Kit提供的Token，用于后续推送处理。然后推送，当然有唯一标识来进行推送。我们自己的APP有用户id作为唯一标识，设备也有自己id。这时我们就需要将设备id和用户id进行绑定，用于华为的PushKit 顺利推送给用户。

```dart
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AAID, pushCommon, pushService } from '@kit.PushKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');

    try {
      // 获取应用匿名标识符（AAID，Anonymous Application Identifier）的能力。AAID用于标识应用身份。
      AAID.getAAID((err: BusinessError, data: string) => {
        if (err) {
          hilog.error(0x0000, 'testTag', 'Failed to get AAID: %{public}d %{public}s', err.code, err.message);
        } else {
          hilog.info(0x0000, 'testTag', 'Succeeded in getting AAID');
        }
      });
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      hilog.error(0x0000, 'testTag', 'Failed to get AAID: %{public}d %{public}s', e.code, e.message);
    }

    try {
      // 获取推送服务的Token
      pushService.getToken((err: BusinessError, data: string) => {
        if (err) {
          hilog.error(0x0000, 'testTag', 'Failed to get push token: %{public}d %{public}s', err.code, err.message);
        } else {
          // 成功获取到Token 说明AGC平台设置相关操作都OK
          hilog.info(0x0000, 'testTag', 'Succeeded in getting push token');
        }
      });
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      hilog.error(0x0000, 'testTag', 'Failed to get push token: %{public}d %{public}s', e.code, e.message);
    }

    // 定义需要绑定的profileId
    // 帐号匿名标识，不可为空字符串。不建议使用真实的帐号id，推荐使用帐号id自行生成对应的匿名标识，能与该账号id建立唯一映射关系即可，生成算法无限制。
    const profileId: string = '1****9';
    try {
      // pushCommon.AppProfileType 应用内帐号类型，分为华为帐号和应用帐号。我这里选择后者，根据业务需求选择的。
      pushService.bindAppProfileId(pushCommon.AppProfileType.PROFILE_TYPE_APPLICATION_ACCOUNT, profileId, (err: BusinessError) => {
        if (err) {
          hilog.error(0x0000, 'testTag', 'Failed to bind app profile id: %{public}d %{public}s', err.code, err.message);
        } else {
          hilog.info(0x0000, 'testTag', 'Succeeded in binding app profile id.');
        }
      });
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      hilog.error(0x0000, 'testTag', 'Failed to bind app profile id: %{public}d %{public}s', e.code, e.message);
    }
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}

```

***Push Kit API下沉HarmonyOS，应用可免SDK集成。通过提供系统级长链接，即使应用进程不在也能实时推送消息。***
***Push Kit API下沉HarmonyOS，应用可免SDK集成。通过提供系统级长链接，即使应用进程不在也能实时推送消息。***
***Push Kit API下沉HarmonyOS，应用可免SDK集成。通过提供系统级长链接，即使应用进程不在也能实时推送消息。***
