## 【HarmonyOS 5】鸿蒙中的UIAbility详解（一）

##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

## 一、UIAbility是什么？

Stage模型中的组件类型名，即UIAbility组件，包含UI，提供展示UI的能力，主要用于和用户交互。

UIAbility类似于传统移动开发Android中的Activity或者Fragment。类似IOS开发中的 UIViewController。

UIAbility 是 HarmonyOS 应用框架的核心组件，负责管理应用的用户界面生命周期和上下文信息。


### **二、设置指定启动页面**
**启动页面必须设置**：否则应用启动后会白屏。

避免应用启动后白屏，需在`onWindowStageCreate`生命周期中设置默认加载页面。通过`WindowStage`的`loadContent()`方法指定页面路径。
  ```typescript
  export default class EntryAbility extends UIAbility {
    onWindowStageCreate(windowStage: window.WindowStage): void {
      windowStage.loadContent('pages/Index', (err, data) => { /* 处理回调 */ });
    }
  }
  ```
DevEco Studio默认生成的项目会自动加载`Index`页面，可按需修改路径。

### **三、获取上下文信息（UIAbilityContext）**
获取应用配置信息（如包名、Ability名称等），或调用操作Ability的方法（如启动、终止Ability）。通过`this.context`直接访问。
  ```typescript
  export default class EntryAbility extends UIAbility {
    onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
      const context = this.context; // 直接获取上下文
    }
  }
  ```
 **在页面组件中获取**：
 通过`getUIContext().getHostContext()`转换为`UIAbilityContext`。
  ```typescript
  @Entry
  @Component
  struct Page {
    private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    startAbilityTest() { this.context.startAbility(want); } // 启动其他Ability
  }
  ```

#### **启动页面设置与上下文使用代码示例**
```typescript
// UIAbility定义
export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage) {
    windowStage.loadContent('pages/Main', () => {}); // 设置启动页面
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    const context = this.context; // 获取上下文
    context.startAbility({ abilityName: 'OtherAbility' }); // 启动其他Ability
  }
}

// 页面组件中使用上下文
@Entry
@Component
struct MainPage {
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  build() {
    Button('终止当前Ability').onClick(() => this.context.terminateSelf());
  }
}
```

### **四、UIAbility生命周期与操作**

UIAbility的生命周期包含 **Create（创建）、Foreground（前台）、Background（后台）、Destroy（销毁）** 四个核心状态，以及与窗口（WindowStage）相关的子状态。通过生命周期回调钩子函数，可监听状态变化并执行对应操作。

### **生命周期状态流转图**
```
创建实例          窗口创建       进入前台         切到后台         窗口销毁       实例销毁
  ↓               ↓             ↓               ↓               ↓             ↓
onCreate() → onWindowStageCreate() → onForeground() → onBackground() → onWindowStageDestroy() → onDestroy()
         ↑       ↖                ↗                ↖                ↑
         └─────── WindowStageWillDestroy() ────────────────────────┘
```



#### **1、onCreate**
UIAbility实例创建完成时触发。初始化页面数据、加载资源（如定义变量、获取上下文`this.context`）。

  ```typescript
  export default class EntryAbility extends UIAbility {
    onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
      // 初始化操作（如获取上下文、配置数据）
      const context = this.context; 
    }
  }
  ```

#### **2、WindowStageCreate**
UIAbility实例创建后，进入前台前，系统创建WindowStage时触发。设置启动页面（`loadContent()`）、订阅窗口事件（如前后台切换、焦点变化）。

```dart

    onWindowStageCreate(windowStage: window.WindowStage) {
      windowStage.loadContent('pages/Index'); // 设置启动页面
      windowStage.on('windowStageEvent', (event) => { // 订阅窗口事件
        switch (event) {
          case window.WindowStageEventType.SHOWN: // 切到前台
            console.log('窗口切到前台');
            break;
        }
      });
    }
 
```
#### **3、WindowStageWillDestroy**

WindowStage销毁前触发（此时窗口仍可用）。释放通过WindowStage获取的资源，注销事件订阅（`off('windowStageEvent')`）。

#### **4、WindowStageDestroy**
WindowStage销毁时触发（UI资源释放）。释放UI相关资源（如临时文件、图形对象）。

#### **5、Foreground**
UIAbility切换至前台、UI可见前触发。申请系统资源（如定位、传感器权限）、恢复后台释放的资源。

```dart
    onForeground() {
      // 开启定位功能
      location.start(); 
    }
```

#### **6、Background**
UIAbility切换至后台、UI完全不可见后触发。释放无用资源、执行耗时操作（如数据持久化）。

```dart
    onBackground() {
      // 停止定位、保存当前状态
      location.stop(); 
      saveDataToLocal();
   }
```

#### **7、onDestroy**
UIAbility实例被终止时触发（如调用`terminateSelf()`）。释放全局资源、清理内存（如关闭网络连接、注销监听器）。
  ```typescript
  onDestroy() {
    // 释放数据库连接、取消定时器
    db.close(); 
    clearInterval(timer);
  }
  ```
**注意**：API 13+中，若用户通过最近任务一键清理应用，**不会触发`onDestroy()`**，而是直接终止进程。




### **四、UIAbility的常用函数操作**
#### **1. 终止UIAbility实例**
调用`terminateSelf()`终止当前Ability。
  ```typescript
  context.terminateSelf((err) => {
    if (err) { console.error('终止失败:', err); } 
    else { console.info('终止成功'); }
  });
  ```

#### **2. 获取拉起方信息**
当UIAbilityA通过`startAbility`启动UIAbilityB时，UIAbilityB可获取调用方信息。

  ```typescript
  export default class UIAbilityB extends UIAbility {
    onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
      console.log(`调用方Pid: ${want.parameters?.['ohos.aafwk.param.callerPid']}`);
    }
  }
  ```

#### **跨Ability信息传递代码示例**
```typescript
// UIAbilityA中启动UIAbilityB
@Entry
@Component
struct UIAbilityAPage {
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  build() {
    Button('拉起UIAbilityB').onClick(() => {
      this.context.startAbility({ 
        bundleName: this.context.abilityInfo.bundleName, 
        abilityName: 'UIAbilityB' 
      });
    });
  }
}

// UIAbilityB中获取调用方信息
export default class UIAbilityB extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    console.log(`调用方包名: ${want.parameters?.['ohos.aafwk.param.callerBundleName']}`);
  }
}
```





### **注意**
当UIAbility设置为`singleton`启动模式时，重复调用`startAbility()`启动同一实例，**不会重新走`onCreate`和`onWindowStageCreate`流程**，而是触发`onNewWant`回调。

  ```typescript
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam) {
    // 根据新的Want参数更新页面数据
    this.data = want.parameters?.data; 
  }
  ```


