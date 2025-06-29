# 【HarmonyOS 5】Detailed Explanation of AttributeModifier and AttributeUpdater Differences

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services ##HarmonyOS Financial Applications (Financial Management #  

## I. Definitions and Roles of AttributeModifier and AttributeUpdater  

**1. AttributeModifier** is a dynamic attribute of ArkUI components that provides attribute setting functionality. Developers can use the attributeModifier method and customize the implementation of the AttributeModifier<T> interface to dynamically set component attributes.  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_0dbb5f1f.png 'image.png')  


| Method                     | Function                 | API Support                | System Capability                          |  
| ------------------------ | ---------------------- | ------------------------ | -------------------------------------- |  
| `applyNormalAttribute`   | Set the style in the normal state of the component    | Supported in meta services starting from API version 12 | `SystemCapability.ArkUI.ArkUI.Full` |  
| `applyPressedAttribute`  | Set the style in the pressed state of the component   | Supported in meta services starting from API version 12 | `SystemCapability.ArkUI.ArkUI.Full` |  
| `applyFocusedAttribute`  | Set the style in the focused state of the component   | Supported in meta services starting from API version 12 | `SystemCapability.ArkUI.ArkUI.Full` |  
| `applyDisabledAttribute` | Set the style in the disabled state of the component  | Supported in meta services starting from API version 12 | `SystemCapability.ArkUI.ArkUI.Full` |  
| `applySelectedAttribute` | Set the style in the selected state of the component  | Supported in meta services starting from API version 12 | `SystemCapability.ArkUI.ArkUI.Full` |  

This attribute can be used to achieve the following three scenarios:  

**(1) Encapsulating Shared UI Attribute Styles**  

```js
// Custom implementation of the AttributeModifier UI style interface for reuse
class MyModifier implements AttributeModifier<ButtonAttribute> {
  // Normal state style
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

**(2) Dynamically Updating Styles**  

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

**(3) Modifying Styles for Multiple States (Focused, Pressed, Default, Selected, Disabled)**  

```js
// Custom implementation of the AttributeModifier interface for multiple states
class MyModifier implements AttributeModifier<ButtonAttribute> {
  // Normal state style
  applyNormalAttribute(instance: ButtonAttribute): void {
    instance.fontColor(Color.Black)
    instance.fontSize(20)
  }
  // Pressed state style
  applyPressedAttribute(instance: ButtonAttribute): void {
    instance.fontColor(Color.Red)
    instance.fontSize(14)
  }
  // Focused state style
  applyFocusedAttribute(instance: ButtonAttribute): void {
    instance.fontColor(Color.Blue)
    instance.fontSize(18)
  }
  // Selected state style
  applySelectedAttribute(instance: ButtonAttribute): void {
    instance.fontColor(Color.Green)
    instance.fontSize(16)
  }
  // Disabled state style
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
        // Test text component
        Button(this.textContent)
          .attributeModifier(this.modifier)
          .width('100%')
          .height(50)
          .id("testButton")
          .onFocus(() => {
            // Focus event
            this.textContent = "聚焦时的文本内容";
          })
          .onBlur(() => {
            // Blur event
          })
          .enabled(!this.isDisabled)
          .margin({
            bottom: 50
          })

        // Button to toggle disabled state
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

