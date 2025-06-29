## 【HarmonyOS 5】鸿蒙页面和组件生命周期函数

##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

## 一、生命周期阶段：
**创建阶段**
**build：**
构建组件的 UI 结构和样式。

**onDidBuild：**
build 方法执行完毕后调用，可用于数据初始化或额外的 UI 调整。

**挂载阶段**
**onPageShow：**
页面显示时调用。
**onReady：**
组件挂载到页面后调用。
**onWindowStageShow：**
窗口显示时调用。

**交互阶段**
**onBackPress：**
用户点击返回按钮时调用。

**销毁阶段**
**onPageHide：**
页面隐藏时调用。

**onDestroy：**
组件销毁时调用。

## 二、页面和组件的生命周期函数如何区分?
首先我们需要理解页面和自定义组件的概念。

在 ArkUI 中，页面组件指的是被@Entry装饰的组件，其拥有独特的生命周期接口，这些接口对页面在不同状态下的行为控制起着关键作用。

自定义组件则由@Component装饰。

如何分清楚哪些是页面独有的生命周期函数呢？关键点在于函数名字中的page，例如onPageShow,onPageHide这两个就是页面独有。并且还有个特殊的函数，即：返回按钮触发函数，onBackPress。只需要记住，只有页面才能响应返回按钮即可。



**三、DEMO示例**

```dart
@Entry
@Component
struct LifeCycleExample {
  build() {
    Column({ space: 50 }) {
      Text('生命周期示例')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
    }
    .width('100%')
  }

  onDidBuild() {
    console.log('build方法执行完毕');
  }

  onPageShow() {
    console.log('页面显示');
  }

  onReady() {
    console.log('组件挂载完成');
  }

  onWindowStageShow() {
    console.log('窗口显示');
  }

  onBackPress(): boolean {
    console.log('点击返回按钮');
    return false;
  }

  onPageHide() {
    console.log('页面隐藏');
  }

  onDestroy() {
    console.log('组件销毁');
  }
}
```
