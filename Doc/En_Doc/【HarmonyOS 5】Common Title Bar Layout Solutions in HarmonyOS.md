## 【HarmonyOS 5】Common Title Bar Layout Solutions in HarmonyOS  

\## HarmonyOS Development Capabilities ## HarmonyOS SDK Application Services ## HarmonyOS Financial Applications (Financial Management #  


### 一、Problem Background  
The common title bar in HarmonyOS is a rectangular area with a back button on the left, a help button (often a question mark) on the right, and title text in the center. Many developers struggle with alignment when using the `Row` component for layout.  


### 二、Solutions  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_a80c2ef3.png 'image.png')  


#### Solution 1: Using Flex Layout  
Use a Flex layout to horizontally align the back button, title text, and help button. `justifyContent: FlexAlign.SpaceBetween` distributes the components evenly, and `alignItems: ItemAlign.Center` centers them vertically.  

```dart  
@Entry  
@Component  
struct TitleBarFlex {  
  build() {  
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {  
      // Left back button  
      Button('←')  
        .onClick(() => {  
          console.log('Back button clicked');  
        })  

      // Center title text  
      Text('Title Text')  
        .fontSize(20)  
        .fontWeight(FontWeight.Bold)  

      // Right help button  
      Button('?')  
        .onClick(() => {  
          console.log('Help button clicked');  
        })  
    }  
    .width('100%')  
    .height(50)  
    .padding({ left: 10, right: 10 })  
    .backgroundColor('#F0F0F0');  
  }  
}  
```  


#### Solution 2: Using Stack Layout  
Use a Stack layout to stack the three components. Position the back button and help button with the `position` attribute, and center the title text with `alignContent: Alignment.Center`.  

```dart  
@Entry  
@Component  
struct Index {  
  build() {  
    Stack({ alignContent: Alignment.Center }) {  
      // Center title text  
      Text('Title Text')  
        .fontSize(20)  
        .fontWeight(FontWeight.Bold)  

      // Left back button  
      Button('←')  
        .position({ x: 10, y: 5 })  
        .onClick(() => {  
          console.log('Back button clicked');  
        })  

      // Right help button  
      Button('?')  
        .position({ x: "88%", y: 5 })  
        .onClick(() => {  
          console.log('Help button clicked');  
        })  
    }  
    .width('100%')  
    .height(50)  
    .backgroundColor('#F0F0F0');  
  }  
}  
```