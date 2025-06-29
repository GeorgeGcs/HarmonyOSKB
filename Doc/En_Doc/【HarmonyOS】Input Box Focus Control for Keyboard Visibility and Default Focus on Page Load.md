**【HarmonyOS 5】Input Box Focus Control for Keyboard Visibility and Default Focus on Page Load**

#HarmonyOS Development Capabilities
#HarmonyOS SDK Application Services
#HarmonyOS Financial Applications (Financial Management)

**Problem Background:**
In HarmonyOS, the TextInput control is the most common component for user input. It involves basic focus control operations such as gaining and losing focus, which are essential for users to input and exit the input state conveniently.

Since text input is always accompanied by keyboard interaction, **dynamically adjusting focus** is often required both in logical control and UI rendering.

Another common requirement is that the keyboard should automatically pop up when the page loads, with the input box **defaulting to obtain focus**.

**Solutions:**
**Problem 1:**

1. First, call this interface to actively transfer focus to the component specified by the parameter:

focusControl.requestFocus("id");

----------

***Note:
1. Components that support focus control: TextInput, TextArea, Search, Button, Text, Image, List, Grid. Focus events currently only work on physical devices.***

----------

2. Monitor focus gain and loss callbacks:
onFocus
onBlur

3. Ensure the component gains focus when clicked

**Problem 2:**
1. To automatically pop up the keyboard when entering the page, set defaultFocus(true) on the input control

----------

***Note:
defaultFocus does not work for custom views. [Set default focused component when a page is created.]***

----------

**DEMO Example:**

```dart
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * Focus Page
 */
@Entry
@Component
struct FocusPage {

  private TAG: string = "FocusPage";

  private ID_TARGET_TEXT_INPUT: string = "ID_TARGET_TEXT_INPUT";

  // Whether focus can be obtained, default is false
  @State isFocusable: boolean = true;

  private requestFocus(){
    focusControl.requestFocus(this.ID_TARGET_TEXT_INPUT);
  }

  private setFocus(){
    this.isFocusable = true;
    this.requestFocus();
  }

  onClickSetFocus = ()=>{
    this.setFocus();
  }

  onClickResetFocus = ()=>{
    // Disable focus to immediately lose focus
    this.isFocusable = false;
  }

  private showToast(content: string){
    try {
      promptAction.showToast({
        message: content,
        duration: 2000
      });
    } catch (error) {
      let message = (error as BusinessError).message
      let code = (error as BusinessError).code
      console.error(this.TAG, `showToast args error code is ${code}, message is ${message}`);
    };
  }

  build() {
    Column(){
      TextInput()
        .id(this.ID_TARGET_TEXT_INPUT)
        .size({
          width: px2vp(600),
          height: px2vp(200)
        })
        .defaultFocus(true) // Set default focus to true so the input box gains focus and pops up the keyboard when the page loads
        .focusable(this.isFocusable)
        // Focus gain callback
        .onFocus(()=>{
          // Do something ..
          this.showToast("onFocus Focus gained callback");
        })
        // Focus loss callback
        .onBlur(()=>{
          // Do something ..
          this.showToast("onBlur Focus lost callback");
        })
        .onClick(()=>{
          this.setFocus();
        })

      Row(){
        Button("click set focus")
          .size({
            width: px2vp(600),
            height: px2vp(200)
          })
          .margin({ top: px2vp(100) })
          .onClick(this.onClickSetFocus)

        Blank()

        Button("click reset focus")
          .size({
            width: px2vp(600),
            height: px2vp(200)
          })
          .margin({ top: px2vp(100) })
          .onClick(this.onClickResetFocus)
      }
      .size({
        width: "100%",
        height: px2vp(200),
      })
      .padding({ left: px2vp(20), right: px2vp(20) })
    }
    .justifyContent(FlexAlign.Center)
    .size({
      width: "100%",
      height: "100%"
    })
  }
}
```
