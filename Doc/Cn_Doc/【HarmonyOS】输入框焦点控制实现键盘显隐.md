## 【HarmonyOS】输入框焦点控制实现键盘显隐和进入页面默认弹出键盘获取a焦点设置

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

**问题背景：**
鸿蒙中输入框控件，TextInput最常见的控制，即：针对输入框焦点控制，获取焦点，失去焦点。达到用户方便操作输入和退出输入。

因为输入框一定会伴随着键盘交互，一般在逻辑控制上和UI渲染上，都可能会需要**动态调整改焦点**。

另外一个比较常用的需求是，进入页面，键盘就自动弹出，输入框**默认获取焦点**。

**解决方案：**
**问题一：**

1.首先调用此接口可以主动让焦点转移至参数指定的组件上：

focusControl.requestFocus("id");

----------

***注意：
1.支持焦点控制的组件：TextInput、TextArea、Search、Button、Text、Image、List、Grid。焦点事件当前仅支持在真机上显示运行效果。***

----------

2.监听监控自身的获取焦点回调和失去焦点回调：
onFocus
onBlur

3.点击控件时需要设置控件获取焦点

**问题二：**
1.进入页面，键盘就自动弹出，需要在输入框控件上设置 defaultFocu(true)

----------

***注意：
defaultFocus对于自定义view不生效【Set default focused component when a page create.】***

----------

**DEMO示例：**

```dart
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 焦点界面
 */
@Entry
@Component
struct FocusPage {

  private TAG: string = "FocusPage";

  private ID_TARGET_TEXT_INPUT: string = "ID_TARGET_TEXT_INPUT";

  // 是否能获焦，默认false
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
    // 禁用焦点，就可直接失去焦点
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
        .defaultFocus(true) // 设置默认焦点为true，进入页面就会获取焦点，弹出键盘
        .focusable(this.isFocusable)
        // 获得焦点回调
        .onFocus(()=>{
          // do sth ..
          this.showToast("onFocus 获得焦点回调");
        })
        // 失去焦点回调
        .onBlur(()=>{
          // do sth ..
          this.showToast("onBlur 失去焦点回调");
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

