## 【HarmonyOS】应用推送使用个推SDK如何实现？

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

## 前言

个推和极光都是市面上很成熟的推送第三方SDK了。今天讲讲个推SDK在鸿蒙中如何集成使用。

存在即合理，三方SDK推送给我们带来了极大的好处，首先在服务器后台处理一套API就可搞定，差异化处理都由SDK厂商来做了。客户端层面，SDK会更进一步进行封装，并且加强功能的能力。整个功能又节约了人力维护和开发成本。
当然也有缺点，毕竟差异化都是厂商处理了，所以在平台进行API更新时，都需要等厂商先升级完毕才能进行下一步，有了前置依赖。

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/667ede49cfe6447a9ed87e7a9debe14cb1862.png)

## 平台注册和配置事项

一般鸿蒙应用选择个推很大的前提是，既有的IOS和Android已经使用了个推，在迁移一致性上来说，也会选择个推来实现鸿蒙上的应用推送功能。

一般公司运营会负责个推平台账号。这里注册是为给给应用开发来做测试账号用。

[个推平台](https://dev.getui.com/dev/#/login?mode=register) 整个注册过程很简单，傻瓜操作即可。

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/0de0dd9d76284114a3ee1fe36209b62db1862.png)

注册完成后登陆个推平台，进行测试应用的注册。一般平台都需要以你的应用作为服务对象，**会生成对应该的APPID或者APPKey**，到时候使用他们的SDK，初始化时就需要将你的应用唯一标识传给他们，联网之后他们的后台会进行校验。这也是一个注意项，在使用三方SDK时，若没有和自己家的后台服务器直接交互，很多情况下是需要连接外部网络，因为客户端的**三方SDK会进行联网校验**。所以很多**公司是内网，测试机使用SDK功能就会有问题**。

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/f2cba116f6e54dc7956d45874b025c3fb1862.png)

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/572f0b7b64de47a7ab0955b99d724450b1862.png)

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/1b7f9793b32b42ff99b5bd7aec3f5fe4b1862.png)

**关于华为AGC平台推送服务的配置，参见这篇文章：**
[【HarmonyOS】关于鸿蒙消息推送的心得体会 （一）](https://blog.csdn.net/superherowupan/article/details/140476623?spm=1001.2014.3001.5502)

**关于个推平台和华为AGC平台进行绑定的操作：**
在个推开发者中心--应用管理页--找到对应的这个鸿蒙应用--进入“消息推送”页--配置管理--应用配置–鸿蒙：去填写鸿蒙应用的厂商信息，点击上传文件，选择您在创建服务器秘钥文件中下载的JSON文件上传：

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/baa9aab5fbfb4f4ca8d3ab1c0944664cb1862.png)

如果不知道JSON文件如何获取，详细步骤参见文档：[开通指南](https://docs.getui.com/getui/mobile/harmonyos/harmonyosstudio/) 查看其中的**创建服务帐号密钥文件**的内容。

## SDK获取Demo运行

应用注册完之后，就可以进行推送SDK的下载了。这里会有客户端SDK和服务器
SDK。

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/029942bc411a4ebf959f6dc6784386edb1862.png)

下载完成之后，我们可以看到SDK是以Demo的形式提供。SDK的Har肯定就在项目的libs里了。这里我们也发现了个彩蛋，MACOSX，这一看就是Mac电脑上传的包哈哈哈。

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/39040b958ade42dfb3e762ab84890788b1862.png)

打开应用后我们可以看到，整个demo很简单。sdk本体就是libs下的GT-HM-1.0.2.0-beta.har。

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/fd047e9da5df4232b4d8032fb333d66fb1862.png)

**在入口Ability的创建函数中，进行了SDK的初始化操作。**这里的APPID就是我们在个推平台上注册应用，对应的id。

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
      appId: 'APPID',
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

因为个推是在华为推送官网API基础之上做的封装，所以官网对于推送进行验证id我们也需要进行配置。这个id在华为AGC平台上可以找到。如何获取id和填写id到工程里，参见这篇文章：**
[【HarmonyOS】关于鸿蒙消息推送的心得体会 （一）](https://blog.csdn.net/superherowupan/article/details/140476623?spm=1001.2014.3001.5502)

**前两步完成之后，使用对应的华为AGC平台上你的测试应用签名文件进行编译，启动后手机上显示的完整的测试页，通过按钮触发不同的SDK API，注意测试之前要先开启通知开关。代码参见demo中的index.ets**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a9232f4eedbb4629a5dea3b4d51497d3.png)
***注意一定要连接外网进行测试！***
***注意一定要连接外网进行测试！***
***注意一定要连接外网进行测试！***

## 最后一步创建推送通知进行测试验证

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/ef961edd63d344e4b80e261e310860ecb1862.png)

CID是个推SDK在初始化时生成，有日志答应可以获取到。

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/3627f521755e4728ad96ecdf84cef3f5b1862.png)

其实推送功能就算使用华为官网原生API来实现，工作量也不是很大。但是服务器后台的工作量还是很巨大。以上是个推SDK在客户端集成的操作。关于服务器API的操作参见官网文档：[RestAPI V2](https://docs.getui.com/getui/server/rest_v2/introduction/)

以上都完成后，想必你已经对集成个推SDK实现推送功能，信心百倍咯，快去自己试试吧。
