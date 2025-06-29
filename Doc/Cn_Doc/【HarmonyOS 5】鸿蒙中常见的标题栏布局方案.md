## 【HarmonyOS 5】鸿蒙中常见的标题栏布局方案

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

## 一、问题背景：

鸿蒙中常见的标题栏：矩形区域，左边是返回按钮，右边是问号帮助按钮，中间是标题文字。

那有几种布局方式，分别怎么布局呢？常见的思维是，有老铁使用row去布局，怎么都对不齐。

## 二、解决方案
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_a80c2ef3.png 'image.png')


**方案一，使用Flex布局：**
使用Flex布局将返回按钮、标题文字和帮助按钮水平排列，通过justifyContent: FlexAlign.SpaceBetween使三个组件在水平方向上均匀分布，alignItems: ItemAlign.Center使组件在垂直方向上居中对齐。

```dart
@Entry
@Component
struct TitleBarFlex {
  build() {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      // 左边返回按钮
      Button('←')
        .onClick(() => {
          console.log('返回按钮被点击')
        })

      // 中间标题文字
      Text('标题文字')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)

      // 右边问号帮助按钮
      Button('?')
        .onClick(() => {
          console.log('帮助按钮被点击')
        })
    }
    .width('100%')
    .height(50)
    .padding({ left: 10, right: 10 })
    .backgroundColor('#F0F0F0')
  }
}
```

**方案二，使用Stack布局：**
使用Stack布局将三个组件堆叠在一起，通过position属性分别设置返回按钮和帮助按钮的位置，标题文字通过alignContent: Alignment.Center使其在布局中居中显示。

```dart
@Entry
@Component
struct Index {
  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 中间标题文字
      Text('标题文字')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)

      // 左边返回按钮
      Button('←')
        .position({ x: 10, y: 5 })
        .onClick(() => {
          console.log('返回按钮被点击')
        })

      // 右边问号帮助按钮
      Button('?')
        .position({ x: "88%", y: 5 })
        .onClick(() => {
          console.log('帮助按钮被点击')
        })
    }
    .width('100%')
    .height(50)
    .backgroundColor('#F0F0F0')
  }
}

```
