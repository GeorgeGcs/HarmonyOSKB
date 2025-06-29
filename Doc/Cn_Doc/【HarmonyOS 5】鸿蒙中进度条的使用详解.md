# 【HarmonyOS 5】鸿蒙中进度条的使用详解

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

## 一、HarmonyOS中Progress进度条的类型
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_8f1a022d.png 'image.png')


HarmonyOS的ArkUI框架为开发者提供了多种类型的进度条，每种类型都有其独特的样式，以满足不同的设计需求。以下是几种常见的进度条类型：

1.  **线性进度条（Linear）**：这是最常见的进度条样式，以直线的形式展示进度。从API version 9开始，当组件高度大于宽度时，它会自适应垂直显示；当高度和宽度相等时，保持水平显示。

2.  **环形无刻度进度条（Ring）**：这种进度条呈环形，通过环形圆环的逐渐填充来显示进度，默认前景色为蓝色，默认strokeWidth进度条宽度为2.0vp。

3.  **环形有刻度进度条（ScaleRing）**：它显示类似时钟刻度形式的进度展示效果。在头尾两端圆弧处的进度展示效果与圆形样式（Eclipse）相同，中段处的进度展示效果为矩形状长条，与线性样式相似。从API version 9开始，当刻度外圈出现重叠时，它会自动转换为环形无刻度进度条。

4.  **椭圆形进度条（Eclipse）**：显示类似月圆月缺的进度展示效果，从月牙逐渐变化至满月。

5.  **胶囊进度条（Capsule）**：头尾两端圆弧处的进度展示效果与椭圆形样式（Eclipse）相同，中段处的进度展示效果与线性样式（Linear）相同。当高度大于宽度时，它会自适应垂直显示。

## 三、使用ArkTS创建和设置进度条

### （一）创建进度条

在ArkTS中，我们通过调用Progress接口来创建进度条。以下是创建进度条的基本语法：

```typescript
Progress({ value: number, total?: number, type?: ProgressType })
```

### （二）设置进度条样式

我们可以在创建进度条时，通过设置`ProgressType`枚举类型给`type`可选项指定不同的进度条类型，从而实现多样化的样式。以下是不同类型进度条的设置示例：

1.  **线性进度条**：

```typescript
Progress({ value: 50, total: 100, type: ProgressType.Linear })
```

2.  **环形无刻度进度条**：

```typescript
Progress({ value: 30, total: 100, type: ProgressType.Ring })
```

3.  **环形有刻度进度条**：

```typescript
Progress({ value: 70, total: 100, type: ProgressType.ScaleRing })
```

4.  **椭圆形进度条**：

```typescript
Progress({ value: 10, total: 100, type: ProgressType.Eclipse })
```

5.  **胶囊进度条**：

```typescript
Progress({ value: 45, total: 100, type: ProgressType.Capsule })
```

### （三）动态更新进度

进度条的关键功能之一是能够在任务执行过程中动态更新进度，以反映任务的实时进展。

在鸿蒙Progress组件中通过value和total两个属性来实现进度条得更新效果，源码如下：

其中，`value`用于设置初始进度值，`total`用于设置进度总长度，`type`决定Progress的样式。如果不设置`type`，默认使用线性进度条样式。

```typescript
Progress({ value: 24, total: 100, type: ProgressType.Linear })
```

```typescript
import prompt from '@ohos.prompt';

@Entry
@Component
struct DownloadProgressBar {
  // 下载进度，初始值为 0
  @State progress: number = 0;
  // 下载状态提示信息
  @State status: string = '等待下载';

  // 模拟下载的函数
  startDownload() {
    // 模拟下载过程，使用 setInterval 定时更新进度
    let intervalId = setInterval(() => {
      this.progress += 10;
      if (this.progress >= 100) {
        this.status = '下载完成';
        clearInterval(intervalId);
        prompt.showToast({ message: '下载已完成' });
      } else {
        this.status = `下载中，进度: ${this.progress}%`;
      }
    }, 1000);
  }

  build() {
    Column({ space: 20 }) {
      Text('下载进度条示例')
        .fontSize(20)
        .fontWeight(FontWeight.Bold);

      Progress({ value: this.progress, total: 100 })
        .width('90%')
        .height(20);

      Text(this.status)
        .fontSize(16);

      Button('开始下载')
        .width('60%')
        .height(40)
        .backgroundColor(Color.Blue)
        .fontColor(Color.White)
        .onClick(() => {
          this.startDownload();
        });
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center);
  }
}
```
