## 【HarmonyOS 5】使用openCustomDialog如何禁止手势关闭的方案

##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

### 一、前言
在HarmonyOS中使用`openCustomDialog`自定义弹框时，我们会遇到实现禁止手势关闭弹框的业务场景。
虽然在 HarmonyOS Next 中，自定义 Dialog 默认可能继承系统的侧滑返回手势，并且目前无法屏蔽，官方反馈未来版本可能会开放禁用选项。

在当前版本中，目前无法完全禁止手势关闭，但可以通过一些方法进行控制。例如，监听 onWillDismiss 事件可以在关闭时进行拦截，但需要处理不同的关闭原因。

华为官方文档明确提到了使用openCustomDialog时可以通过配置onWillDismiss回调来拦截关闭事件。在onWillDismiss中，可以检查DismissReason来判断关闭原因，例如用户滑动或点击外部。如果是手势关闭（如侧滑），可以通过返回false来阻止对话框关闭。可以通过监听onWillDismiss事件来禁止手势关闭。

`openCustomDialog`提供了`onWillDismiss`回调函数，当用户尝试通过**滑动、点击外部、返回键**等操作关闭弹窗时，会触发该回调。通过在回调中判断关闭原因并拦截操作，即可实现禁止手势关闭的效果。

### 二、方案思路
#### 1. 定义自定义弹窗组件
```typescript
import { PromptAction, DismissReason } from '@ohos.prompt';

@Builder
function CustomDialogContent() {
  return Column() {
    Text('禁止手势关闭的弹窗')
      .fontSize(24)
      .fontWeight(FontWeight.Bold)
    Button('确认关闭')
      .onClick(() => {
        // 主动关闭弹窗
        promptAction.closeCustomDialog(dialogId);
      })
  }
  .padding(30)
  .backgroundColor(Color.White)
  .borderRadius(16)
  .width('80%')
}
```

#### 2. 打开弹窗并设置拦截逻辑
```typescript
let promptAction = UIContext.getPromptAction();
let dialogId: number = 0;

promptAction.openCustomDialog({
  builder: () => CustomDialogContent(),
  alignment: DialogAlignment.Center,
  maskColor: 'rgba(0, 0, 0, 0.3)',
  autoCancel: false, // 禁止点击外部关闭
  onWillDismiss: (dismissAction) => {
    // 处理不同关闭原因
    switch (dismissAction.reason) {
      case DismissReason.SWIPE: // 侧滑关闭
      case DismissReason.BACK:   // 返回键关闭
        return false; // 阻止关闭
      default:
        return true; // 允许其他方式关闭
    }
  }
}).then(id => dialogId = id);
```
#### 3. 关闭类型参数说明

| 参数               | 说明                                                                 |
|--------------------|---------------------------------------------------------------------|
| `autoCancel`       | 控制是否允许点击外部关闭弹窗，设置为`false`可禁用该功能。 |
| `onWillDismiss`    | 关闭事件回调函数，返回`false`可阻止关闭，返回`true`则允许关闭。 |
| `DismissReason`    | 关闭原因枚举，包含`SWIPE`（侧滑）、`BACK`（返回键）等类型。 |


### 三、源码DEMO示例
```typescript
import { PromptAction, DismissReason } from '@ohos.prompt';

@Entry
@Component
struct App {
  private promptAction: PromptAction = UIContext.getPromptAction();
  private dialogId: number = 0;

  build() {
    Column() {
      Button('打开禁止手势关闭的弹窗')
        .onClick(() => this.showDialog())
    }
  }

  showDialog() {
    this.promptAction.openCustomDialog({
      builder: () => this.CustomDialogContent(),
      alignment: DialogAlignment.Center,
      maskColor: 'rgba(0, 0, 0, 0.3)',
      autoCancel: false,
      onWillDismiss: (dismissAction) => {
        console.log(`关闭原因：${dismissAction.reason}`);
        return dismissAction.reason === DismissReason.BUTTON; // 仅允许按钮关闭
      }
    }).then(id => this.dialogId = id);
  }

  @Builder
  CustomDialogContent() {
    return Column() {
      Text('禁止手势关闭')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
      Button('确认关闭')
        .onClick(() => this.promptAction.closeCustomDialog(this.dialogId))
    }
    .padding(30)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .width('80%')
  }
}
```
**注意**
综上所述，可在HarmonyOS中实现`openCustomDialog`的手势关闭拦截。对于需要完全禁止系统级手势的场景，建议结合页面级导航拦截逻辑进行处理。
 **系统限制**：
   - 在HarmonyOS Next系统中，部分系统级手势（如从屏幕边缘向内滑动返回）可能无法完全拦截。
   - 建议通过`onWillDismiss`回调配合页面级`onBackPress`拦截实现更全面的控制。