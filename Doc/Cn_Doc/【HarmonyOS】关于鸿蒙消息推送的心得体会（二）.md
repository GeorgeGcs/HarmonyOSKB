## 【HarmonyOS】关于鸿蒙消息推送的心得体会（二）

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/3435410839d247078c5dd4cc11b0c196b1862.png)

## 前言

推送功能的开发与传统功能开发还是有很大区别。首先最大的区别点就在于需要多部门之间的协同，作为鸿蒙客户端开发，**你需要和产品，运营，以及后台开发一起协作，这个事儿才能做好。**

上一篇，[【HarmonyOS】关于鸿蒙消息推送的心得体会 （一）](https://blog.csdn.net/superherowupan/article/details/140476623?spm=1001.2014.3001.5501)之中，AGC平台开通推送服务，配置推送设置项 ，这个任务在公司里主要是运营来负责。毕竟公司的华为AGC平台帐号，也不是开发人员可以随意使用。

但是目前推送集成的文档，不管是华为官方还是第三方推送SDK服务提供商，文档中的**操作内容都是糅合在一起**，华为官方最多只是对后台的REST API进行了小拆分。有些是开发需要操作，有些则是产品，运营需要去做，甚至推送发起后台要去处理的内容也在文档里。

综上所述，鸿蒙客户端开发人员就需要辛苦一些，把整个文档浏览过之后，再根据步骤实操，使用demo验证推送功能，再将正式集成推送时的工作内容进行划分，与其他部门一起完成配置项和处理项。

由此可见，**应用开发人员其实需要一套授权可操作的测试应用帐号**，来进行这种多部门沟通前的验证集成工作。否则你只能等待前置条件的完成，很浪费时间。

其实我是建议此种类型的**文档根据角色来进行内容划分**，这样操作起来大家也能各司其职。

## 推送功能的分工

作为已经踩过坑的鸿蒙应用开发人员，我将鸿蒙推送的角色分工梳理了下。

当然这仅供参考，主要根据你们公司的部门职责的实际情况来决定。如果你们公司产品不管事儿，和项目经理似的，活儿都是运营干，你也没有必要拿着我这篇文档Diss人家，实在是大动肝火啊好兄弟。

在我这里当然是有产品，运营，后台开发➕应用开发，UI设计主要是推送通知的一些图标和交互，关联不大就不展开说了。如果你那没有对应的角色。**那你就需要授权去操作了。切记不要自己吭吭哧哧一顿操作。**

不出事儿还好，出事了人家就会问你，为什么擅自操作？你懂得。

废话不多说咯，下面就是工作内容角色拆解，仅供参考：

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/b774270143bc4345b7a26a08064c0bc6b1862.png)

**1.运营人员**需要在华为AGC平台进行推送服务的开通，以及推送类型的处理。你要知道图上这些信息，Push Kit将通知消息分类为**服务与通讯、资讯营销两大类别**。
说人话环节，这个事儿其实就是华为官方根据推送的内容场景，进行了梳理分类，来**严格控制消息的展示位置，推送数量和提醒方式**。说白了就是一堆对应关系表，运营耐心阅读这些内容，**根据自己应用的推送场景进行对号入座**处理即可。
详细内容请移步Push Kit下的（**申请推送场景化消息权益**
）文档进行阅读。

**2.产品人员**需要参与的工作，主要是确认运营的场景分类，还有开发的通知交互，以及UI设计的事宜。

**3.鸿蒙应用开发人员**需要，通知开关需由用户授权允许，应用首次启动时需弹窗询问用户是否允许通知。因为应用的通知开关默认为关闭状态。你不去做申请授权，推送了你也不会展示。若返回的错误码为1600004，即为拒绝授权。

***有个点需要注意，如果用户曾经居然过授权，你就算再次调用该API也不会再显示授权模态弹框。所以根据这种错误类型需要自己新增提示，告知用户拒绝过授权，需要手动去设置界面，开启应用的通知开关。***

```dart
import { notificationManager } from '@kit.NotificationKit';
import { common } from '@kit.AbilityKit'; 
 
  /**
   * 请求打开通知
   */
  public requestEnableNotificationByUser(context: common.UIAbilityContext){
    let requestEnableNotificationCallback = (err: BusinessError): void => {
      if (err) {
        console.error(`requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
      } else {
        console.info("requestEnableNotification success");
      }
    };
    notificationManager.requestEnableNotification(context, requestEnableNotificationCallback);
  }
```

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/0c948d34e3344b6dabe9bce14fa6c1e8b1862.png)

然后就是上篇文档一中提到，获取Push Token的操作。拿到之后你需要将Token发送给后台服务器，他那边做推送需要用。

最后就是处理通知点击的动作，如果业务需要你处理点击通知，跳转到你应用首页里做处理，你需要在：

```dart
import { UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export default class MainAbility extends UIAbility {
  onCreate(want: Want): void {
    // 获取消息中传递的data数据
    const data = want.parameters;
    hilog.info(0x0000, 'testTag', 'Succeeded in getting message data');
    // 根据实际业务场景对data进行处理
  }
}
```

如果你的ability是单例（singleton）模式，需要在onNewWant()方法再处理一次。
***当点击消息首次进入应用首页时，会在onCreate()方法中获取消息data数据，当前应用进程存在时，点击新消息进入首页会在onNewWant()方法中获取消息数据。***
**当你的ability设置了url或者action就可以跳到应用内某个页面的处理了。**

**4.后台开发人员**需要阅读REST API文档，对推送消息的结构体，消息回执，撤回，推送，实况窗，VoIP等接口的开发。
应用服务端调用REST API推送通知消息，通知消息示例如下：

```dart
// Request URL
POST https://push-api.cloud.huawei.com/v3/[projectId]/messages:send

// Request Header
Content-Type: application/json
// JWT格式字符串，可参见Authorization获取。
Authorization: Bearer eyJr*****OiIx---****.eyJh*****iJodHR--***.QRod*****4Gp---****
push-type: 0 // 0表示通知消息场景。

// Request Body
{
  "payload": {
    "notification": {
      "category": "MARKETING",// 资讯营销类型，一天2条
      "title": "普通通知标题",
      "body": "普通通知内容",
      "profileId": "111***222", // 应用帐号和token进行绑定得到的唯一标识id
      "clickAction": {
        "actionType": 0 // 0表示点击消息打开应用首页。
      }
    }
  },
  "target": {
    "token": ["IQAAAA**********4Tw"] // 客户端发给服务器后台的用户推送token
  }
}
```

以上整个流程都完成，你的应用就可以实现推送功能了。当然这只是最基本的玩法，还有实况窗，VoIP等玩法就不展开说了，感兴趣的可以去看官方API详细研究下。

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/a2351b0f28174c80a2513a13b12fef3eb1862.png)

