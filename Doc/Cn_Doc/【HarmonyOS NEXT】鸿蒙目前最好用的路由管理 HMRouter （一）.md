## 【HarmonyOS NEXT】鸿蒙目前最好用的路由管理 HMRouter （一）

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

## 一、前言

经过**router**到**navigation**，直到**HMRouter**的横空出世。鸿蒙应用内最强的路由管理终于出现了。被疯狂吐槽的router因为各种路由需求无法满足，使用僵化，已经被官方放弃，不推荐使用。更新出navigation被TOP200应用疯狂适配后，爆出一堆bug和新需求。现在HMRouter的出现，终于可以让大家在路由管理上，丝滑操作了。

比如在Android和IOS上最常见的回退需求。router和navigation都无法做到。A-B-C-D三级页面。D页面返回到A，可以直接使用pop指定跳转的url进行实现。

本章讲解HMRouter是什么，能力是什么，如何快速集成。后续章节对其扩展特性功能进行详细讲解。

## 二、HMRouter

1.知其然才能知其所以然。我们要先搞清楚HMRouter是什么。
**HMRouter作为路由管理，框架底层对Navigation相关能力进行了封装**，让我们无需关心繁琐的navigation逻辑。

2.HMRouter都能做什么？
能力如何？具备**页面跳转、弹窗提示、转场动效、数据加载、维测场景**。总的来说，它是HarmonyOS上页面跳转的场景解决方案，主要解决应用内原生页面间相互跳转的问题。

3.HMRouter是什么形态？
作为插件集成到项目中进行使用，目前代码开源在Gitee上，也可以直接拿源码模块使用，或者自己魔改（不过要注意在商业项目中使用，开源协议的问题）。

## 三、快速使用

**（1）集成HMRouter插件**
**1.首先需要下载依赖**

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/5649e03bf0604c9ebe09d4d03604907db1862.png)

```dart
"dependencies": {
   "@hadss/hmrouter": "^1.0.0-rc.5"
 }
```

**2.编译插件配置**

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/419b47a5d951437b85a71cd9694d34aab1862.png)

```dart
"dependencies": {
  "@hadss/hmrouter-plugin": "^1.0.0-rc.4" // 使用npm仓版本号
},
```

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/dd8e2519fece49bcac1fd9821d3fbfcdb1862.png)

```bash
import { hapTasks } from '@ohos/hvigor-ohos-plugin';
import { hapPlugin } from "@hadss/hmrouter-plugin";

export default {
    system: hapTasks, /* Built-in plugin of Hvigor. It cannot be modified. */
    plugins: [hapPlugin()]         /* Custom plugin to extend the functionality of Hvigor. */
}

```

**（2）初始化工具**
在EntryAbility，你的启动模块中配置初始化工具。

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/030ae4adc4be46a3afe7cfb1a1abdc9fb1862.png)

```bash
onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
  hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  HMRouterMgr.init({
    context: this.context
  });
}
```

**（3）初始化首页**
与Navigation相同，页面build中需要包裹容器进行页面的显示。
与Navigation不同的是，该容器需要在,Column或者Stack之内套着使用。

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/4d13652589764ea1af0751f335b000dfb1862.png)

代码文本参见下方的DEMO代码示例。

**（4）配置跳转页**
跳转到的目标页面，通过HMRouter路由注解标签的形式，进行页面信息的配置。设置瞄点，使上级页面可跳转过来。

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/3b9cc06ae02949d1b046bdf7b59617f6b1862.png)

代码文本参见下方的DEMO代码示例。

**（5）完成（实现基础的页面跳转和返回）**

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/ce1bccf443364f30887a6dba96f4c992b1862.png)

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/fe454690818d4b7a9b3935cf80e635d5b1862.png)

**DEMO代码示例：**
Index.ets 首页

```dart
import { AttributeUpdater } from '@kit.ArkUI';
import { HMDefaultGlobalAnimator, HMNavigation, HMRouterMgr } from '@hadss/hmrouter';

/**
 * 界面样式公用函数
 */
class NavModifier extends AttributeUpdater<NavigationAttribute> {
  initializeModifier(instance: NavigationAttribute): void {
    instance.mode(NavigationMode.Stack);
    instance.navBarWidth('100%');
    instance.hideTitleBar(true);
    instance.hideToolBar(true);
  }
}

@Entry
@Component
struct Index {
  modifier: NavModifier = new NavModifier();

  aboutToAppear(): void {

  }

  build() {
    // @Entry中需要再套一层容器组件,Column或者Stack
    Column(){
      // 使用HMNavigation容器
      HMNavigation({
        navigationId: 'mainNavigation', options: {
          // 设置动画样式
          standardAnimator: HMDefaultGlobalAnimator.STANDARD_ANIMATOR,
          // 设置弹框动画样式
          dialogAnimator: HMDefaultGlobalAnimator.DIALOG_ANIMATOR,
          // 设置页面navigation的参数，标题栏，工具栏，bar那些
          modifier: this.modifier
        }
      }) {
        Row() {
          Text("点击跳转")
            .fontSize(50)
            .onClick(()=>{
              HMRouterMgr.push({pageUrl: 'pageB'})
            })
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Color.Yellow)
        .justifyContent(FlexAlign.Center)
      }
    }
    .height('100%')
    .width('100%')
  }
}
```

PageB.ets 跳转页

```dart
import { HMRouter, HMRouterMgr } from "@hadss/hmrouter"

// HMRouter 路由标签使用在自定义组件struct上，且该自定义组件需要添加export关键字
@HMRouter({ pageUrl: 'pageB' })
@Component
export struct PageB {

  build() {
    Row(){
      Text("点击返回")
        .fontSize(50)
        .onClick(()=>{
          HMRouterMgr.pop();
        })
    }.width("100%").height("100%").backgroundColor(Color.Red).justifyContent(FlexAlign.Center)
  }
}
```

