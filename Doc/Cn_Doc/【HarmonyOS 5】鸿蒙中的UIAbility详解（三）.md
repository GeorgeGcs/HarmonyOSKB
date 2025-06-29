【HarmonyOS 5】鸿蒙中的UIAbility详解（三）

##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

## 一、前言
本文是鸿蒙中的UIAbility详解系列的最终章。主要针对UIAbility的冷启动和热启动，对于want数据的处理。UIAbility的备份恢复，UIAbility的接续等高级功能的概念和使用讲解。


## 二、UIAbility启动模式：冷启动与热启动的Want数据处理

### 1. 冷启动（Cold Start）
应用首次启动或被系统完全终止后重新创建。  

冷启动，应用会从onCreate函数中进入，通过want参数，我们可以处理其中携带的信息。像applink就是uri，deeplink就是parameters?.deepLink，还有推送等。

核心逻辑很简单，根据want中对应需要处理的字段信息，进行逻辑处理（跳转目标页面，数据和业务处理等）。
  ```typescript
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    const deepLinkData = want.parameters?.deepLink; // 解析深层链接参数
    this.initData(deepLinkData);
  }
  ```
### 2. 热启动（Warm Start）
应用在后台运行时被重新激活（如切换任务或接收新事件）。  

一般和冷启动处理是一对儿，处理逻辑也和冷启动一致。只不过此时应用从onNewWant函数跳进来。时机也是App已经创建了，此时又被激活。

  ```typescript
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam) {
    if (launchParam.launchReason === AbilityConstant.LaunchReason.NEW_WANT) {
      const updateData = want.parameters?.updateData; // 解析热启动参数
      this.refreshUI(updateData);
    }
  }
  ```


### 总结：冷热启动区别对比
| 特性               | 冷启动                          | 热启动                          |
|--------------------|---------------------------------|---------------------------------|
| 触发条件           | 首次启动/进程终止后重启         | 从后台唤醒/接收新Want           |
| 生命周期入口       | `onCreate`                      | `onNewWant`（单实例）           |
| 页面栈处理         | 重建页面栈                      | 恢复现有页面栈                  |
| Want参数来源       | 启动时指定（如图标点击、链接）  | 运行中动态传入（如跨Ability调用）|


### 3. 源码示例
```dart
// EntryAbility.ets
export default class EntryAbility extends UIAbility {
  private selectPage: string = '';

  // 冷启动时触发
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    this.parseParams(want); // 解析参数
  }

  // 热启动时触发
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam) {
    this.parseParams(want); // 解析参数
    if (this.currentWindowStage) {
      this.onWindowStageCreate(this.currentWindowStage); // 重新加载页面
    }
  }

  // 解析参数逻辑
  private parseParams(want: Want) {
    if (want.parameters?.params) {
      const params = JSON.parse(want.parameters.params as string);
      this.selectPage = params.targetPage; // 获取目标页面标识（funA/funB）
    }
  }

  // 加载页面
  onWindowStageCreate(windowStage: window.WindowStage) {
    let targetPage = 'pages/Index'; // 默认页面
    switch (this.selectPage) {
      case 'funA': targetPage = 'pages/FunA'; break;
      case 'funB': targetPage = 'pages/FunB'; break;
    }
    windowStage.loadContent(targetPage); // 加载对应页面
  }
}
```


---


## 二、UIAbility备份恢复：保障异常终止后的状态延续


应用因系统资源不足被后台终止时，自动保存状态。  
下次启动时还原数据（如编辑中的内容、页面位置）。  


#### 1. 启用备份功能
在`onCreate`中调用`setRestoreEnabled(true)`：  
```typescript
export default class EntryAbility extends UIAbility {
  onCreate() {
    this.context.setRestoreEnabled(true); // 初始化时启用备份
  }
}
```

#### 2. 保存自定义数据
重写`onSaveState`方法，通过`WantParams`存储数据：  
```typescript
onSaveState(state: AbilityConstant.StateType, wantParams: Record<string, Object>) {
  wantParams["editorContent"] = this.editor.getText(); // 保存编辑内容
  wantParams["currentPage"] = this.router.getCurrentPage(); // 保存页面路由
  return AbilityConstant.OnSaveResult.ALL_AGREE;
}
```

#### 3. 恢复数据
在`onCreate`或`onNewWant`中解析参数：  
```typescript
onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
  if (want.parameters?.editorContent) {
    this.editor.setText(want.parameters.editorContent as string); // 恢复文本
    this.router.navigateTo(want.parameters.currentPage as string); // 恢复页面路由
  }
}
```

### 注意
**1. 数据限制**：单次备份最大200KB，存储时效7天，重启设备不保留。  
**2. 适用场景**：临时数据（如未保存的表单）、页面状态（如滚动位置），**不建议存储敏感数据**。  
**3. 性能优化**：避免在`onSaveState`中执行耗时操作，优先存储关键状态。


## 三、应用接续（Continuation）：跨设备任务无缝迁移

将当前页面状态、路由信息迁移至另一设备（如手机→平板）。  
支持按场景开启/关闭迁移（如仅在编辑页允许迁移）。  
小数据通过`wantParam`传输（≤100KB），大数据使用分布式数据对象（DDO）。  

#### 1. 配置可迁移能力
在`module.json5`中设置`continuable: true`：  
```json
{
  "abilities": [
    {
      "name": "EditorAbility",
      "continuable": true // 启用跨设备迁移
    }
  ]
}
```

#### 2. 源端（发起迁移设备）实现
`onContinue`回调：保存数据、校验兼容性、决定是否迁移。  
  ```typescript
  onContinue(wantParam: Record<string, Object>): OnContinueResult {
    // 校验目标设备版本
    if (wantParam.version < MIN_SUPPORT_VERSION) return MISMATCH;
    
    // 保存编辑内容
    wantParam["editorData"] = this.editor.getData();
    
    // 动态控制迁移状态（如仅在编辑页允许迁移）
    if (this.currentPage !== 'EditorPage') return REJECT;
    
    return AGREE;
  }
  ```

#### 4. 目标端（接收设备）恢复
冷启动时通过`onCreate`恢复，热启动时通过`onNewWant`恢复：  
  ```typescript
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    if (launchParam.launchReason === CONTINUATION) {
      const editorData = want.parameters?.editorData;
      this.editor.setData(editorData); // 恢复数据
      this.context.restoreWindowStage(); // 自动恢复页面栈
    }
  }
  ```

### 注意
**1. 针对动态开关迁移**：通过`setMissionContinueState`控制（如在非编辑页禁用）：  
  ```typescript
  // 在非编辑页关闭迁移
  this.context.setMissionContinueState(AbilityConstant.ContinueState.INACTIVE);
  ```
**2. 针对自定义页面栈**：关闭自动恢复，手动指定目标页面：  
  ```typescript
  onContinue(wantParam) {
    wantParam[wantConstant.Params.SUPPORT_CONTINUE_PAGE_STACK_KEY] = false; // 禁用自动恢复
    wantParam["targetPage"] = "SummaryPage"; // 自定义目标页面
  }
  ```
 **3. 针对大数据迁移**：使用分布式数据对象（DDO）同步文件或大文本：  
  ```typescript
  // 源端创建DDO并保存
  const ddo = distributedDataObject.create(this.context, largeData);
  wantParam["ddoSessionId"] = ddo.genSessionId(); // 传递会话ID至目标端
  ```


