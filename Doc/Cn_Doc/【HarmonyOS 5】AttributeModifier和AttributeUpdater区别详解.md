# 【HarmonyOS 5】AttributeModifier和AttributeUpdater区别详解

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

## 一、AttributeModifier和AttributeUpdater的定义和作用

**1. AttributeModifier**是ArkUI组件的动态属性，提供属性设置功能。开发者可使用attributeModifier方法，通过自定义实现AttributeModifier<T>接口，来动态设置组件属性。
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_0dbb5f1f.png 'image.png')


| 方法                       | 作用           | API 支持                     | 系统能力                                |
| ------------------------ | ------------ | -------------------------- | ----------------------------------- |
| `applyNormalAttribute`   | 设置组件普通状态时的样式 | 从 API version 12 开始在元服务中支持 | `SystemCapability.ArkUI.ArkUI.Full` |
| `applyPressedAttribute`  | 设置组件按压状态的样式  | 从 API version 12 开始在元服务中支持 | `SystemCapability.ArkUI.ArkUI.Full` |
| `applyFocusedAttribute`  | 设置组件获焦状态的样式  | 从 API version 12 开始在元服务中支持 | `SystemCapability.ArkUI.ArkUI.Full` |
| `applyDisabledAttribute` | 设置组件禁用状态的样式  | 从 API version 12 开始在元服务中支持 | `SystemCapability.ArkUI.ArkUI.Full` |
| `applySelectedAttribute` | 设置组件选中状态的样式  | 从 API version 12 开始在元服务中支持 | `SystemCapability.ArkUI.ArkUI.Full` |

该属性可以提供实现以下三种场景的效果实现：

**（1）封装共享UI属性样式**

```js
// 自定义实现AttributeModifier UI样式接口用于复用
class MyModifier implements AttributeModifier<ButtonAttribute> {
  // 普通状态样式
  applyNormalAttribute(instance: ButtonAttribute): void {
    instance.fontColor(Color.Black)
    instance.fontSize(20)
  }
}

@Entry
@Component
struct AttTestPage {

  @State modifier: MyModifier = new MyModifier()

  build() {
      Column() {
        Button("按钮1")
          .attributeModifier(this.modifier)

       Button("按钮2")
          .attributeModifier(this.modifier)
          
       Button("按钮3")
          .attributeModifier(this.modifier)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.White)
      .justifyContent(FlexAlign.Center)
  }
}
```

**（2）动态更新样式**

```js
class MyButtonModifier implements AttributeModifier<ButtonAttribute> {
  isDark: boolean = false

  applyNormalAttribute(instance: ButtonAttribute): void {
    if (this.isDark) {
      instance.backgroundColor(Color.Blue);
    } else {
      instance.backgroundColor(Color.Red);
    }
  }
}

@Entry
@Component
struct updateTestPage {
  @State modifier: MyButtonModifier = new MyButtonModifier();

  build() {
      Column() {
        Button("Button")
          .attributeModifier(this.modifier)
          .onClick(() => {
            this.modifier.isDark = !this.modifier.isDark;
          })
      }
      .width('100%')
      .height('100%')
  }
}
```

**（3）满足多态度样式的修改（聚焦，按下，默认，选择，禁用）**

