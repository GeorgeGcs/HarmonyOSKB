# 【HarmonyOS 5】Solution to Disable Gesture Closing for openCustomDialog  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services##HarmonyOS Financial Applications (Financial Management#  


### 一、Preface  

When using `openCustomDialog` for custom pop-ups in HarmonyOS, we encounter business scenarios where we need to disable gesture closing of the pop-up.  

Although in HarmonyOS Next, custom Dialogs may inherit the system's swipe-back gesture by default and cannot be blocked currently, official feedback indicates that an option to disable it may be available in future versions.  

In the current version, complete disabling of gesture closing is not yet possible, but control can be achieved through certain methods. For example, listening to the `onWillDismiss` event allows interception during closing, though different closing reasons need to be handled.  

Huawei's official documentation explicitly mentions that using `openCustomDialog` can intercept the closing event through the `onWillDismiss` callback configuration. In `onWillDismiss`, you can check `DismissReason` to determine the closing cause, such as user swiping or clicking outside. If it is a gesture closing (e.g., swipe), you can prevent the dialog from closing by returning `false`. Disabling gesture closing can be achieved by listening to the `onWillDismiss` event.  

`openCustomDialog` provides an `onWillDismiss` callback function, which is triggered when the user attempts to close the pop-up through operations such as **swiping, clicking outside, or pressing the back button**. By judging the closing reason and intercepting the operation in the callback, the effect of disabling gesture closing can be achieved.  


### 二、Solution Approach  

#### 1. Define a Custom Pop-Up Component  
```typescript
import { PromptAction, DismissReason } from '@ohos.prompt';

@Builder
function CustomDialogContent() {
  return Column() {
    Text('Pop-up with gesture closing disabled')
      .fontSize(24)
      .fontWeight(FontWeight.Bold)
    Button('Confirm to close')
      .onClick(() => {
        // Close the pop-up actively
        promptAction.closeCustomDialog(dialogId);
      })
  }
  .padding(30)
  .backgroundColor(Color.White)
  .borderRadius(16)
  .width('80%')
}
```  

#### 2. Open the Pop-Up and Set Interception Logic  
```typescript
let promptAction = UIContext.getPromptAction();
let dialogId: number = 0;

promptAction.openCustomDialog({
  builder: () => CustomDialogContent(),
  alignment: DialogAlignment.Center,
  maskColor: 'rgba(0, 0, 0, 0.3)',
  autoCancel: false, // Disable closing by clicking outside
  onWillDismiss: (dismissAction) => {
    // Handle different closing reasons
    switch (dismissAction.reason) {
      case DismissReason.SWIPE: // Close by swipe
      case DismissReason.BACK:   // Close by back button
        return false; // Prevent closing
      default:
        return true; // Allow closing by other methods
    }
  }
}).then(id => dialogId = id);
```  

#### 3. Explanation of Closing Type Parameters  

| Parameter          | Description                                                                 |
|--------------------|-----------------------------------------------------------------------------|
| `autoCancel`       | Controls whether closing by clicking outside is allowed; set to `false` to disable this function. |
| `onWillDismiss`    | Closing event callback function; returning `false` prevents closing, while returning `true` allows closing. |
| `DismissReason`    | Enumeration of closing reasons, including `SWIPE` (swipe) and `BACK` (back button). |


### 三、Source Code DEMO Example  
```typescript
import { PromptAction, DismissReason } from '@ohos.prompt';

@Entry
@Component
struct App {
  private promptAction: PromptAction = UIContext.getPromptAction();
  private dialogId: number = 0;

  build() {
    Column() {
      Button('Open pop-up with gesture closing disabled')
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
        console.log(`Closing reason: ${dismissAction.reason}`);
        return dismissAction.reason === DismissReason.BUTTON; // Only allow closing by button
      }
    }).then(id => this.dialogId = id);
  }

  @Builder
  CustomDialogContent() {
    return Column() {
      Text('Gesture closing disabled')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
      Button('Confirm to close')
        .onClick(() => this.promptAction.closeCustomDialog(this.dialogId))
    }
    .padding(30)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .width('80%')
  }
}
```  

### Notes  
In summary, gesture closing interception for `openCustomDialog` can be implemented in HarmonyOS. For scenarios requiring complete disabling of system-level gestures, it is recommended to handle them in conjunction with page-level navigation interception logic.  

#### System Limitations:  
- In HarmonyOS Next, some system-level gestures (such as swiping back from the screen edge) may not be fully interceptable.  
- It is recommended to achieve more comprehensive control by combining the `onWillDismiss` callback with page-level `onBackPress` interception.