        // Button to toggle selected state
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

For details, refer to the official API documentation [AttributeModifier Dynamic Attribute Setting - Universal Attributes - Component Universal Information - ArkTS Components - ArkUI (ArkUI Framework) - Application Framework - Huawei HarmonyOS Developer](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V14/ts-universal-attributes-attribute-modifier-V14#attributemodifiert)  


**2. AttributeUpdater** is an attribute updater provided by the ArkUI framework, used to update attributes and trigger UI updates for components. It needs to be imported from the @kit.ArkUI module, and developers can create custom classes that inherit from AttributeUpdater.  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_bad5893c.png 'image.png')  


| Method                       | Function                          | Parameters                | Return Value       | API Support                          | System Capability                          |  
| -------------------------- | ------------------------------- | ----------------------- | -------------- | ------------------------------------ | -------------------------------------- |  
| `applyNormalAttribute`     | Define the normal state attribute update function              | `instance` (component attribute class, required)   | None           | Supported in meta services starting from API version 12       | `SystemCapability.ArkUI.ArkUI.Full` |  
| `initializeModifier`       | Provide styles when AttributeUpdater is first set for the component | `instance` (component attribute class, required)   | None           | Supported in meta services starting from API version 12       | `SystemCapability.ArkUI.ArkUI.Full` |  
| `attribute`                | Get the attribute class instance of the component for direct attribute updates      | None                    | `T undefined` (returns the instance if it exists, otherwise `undefined`) | Supported in meta services starting from API version 12       | `SystemCapability.ArkUI.ArkUI.Full` |  
| `updateConstructorParams`  | Change the constructor parameters of the component              | None                    | `C` (component constructor type)       | Supported in meta services starting from API version 12       | `SystemCapability.ArkUI.ArkUI.Full` |  
| `onComponentChanged`       | Bind the same custom Modifier object and notify the application when the component switches | `component` (component attribute class, required) | None           | Supported in meta services starting from API version 12       | `SystemCapability.ArkUI.ArkUI.Full` |  

```js
// Import necessary modules
import { AttributeUpdater } from '@kit.ArkUI';

// Custom AttributeUpdater class
class TextAttributeUpdater extends AttributeUpdater<TextAttribute, TextInterface> {
  // Initialize component styles
  initializeModifier(instance: TextAttribute): void {
    instance.fontSize(16)
      .fontColor(Color.Yellow)
  }

  // Define the normal state attribute update function
  applyNormalAttribute(instance: TextAttribute): void {
    instance.fontSize(20)
      .fontColor(Color.Blue)
  }

}

// Page component
@Entry
@Component
struct AttUpdateTestPage {
  private textUpdater: TextAttributeUpdater = new TextAttributeUpdater();

  build() {
    Column({ space: 50 }) {
      // Text component using AttributeUpdater
      Text("默认文本")
        .attributeModifier(this.textUpdater)
        .width('100%')
        .textAlign(TextAlign.Center)

      // Button to trigger attribute update
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

For details, refer to the official API documentation [AttributeUpdater - arkui - UI Interface - ArkTS API - ArkUI (ArkUI Framework) - Application Framework - Huawei HarmonyOS Developer](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V14/js-apis-arkui-attributeupdater-V14?catalogVersion=V14)  


## II. Commonalities and Differences Between AttributeModifier and AttributeUpdater  

**1. Commonalities**  

(1) Both can set component attributes.  

(2) AttributeUpdater inherits from AttributeModifier; in fact, Update is a special Modifier.  

**2. Differences**  

(1) AttributeModifier is mainly used for the three scenarios described above: encapsulating shared UI attribute styles, achieving polymorphic UI representations, and dynamically modifying a small number of UI attributes.  

(2) AttributeUpdater focuses on directly setting attributes to components, triggering UI updates directly without marking them as state variables. It places more emphasis on direct attribute updates and changing component constructor parameters. In fact, Update is mainly used to handle large-scale attribute modifications, specifically to solve the performance loss problem when AttributeModifier handles large-scale attribute modifications. Therefore, using an attribute updater can directly bypass the ArkUI @State mechanism for attribute updates.  

(3) AttributeModifier: Custom Modifiers do not support perceiving changes in state data decorated with @State.  
AttributeUpdater: Can directly update attributes to trigger UI changes, and to a certain extent, can be regarded as bypassing the regular state management mechanism to achieve attribute updates, providing more direct control over attribute updates.  


## III. Source Code Examples  

```js
import { AttributeUpdater } from '@ohos.arkui.modifier'

/**
 * AttributeUpdater definition
 */
class MyButtonUpdate extends AttributeUpdater<ButtonAttribute> {
  // The initializeModifier method is triggered when first bound, for attribute initialization
  initializeModifier(instance: ButtonAttribute): void {
    instance
      .width('50%')
      .height(30)

  }
}

/**
 * AttributeModifier definition
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
  // Although AttributeUpdater inherits from AttributeModifier, it has the ability to update attributes
  update: MyButtonUpdate = new MyButtonUpdate();

  // AttributeModifier needs to use @State for data binding so that the control can support dynamic updates.
  // @State modifier: MyButtonModifier = new MyButtonModifier();

  build() {
    Row() {
      Column() {
        Button("Button")
          // .attributeModifier(this.modifier)
          .attributeModifier(this.update)
          .onClick(() => {
            // this.modifier.isDark = !this.modifier.isDark

            // Directly modify component attributes through attribute and trigger component attribute update immediately
            this.update.attribute?.width('100%').fontSize(52);
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
```  


### **Notes:**  

**AttributeModifier**: The attribute support scope does not include attributes with parameters as CustomBuilder or Lambda expressions, and does not support gestures. Only some specific events are supported.  

**AttributeUpdater**: updateConstructorParams currently only supports Button, Image, Text, and Span components, and does not support operations related to state management such as light and dark mode switching.