```js

// 自定义实现AttributeModifier多种状态接口
class MyModifier implements AttributeModifier<ButtonAttribute> {
  // 普通状态样式
  applyNormalAttribute(instance: ButtonAttribute): void {
    instance.fontColor(Color.Black)
    instance.fontSize(20)
  }
  // 按下状态样式
  applyPressedAttribute(instance: ButtonAttribute): void {
    instance.fontColor(Color.Red)
    instance.fontSize(14)
  }
  // 聚焦状态样式
  applyFocusedAttribute(instance: ButtonAttribute): void {
    instance.fontColor(Color.Blue)
    instance.fontSize(18)
  }
  // 选择状态样式
  applySelectedAttribute(instance: ButtonAttribute): void {
    instance.fontColor(Color.Green)
    instance.fontSize(16)
  }
  // 禁用状态样式
  applyDisabledAttribute(instance: ButtonAttribute): void {
    instance.fontColor(Color.Gray)
    instance.fontSize(16)
  }
}

@Entry
@Component
struct AttTestPage {

  @State modifier: MyModifier = new MyModifier()
  @State isDisabled: boolean = false;
  @State isFocused: boolean = false;

  @State textContent: string = "默认文本内容";

  build() {
      Column() {
        // 测试文本组件
        Button(this.textContent)
          .attributeModifier(this.modifier)
          .width('100%')
          .height(50)
          .id("testButton")
          .onFocus(() => {
            // 聚焦事件
            this.textContent = "聚焦时的文本内容";
          })
          .onBlur(() => {
            // 失焦事件
          })
          .enabled(!this.isDisabled)
          .margin({
            bottom: 50
          })

        // 切换禁用状态按钮
        Button(this.isDisabled? '启用文本' : '禁用文本')
          .onClick(() => {
            this.isDisabled =!this.isDisabled;
            if(this.isDisabled){
              this.textContent = "禁用时的文本内容";
            }
          })
          .id("enableButton")
          .width('100%')
          .height(50)
          .margin({
            bottom: 50
          })

        // 切换选择状态按钮
        Button(this.isFocused? '设置聚焦' : '取消聚焦')
          .onClick(() => {
            this.isFocused =!this.isFocused;
            if(this.isFocused){
              this.getUIContext().getFocusController().requestFocus("testButton")
              this.textContent = "选择时的文本内容";
            }else{
              this.getUIContext().getFocusController().requestFocus("enableButton")
            }
          })
          .width('100%')
          .height(50)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.White)
      .justifyContent(FlexAlign.Center)
  }
}
```

详情参见官方API文档[AttributeModifier动态属性设置-通用属性-组件通用信息-ArkTS组件-ArkUI（方舟UI框架）-应用框架 - 华为HarmonyOS开发者](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V14/ts-universal-attributes-attribute-modifier-V14#attributemodifiert)

**2. AttributeUpdater**是ArkUI框架提供的属性更新器。用于更新属性的给组件触发 UI 更新。需从@kit.ArkUI导入模块，开发者自定义类继承AttributeUpdater。
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_bad5893c.png 'image.png')


| 方法                        | 作用                            | 参数                    | 返回值           | API 支持                               | 系统能力                                |                                     |
| ------------------------- | ----------------------------- | --------------------- | ------------- | ------------------------------------ | ----------------------------------- | ----------------------------------- |
| `applyNormalAttribute`    | 定义正常态更新属性函数                   | `instance`（组件属性类，必填）  | 无             | 从 API version 12 开始在元服务中支持           | `SystemCapability.ArkUI.ArkUI.Full` |                                     |
| `initializeModifier`      | AttributeUpdater 首次设置给组件时提供样式 | `instance`（组件属性类，必填）  | 无             | 从 API version 12 开始在元服务中支持           | `SystemCapability.ArkUI.ArkUI.Full` |                                     |
| `attribute`               | 获取组件对应的属性类实例，实现属性直通更新         | 无                     | \`T           | undefined`（存在则返回实例，否则返回`undefined\`） | 从 API version 12 开始在元服务中支持          | `SystemCapability.ArkUI.ArkUI.Full` |
| `updateConstructorParams` | 更改组件的构造入参                     | 无                     | `C`（组件构造函数类型） | 从 API version 12 开始在元服务中支持           | `SystemCapability.ArkUI.ArkUI.Full` |                                     |
| `onComponentChanged`      | 绑定相同自定义 Modifier 对象，组件切换时通知应用 | `component`（组件属性类，必填） | 无             | 从 API version 12 开始在元服务中支持           | `SystemCapability.ArkUI.ArkUI.Full` |                                     |

```js

// 导入必要的模块
import { AttributeUpdater } from '@kit.ArkUI';

// 自定义 AttributeUpdater 类
class TextAttributeUpdater extends AttributeUpdater<TextAttribute, TextInterface> {
  // 初始化设置组件样式
  initializeModifier(instance: TextAttribute): void {
    instance.fontSize(16)
      .fontColor(Color.Yellow)
  }

  // 定义正常态更新属性函数
  applyNormalAttribute(instance: TextAttribute): void {
    instance.fontSize(20)
      .fontColor(Color.Blue)
  }

}

// 页面组件
@Entry
@Component
struct AttUpdateTestPage {
  private textUpdater: TextAttributeUpdater = new TextAttributeUpdater();

  build() {
    Column({ space: 50 }) {
      // 使用 AttributeUpdater 的 Text 组件
      Text("默认文本")
        .attributeModifier(this.textUpdater)
        .width('100%')
        .textAlign(TextAlign.Center)

      // 按钮用于触发属性更新
      Button('更新属性')
        .onClick(() => {
          this.textUpdater.attribute?.fontColor(Color.Red);
          this.textUpdater.updateConstructorParams("修改文本内容");
        })
        .width('100%')
    }
    .width('100%')
    .padding({ top: 100 })
  }
}
```

详情参见官方API文档[AttributeUpdater-arkui-UI界面-ArkTS API-ArkUI（方舟UI框架）-应用框架 - 华为HarmonyOS开发者](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V14/js-apis-arkui-attributeupdater-V14?catalogVersion=V14)

## 二、AttributeModifier和AttributeUpdater的共性和区别

**1. 共性**

(1) 都可对组件属性进行设置

(2) AttributeUpdater继承于AttributeModifier，实际上update是个特殊的modifier。

**2. 区别**

（1）AttributeModifie主要用于上述描述的三种场景，封装共享UI属性样式，实现多态UI表现，动态修改小批量的UI属性。

（2）AttributeUpdater侧重于将属性直接设置给组件，无需标记为状态变量即可直接触发 UI 更新。它更强调属性的直通更新以及对组件构造入参的更改等功能。实际上Update主要处理大批量的属性修改，主要就是为了解决AttributeModifie处理大量属性修改时性能损耗的问题。所以使用属性更新器，可直接绕过ArkUI的@State机制进行属性的更新。

(3) AttributeModifier：自定义 Modifier 不支持感知 @State 装饰的状态数据变化。
AttributeUpdater：可直接更新属性触发 UI 变化，在一定程度上可以看作是绕过了常规的状态管理机制来实现属性更新，对属性更新的控制更为直接。

## 三、源码示例

```js
import { AttributeUpdater } from '@ohos.arkui.modifier'

/**
 * AttributeUpdater定义
 */
class MyButtonUpdate extends AttributeUpdater<ButtonAttribute> {
  // 首次绑定时触发initializeModifier方法，进行属性初始化
  initializeModifier(instance: ButtonAttribute): void {
    instance
      .width('50%')
      .height(30)

  }
}

/**
 * AttributeModifier定义
 */
class MyButtonModifier implements AttributeModifier<ButtonAttribute> {
  isDark: boolean = false

  applyNormalAttribute(instance: ButtonAttribute): void {
    if (this.isDark) {
      instance.backgroundColor(Color.Blue)
    } else {
      instance.backgroundColor(Color.Red)
    }
  }
}

@Entry
@Component
struct Index {
  // AttributeUpdater 虽然继承于AttributeModifier需要使用，但是自带更新属性的能力
  update: MyButtonUpdate = new MyButtonUpdate();

  // AttributeModifier需要使用@State进行数据绑定，控件才能支持动态更新。
  // @State modifier: MyButtonModifier = new MyButtonModifier();

  build() {
    Row() {
      Column() {
        Button("Button")
          // .attributeModifier(this.modifier)
          .attributeModifier(this.update)
          .onClick(() => {
            // this.modifier.isDark = !this.modifier.isDark

            // 通过attribute，直接修改组件属性，并立即触发组件属性更新
            this.update.attribute?.width('100%').fontSize(52);
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
```

### **注意：**

**AttributeModifier**：属性支持范围不支持入参为 CustomBuilder 或 Lamda 表达式的属性，且不支持手势，事件仅支持部分特定事件。

**AttributeUpdater**：updateConstructorParams 当前只支持 Button、Image、Text 和 Span 组件，且不支持深浅色切换等状态管理相关的操作。
